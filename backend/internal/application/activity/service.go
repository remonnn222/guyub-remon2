package activity

import (
	"context"

	domainActivity "guyub/internal/domain/activity"
)

type Service struct {
	activityRepo domainActivity.Repository
}

func NewService(activityRepo domainActivity.Repository) *Service {
	return &Service{
		activityRepo: activityRepo,
	}
}

// ListDTO represents the activity log response
type ListDTO struct {
	ID           uint64  `json:"id"`
	UserID       *uint64 `json:"user_id,omitempty"`
	ActivityType string  `json:"activity_type"`
	IPAddress    *string `json:"ip_address,omitempty"`
	UserAgent    *string `json:"user_agent,omitempty"`
	DeviceType   *string `json:"device_type,omitempty"`
	Browser      *string `json:"browser,omitempty"`
	Platform     *string `json:"platform,omitempty"`
	Description  *string `json:"description,omitempty"`
	CreatedAt    string  `json:"created_at"`
}

// PaginatedResult represents paginated activity logs
type PaginatedResult struct {
	Data  []ListDTO `json:"data"`
	Meta  Meta      `json:"meta"`
}

type Meta struct {
	CurrentPage int   `json:"current_page"`
	PerPage     int   `json:"per_page"`
	Total       int64 `json:"total"`
	TotalPages  int   `json:"total_pages"`
	From        int   `json:"from"`
	To          int   `json:"to"`
}

// ListParams represents query parameters for listing
type ListParams struct {
	Page         int
	PerPage      int
	SortBy       string
	SortOrder    string
	UserID       *uint64
	ActivityType *string
	DateFrom     *string
	DateTo       *string
}

func (s *Service) List(ctx context.Context, params ListParams) (*PaginatedResult, error) {
	pagination := &domainActivity.Pagination{
		Page:    params.Page,
		PerPage: params.PerPage,
		SortBy:  params.SortBy,
		SortDir: params.SortOrder,
	}

	if pagination.Page < 1 {
		pagination.Page = 1
	}
	if pagination.PerPage < 1 {
		pagination.PerPage = 10
	}
	if pagination.SortBy == "" {
		pagination.SortBy = "created_at"
	}
	if pagination.SortDir == "" {
		pagination.SortDir = "desc"
	}

	filter := &domainActivity.Filter{
		UserID: params.UserID,
	}

	if params.ActivityType != nil && *params.ActivityType != "" {
		actType := domainActivity.ActivityType(*params.ActivityType)
		filter.ActivityType = &actType
	}

	logs, total, err := s.activityRepo.FindAll(ctx, filter, pagination)
	if err != nil {
		return nil, err
	}

	dtos := make([]ListDTO, len(logs))
	for i, log := range logs {
		dtos[i] = ListDTO{
			ID:           log.ID,
			UserID:       log.UserID,
			ActivityType: string(log.ActivityType),
			IPAddress:    log.IPAddress,
			UserAgent:    log.UserAgent,
			DeviceType:   log.DeviceType,
			Browser:      log.Browser,
			Platform:     log.Platform,
			Description:  log.Description,
			CreatedAt:    log.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		}
	}

	totalPages := int(total) / pagination.PerPage
	if int(total)%pagination.PerPage > 0 {
		totalPages++
	}

	from := (pagination.Page-1)*pagination.PerPage + 1
	to := from + len(dtos) - 1
	if len(dtos) == 0 {
		from = 0
		to = 0
	}

	return &PaginatedResult{
		Data: dtos,
		Meta: Meta{
			CurrentPage: pagination.Page,
			PerPage:     pagination.PerPage,
			Total:       total,
			TotalPages:  totalPages,
			From:        from,
			To:          to,
		},
	}, nil
}

func (s *Service) GetByID(ctx context.Context, id uint64) (*ListDTO, error) {
	log, err := s.activityRepo.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}

	return &ListDTO{
		ID:           log.ID,
		UserID:       log.UserID,
		ActivityType: string(log.ActivityType),
		IPAddress:    log.IPAddress,
		UserAgent:    log.UserAgent,
		DeviceType:   log.DeviceType,
		Browser:      log.Browser,
		Platform:     log.Platform,
		Description:  log.Description,
		CreatedAt:    log.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}, nil
}

func (s *Service) GetUserStats(ctx context.Context, userID uint64) (*domainActivity.UserStats, error) {
	return s.activityRepo.GetUserStats(ctx, userID)
}

func (s *Service) GetStats(ctx context.Context) (*domainActivity.Stats, error) {
	return s.activityRepo.GetStats(ctx, &domainActivity.StatsFilter{})
}
