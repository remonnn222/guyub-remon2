package audit

import (
	"context"
	"encoding/json"

	domainAudit "guyub/internal/domain/audit"
)

type Service struct {
	auditRepo domainAudit.Repository
}

func NewService(auditRepo domainAudit.Repository) *Service {
	return &Service{
		auditRepo: auditRepo,
	}
}

// ListDTO represents the audit log response
type ListDTO struct {
	ID            uint64                 `json:"id"`
	UserID        *uint64                `json:"user_id,omitempty"`
	UserName      *string                `json:"user_name,omitempty"`
	Event         string                 `json:"event"`
	AuditableType string                 `json:"auditable_type"`
	AuditableID   *uint64                `json:"auditable_id,omitempty"`
	OldValues     map[string]interface{} `json:"old_values,omitempty"`
	NewValues     map[string]interface{} `json:"new_values,omitempty"`
	Description   *string                `json:"description,omitempty"`
	IPAddress     *string                `json:"ip_address,omitempty"`
	UserAgent     *string                `json:"user_agent,omitempty"`
	URL           *string                `json:"url,omitempty"`
	HTTPMethod    *string                `json:"http_method,omitempty"`
	SecurityLevel string                 `json:"security_level"`
	CreatedAt     string                 `json:"created_at"`
}

// PaginatedResult represents paginated audit logs
type PaginatedResult struct {
	Data []ListDTO `json:"data"`
	Meta Meta      `json:"meta"`
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
	Page          int
	PerPage       int
	SortBy        string
	SortOrder     string
	UserID        *uint64
	Event         *string
	AuditableType *string
	Search        string
}

func (s *Service) List(ctx context.Context, params ListParams) (*PaginatedResult, error) {
	pagination := &domainAudit.Pagination{
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

	filter := &domainAudit.Filter{
		UserID:        params.UserID,
		AuditableType: params.AuditableType,
		Search:        params.Search,
	}

	if params.Event != nil && *params.Event != "" {
		event := domainAudit.Event(*params.Event)
		filter.Event = &event
	}

	logs, total, err := s.auditRepo.FindAll(ctx, filter, pagination)
	if err != nil {
		return nil, err
	}

	dtos := make([]ListDTO, len(logs))
	for i, log := range logs {
		dto := ListDTO{
			ID:            log.ID,
			UserID:        log.UserID,
			UserName:      log.UserName,
			Event:         string(log.Event),
			AuditableType: log.AuditableType,
			AuditableID:   log.AuditableID,
			Description:   log.Description,
			IPAddress:     log.IPAddress,
			UserAgent:     log.UserAgent,
			URL:           log.URL,
			HTTPMethod:    log.HTTPMethod,
			SecurityLevel: string(log.SecurityLevel),
			CreatedAt:     log.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		}

		// Parse JSON fields
		if log.OldValues != nil {
			var oldValues map[string]interface{}
			if err := json.Unmarshal(log.OldValues, &oldValues); err == nil {
				dto.OldValues = oldValues
			}
		}
		if log.NewValues != nil {
			var newValues map[string]interface{}
			if err := json.Unmarshal(log.NewValues, &newValues); err == nil {
				dto.NewValues = newValues
			}
		}

		dtos[i] = dto
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
	log, err := s.auditRepo.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}

	dto := &ListDTO{
		ID:            log.ID,
		UserID:        log.UserID,
		UserName:      log.UserName,
		Event:         string(log.Event),
		AuditableType: log.AuditableType,
		AuditableID:   log.AuditableID,
		Description:   log.Description,
		IPAddress:     log.IPAddress,
		UserAgent:     log.UserAgent,
		URL:           log.URL,
		HTTPMethod:    log.HTTPMethod,
		SecurityLevel: string(log.SecurityLevel),
		CreatedAt:     log.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}

	// Parse JSON fields
	if log.OldValues != nil {
		var oldValues map[string]interface{}
		if err := json.Unmarshal(log.OldValues, &oldValues); err == nil {
			dto.OldValues = oldValues
		}
	}
	if log.NewValues != nil {
		var newValues map[string]interface{}
		if err := json.Unmarshal(log.NewValues, &newValues); err == nil {
			dto.NewValues = newValues
		}
	}

	return dto, nil
}

func (s *Service) GetStats(ctx context.Context) (*domainAudit.Stats, error) {
	return s.auditRepo.GetStats(ctx, &domainAudit.StatsFilter{})
}

// CreateLogRequest represents the request to create an audit log
type CreateLogRequest struct {
	UserID        *uint64
	UserName      *string
	Event         domainAudit.Event
	AuditableType string
	AuditableID   *uint64
	OldValues     map[string]interface{}
	NewValues     map[string]interface{}
	Description   *string
	IPAddress     *string
	UserAgent     *string
	URL           *string
	HTTPMethod    *string
}

// Create creates a new audit log entry
func (s *Service) Create(ctx context.Context, req *CreateLogRequest) error {
	log := &domainAudit.Log{
		UserID:        req.UserID,
		UserName:      req.UserName,
		Event:         req.Event,
		AuditableType: req.AuditableType,
		AuditableID:   req.AuditableID,
		Description:   req.Description,
		IPAddress:     req.IPAddress,
		UserAgent:     req.UserAgent,
		URL:           req.URL,
		HTTPMethod:    req.HTTPMethod,
		SecurityLevel: domainAudit.GetSecurityLevel(req.Event, req.AuditableType),
	}

	// Filter sensitive data and convert to JSON
	if req.OldValues != nil {
		filtered := domainAudit.FilterSensitiveData(req.OldValues)
		if jsonData, err := json.Marshal(filtered); err == nil {
			log.OldValues = jsonData
		}
	}
	if req.NewValues != nil {
		filtered := domainAudit.FilterSensitiveData(req.NewValues)
		if jsonData, err := json.Marshal(filtered); err == nil {
			log.NewValues = jsonData
		}
	}

	return s.auditRepo.Create(ctx, log)
}

// LogEvent is a convenience method to log events with minimal parameters
func (s *Service) LogEvent(ctx context.Context, userID *uint64, userName *string, event domainAudit.Event, entityType string, entityID *uint64, description string) error {
	desc := description
	return s.Create(ctx, &CreateLogRequest{
		UserID:        userID,
		UserName:      userName,
		Event:         event,
		AuditableType: entityType,
		AuditableID:   entityID,
		Description:   &desc,
	})
}
