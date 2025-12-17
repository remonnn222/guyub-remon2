package mysql

import (
	"context"
	"errors"
	"strings"
	"time"

	"guyub/internal/domain/audit"

	"gorm.io/gorm"
)

type AuditRepository struct {
	db *gorm.DB
}

func NewAuditRepository(db *gorm.DB) audit.Repository {
	return &AuditRepository{db: db}
}

func (r *AuditRepository) Create(ctx context.Context, log *audit.Log) error {
	return r.db.WithContext(ctx).Create(log).Error
}

func (r *AuditRepository) FindByID(ctx context.Context, id uint64) (*audit.Log, error) {
	var log audit.Log
	err := r.db.WithContext(ctx).First(&log, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &log, err
}

func (r *AuditRepository) FindAll(ctx context.Context, filter *audit.Filter, pagination *audit.Pagination) ([]*audit.Log, int64, error) {
	var logs []*audit.Log
	var total int64

	query := r.db.WithContext(ctx).Model(&audit.Log{})
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

func (r *AuditRepository) applyFilter(query *gorm.DB, filter *audit.Filter) *gorm.DB {
	if filter == nil {
		return query
	}

	if filter.UserID != nil {
		query = query.Where("user_id = ?", *filter.UserID)
	}

	if filter.Event != nil {
		query = query.Where("event = ?", *filter.Event)
	}

	if filter.AuditableType != nil {
		query = query.Where("auditable_type = ?", *filter.AuditableType)
	}

	if filter.AuditableID != nil {
		query = query.Where("auditable_id = ?", *filter.AuditableID)
	}

	if filter.SecurityLevel != nil {
		query = query.Where("security_level = ?", *filter.SecurityLevel)
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

	if filter.Search != "" {
		search := "%" + strings.ToLower(filter.Search) + "%"
		query = query.Where("LOWER(description) LIKE ? OR LOWER(user_name) LIKE ?", search, search)
	}

	return query
}

func (r *AuditRepository) applySorting(query *gorm.DB, pagination *audit.Pagination) *gorm.DB {
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

func (r *AuditRepository) GetStats(ctx context.Context, filter *audit.StatsFilter) (*audit.Stats, error) {
	stats := &audit.Stats{
		ByEvent:         make(map[audit.Event]int64),
		BySecurityLevel: make(map[audit.SecurityLevel]int64),
		ByAuditableType: make(map[string]int64),
	}

	query := r.db.WithContext(ctx).Model(&audit.Log{})
	if filter != nil {
		if filter.DateFrom != nil {
			query = query.Where("created_at >= ?", *filter.DateFrom)
		}
		if filter.DateTo != nil {
			query = query.Where("created_at <= ?", *filter.DateTo)
		}
	}

	// Total logs
	query.Count(&stats.TotalLogs)

	// By event
	var eventCounts []struct {
		Event audit.Event
		Count int64
	}
	r.db.WithContext(ctx).Model(&audit.Log{}).Select("event, COUNT(*) as count").Group("event").Scan(&eventCounts)
	for _, ec := range eventCounts {
		stats.ByEvent[ec.Event] = ec.Count
	}

	// By security level
	var levelCounts []struct {
		SecurityLevel audit.SecurityLevel
		Count         int64
	}
	r.db.WithContext(ctx).Model(&audit.Log{}).Select("security_level, COUNT(*) as count").Group("security_level").Scan(&levelCounts)
	for _, lc := range levelCounts {
		stats.BySecurityLevel[lc.SecurityLevel] = lc.Count
	}

	// By auditable type
	var typeCounts []struct {
		AuditableType string
		Count         int64
	}
	r.db.WithContext(ctx).Model(&audit.Log{}).Select("auditable_type, COUNT(*) as count").Group("auditable_type").Scan(&typeCounts)
	for _, tc := range typeCounts {
		stats.ByAuditableType[tc.AuditableType] = tc.Count
	}

	// Today logs
	today := time.Now().Truncate(24 * time.Hour)
	r.db.WithContext(ctx).Model(&audit.Log{}).Where("created_at >= ?", today).Count(&stats.TodayLogs)

	// This week logs
	weekStart := today.AddDate(0, 0, -int(today.Weekday()))
	r.db.WithContext(ctx).Model(&audit.Log{}).Where("created_at >= ?", weekStart).Count(&stats.ThisWeekLogs)

	return stats, nil
}
