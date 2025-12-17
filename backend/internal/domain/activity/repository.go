package activity

import (
	"context"
	"time"
)

type Repository interface {
	Create(ctx context.Context, log *Log) error
	FindByID(ctx context.Context, id uint64) (*Log, error)
	FindByUserID(ctx context.Context, userID uint64, pagination *Pagination) ([]*Log, int64, error)
	FindAll(ctx context.Context, filter *Filter, pagination *Pagination) ([]*Log, int64, error)
	GetStats(ctx context.Context, filter *StatsFilter) (*Stats, error)
	GetUserStats(ctx context.Context, userID uint64) (*UserStats, error)
}

type Filter struct {
	UserID       *uint64
	ActivityType *ActivityType
	IPAddress    *string
	DateFrom     *time.Time
	DateTo       *time.Time
}

type Pagination struct {
	Page    int
	PerPage int
	SortBy  string
	SortDir string
}

func (p *Pagination) Offset() int {
	return (p.Page - 1) * p.PerPage
}

func NewPagination() *Pagination {
	return &Pagination{
		Page:    1,
		PerPage: 15,
		SortBy:  "created_at",
		SortDir: "desc",
	}
}

type StatsFilter struct {
	DateFrom *time.Time
	DateTo   *time.Time
}

type Stats struct {
	TotalActivities   int64                   `json:"total_activities"`
	ByActivityType    map[ActivityType]int64  `json:"by_activity_type"`
	ByDeviceType      map[string]int64        `json:"by_device_type"`
	TodayActivities   int64                   `json:"today_activities"`
	ActiveUsersToday  int64                   `json:"active_users_today"`
	LoginCountToday   int64                   `json:"login_count_today"`
}

type UserStats struct {
	TotalLogins       int64      `json:"total_logins"`
	LastLoginAt       *time.Time `json:"last_login_at"`
	LastLoginIP       *string    `json:"last_login_ip"`
	FailedLoginCount  int64      `json:"failed_login_count"`
	DevicesUsed       []string   `json:"devices_used"`
}
