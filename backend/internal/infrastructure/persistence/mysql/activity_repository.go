package mysql

import (
	"context"
	"errors"
	"strings"
	"time"

	"guyub/internal/domain/activity"

	"gorm.io/gorm"
)

type ActivityRepository struct {
	db *gorm.DB
}

func NewActivityRepository(db *gorm.DB) activity.Repository {
	return &ActivityRepository{db: db}
}

func (r *ActivityRepository) Create(ctx context.Context, log *activity.Log) error {
	return r.db.WithContext(ctx).Create(log).Error
}

func (r *ActivityRepository) FindByID(ctx context.Context, id uint64) (*activity.Log, error) {
	var log activity.Log
	err := r.db.WithContext(ctx).First(&log, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &log, err
}

func (r *ActivityRepository) FindByUserID(ctx context.Context, userID uint64, pagination *activity.Pagination) ([]*activity.Log, int64, error) {
	var logs []*activity.Log
	var total int64

	query := r.db.WithContext(ctx).Model(&activity.Log{}).Where("user_id = ?", userID)

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	query = r.applySorting(query, pagination)
	query = query.Offset(pagination.Offset()).Limit(pagination.PerPage)

	if err := query.Find(&logs).Error; err != nil {
		return nil, 0, err
	}

	return logs, total, nil
}

func (r *ActivityRepository) FindAll(ctx context.Context, filter *activity.Filter, pagination *activity.Pagination) ([]*activity.Log, int64, error) {
	var logs []*activity.Log
	var total int64

	query := r.db.WithContext(ctx).Model(&activity.Log{})
	query = r.applyFilter(query, filter)

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	query = r.applySorting(query, pagination)
	query = query.Offset(pagination.Offset()).Limit(pagination.PerPage)

	if err := query.Find(&logs).Error; err != nil {
		return nil, 0, err
	}

	return logs, total, nil
}

func (r *ActivityRepository) applyFilter(query *gorm.DB, filter *activity.Filter) *gorm.DB {
	if filter == nil {
		return query
	}

	if filter.UserID != nil {
		query = query.Where("user_id = ?", *filter.UserID)
	}

	if filter.ActivityType != nil {
		query = query.Where("activity_type = ?", *filter.ActivityType)
	}

	if filter.IPAddress != nil {
		query = query.Where("ip_address = ?", *filter.IPAddress)
	}

	if filter.DateFrom != nil {
		query = query.Where("created_at >= ?", *filter.DateFrom)
	}

	if filter.DateTo != nil {
		query = query.Where("created_at <= ?", *filter.DateTo)
	}

	return query
}

func (r *ActivityRepository) applySorting(query *gorm.DB, pagination *activity.Pagination) *gorm.DB {
	if pagination == nil {
		return query.Order("created_at DESC")
	}

	sortBy := pagination.SortBy
	if sortBy == "" {
		sortBy = "created_at"
	}

	sortDir := strings.ToUpper(pagination.SortDir)
	if sortDir != "ASC" && sortDir != "DESC" {
		sortDir = "DESC"
	}

	return query.Order(sortBy + " " + sortDir)
}

func (r *ActivityRepository) GetStats(ctx context.Context, filter *activity.StatsFilter) (*activity.Stats, error) {
	stats := &activity.Stats{
		ByActivityType: make(map[activity.ActivityType]int64),
		ByDeviceType:   make(map[string]int64),
	}

	query := r.db.WithContext(ctx).Model(&activity.Log{})
	if filter != nil {
		if filter.DateFrom != nil {
			query = query.Where("created_at >= ?", *filter.DateFrom)
		}
		if filter.DateTo != nil {
			query = query.Where("created_at <= ?", *filter.DateTo)
		}
	}

	// Total activities
	query.Count(&stats.TotalActivities)

	// By activity type
	var typeCounts []struct {
		ActivityType activity.ActivityType
		Count        int64
	}
	r.db.WithContext(ctx).Model(&activity.Log{}).Select("activity_type, COUNT(*) as count").Group("activity_type").Scan(&typeCounts)
	for _, tc := range typeCounts {
		stats.ByActivityType[tc.ActivityType] = tc.Count
	}

	// By device type
	var deviceCounts []struct {
		DeviceType string
		Count      int64
	}
	r.db.WithContext(ctx).Model(&activity.Log{}).Select("device_type, COUNT(*) as count").Where("device_type IS NOT NULL").Group("device_type").Scan(&deviceCounts)
	for _, dc := range deviceCounts {
		stats.ByDeviceType[dc.DeviceType] = dc.Count
	}

	// Today's activities
	today := time.Now().Truncate(24 * time.Hour)
	r.db.WithContext(ctx).Model(&activity.Log{}).Where("created_at >= ?", today).Count(&stats.TodayActivities)

	// Active users today
	r.db.WithContext(ctx).Model(&activity.Log{}).Where("created_at >= ?", today).Distinct("user_id").Count(&stats.ActiveUsersToday)

	// Login count today
	r.db.WithContext(ctx).Model(&activity.Log{}).Where("created_at >= ? AND activity_type = ?", today, activity.ActivityLogin).Count(&stats.LoginCountToday)

	return stats, nil
}

func (r *ActivityRepository) GetUserStats(ctx context.Context, userID uint64) (*activity.UserStats, error) {
	stats := &activity.UserStats{}

	// Total logins
	r.db.WithContext(ctx).Model(&activity.Log{}).
		Where("user_id = ? AND activity_type = ?", userID, activity.ActivityLogin).
		Count(&stats.TotalLogins)

	// Last login
	var lastLogin activity.Log
	err := r.db.WithContext(ctx).Model(&activity.Log{}).
		Where("user_id = ? AND activity_type = ?", userID, activity.ActivityLogin).
		Order("created_at DESC").
		First(&lastLogin).Error
	if err == nil {
		stats.LastLoginAt = &lastLogin.CreatedAt
		stats.LastLoginIP = lastLogin.IPAddress
	}

	// Failed login count
	r.db.WithContext(ctx).Model(&activity.Log{}).
		Where("user_id = ? AND activity_type = ?", userID, activity.ActivityLoginFailed).
		Count(&stats.FailedLoginCount)

	// Devices used
	r.db.WithContext(ctx).Model(&activity.Log{}).
		Where("user_id = ? AND device_type IS NOT NULL", userID).
		Distinct().
		Pluck("device_type", &stats.DevicesUsed)

	return stats, nil
}
