package audit

import (
	"context"
	"time"
)

type Repository interface {
	Create(ctx context.Context, log *Log) error
	FindByID(ctx context.Context, id uint64) (*Log, error)
	FindAll(ctx context.Context, filter *Filter, pagination *Pagination) ([]*Log, int64, error)
	GetStats(ctx context.Context, filter *StatsFilter) (*Stats, error)
}

type Filter struct {
	UserID        *uint64
	Event         *Event
	AuditableType *string
	AuditableID   *uint64
	SecurityLevel *SecurityLevel
	IPAddress     *string
	DateFrom      *time.Time
	DateTo        *time.Time
	Search        string
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
	TotalLogs        int64            `json:"total_logs"`
	ByEvent          map[Event]int64  `json:"by_event"`
	BySecurityLevel  map[SecurityLevel]int64 `json:"by_security_level"`
	ByAuditableType  map[string]int64 `json:"by_auditable_type"`
	TodayLogs        int64            `json:"today_logs"`
	ThisWeekLogs     int64            `json:"this_week_logs"`
}
