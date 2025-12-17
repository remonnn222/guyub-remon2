package user

import (
	"context"
	"errors"
	"strings"

	"guyub/internal/domain/audit"
	"guyub/internal/domain/user"
	infraAuth "guyub/internal/infrastructure/auth"
)

var (
	ErrUserNotFound      = errors.New("user not found")
	ErrEmailExists       = errors.New("email already exists")
	ErrInvalidEmail      = errors.New("invalid email format")
	ErrInvalidPhone      = errors.New("invalid phone format")
	ErrCannotDeleteSelf  = errors.New("cannot delete your own account")
	ErrInvalidPassword   = errors.New("password does not meet requirements")
)

type Service struct {
	userRepo        user.Repository
	auditRepo       audit.Repository
	passwordService *infraAuth.PasswordService
}

func NewService(
	userRepo user.Repository,
	auditRepo audit.Repository,
	passwordService *infraAuth.PasswordService,
) *Service {
	return &Service{
		userRepo:        userRepo,
		auditRepo:       auditRepo,
		passwordService: passwordService,
	}
}

// DTOs
type CreateUserRequest struct {
	Name     string   `json:"name" validate:"required,min=2,max=255"`
	Email    string   `json:"email" validate:"required,email"`
	Phone    *string  `json:"phone,omitempty"`
	Password string   `json:"password" validate:"required,min=8"`
	Type     string   `json:"type" validate:"required,oneof=internal customer agent"`
	Status   string   `json:"status,omitempty"`
	RoleIDs  []uint64 `json:"role_ids,omitempty"`
}

type UpdateUserRequest struct {
	Name     string   `json:"name" validate:"required,min=2,max=255"`
	Email    string   `json:"email" validate:"required,email"`
	Phone    *string  `json:"phone,omitempty"`
	Password *string  `json:"password,omitempty"`
	Type     string   `json:"type" validate:"required,oneof=internal customer agent"`
	Status   string   `json:"status" validate:"required,oneof=active inactive suspended"`
	RoleIDs  []uint64 `json:"role_ids,omitempty"`
}

type UserResponse struct {
	ID          uint64       `json:"id"`
	Name        string       `json:"name"`
	Email       string       `json:"email"`
	Phone       *string      `json:"phone,omitempty"`
	Status      StatusValue  `json:"status"`
	Type        TypeValue    `json:"type"`
	LastLoginAt *string      `json:"last_login_at,omitempty"`
	LastLoginIP *string      `json:"last_login_ip,omitempty"`
	CreatedAt   string       `json:"created_at"`
	UpdatedAt   string       `json:"updated_at"`
	Roles       []RoleValue  `json:"roles,omitempty"`
}

type StatusValue struct {
	Value string `json:"value"`
	Label string `json:"label"`
}

type TypeValue struct {
	Value string `json:"value"`
	Label string `json:"label"`
}

type RoleValue struct {
	ID   uint64 `json:"id"`
	Name string `json:"name"`
}

type ListUsersRequest struct {
	Page        int     `json:"page"`
	PerPage     int     `json:"per_page"`
	Search      string  `json:"search"`
	Status      *string `json:"status"`
	Type        *string `json:"type"`
	RoleID      *uint64 `json:"role_id"`
	SortBy      string  `json:"sort_by"`
	SortDir     string  `json:"sort_dir"`
	WithTrashed bool    `json:"with_trashed"`
	OnlyTrashed bool    `json:"only_trashed"`
}

type ListUsersResponse struct {
	Data  []*UserResponse `json:"data"`
	Meta  *PaginationMeta `json:"meta"`
}

type PaginationMeta struct {
	CurrentPage int   `json:"current_page"`
	From        int   `json:"from"`
	LastPage    int   `json:"last_page"`
	PerPage     int   `json:"per_page"`
	To          int   `json:"to"`
	Total       int64 `json:"total"`
}

func (s *Service) Create(ctx context.Context, req *CreateUserRequest, createdBy uint64) (*UserResponse, error) {
	// Validate email format
	if !infraAuth.ValidateEmail(req.Email) {
		return nil, ErrInvalidEmail
	}

	// Validate phone if provided
	if req.Phone != nil && *req.Phone != "" && !infraAuth.ValidatePhone(*req.Phone) {
		return nil, ErrInvalidPhone
	}

	// Validate password
	if err := s.passwordService.Validate(req.Password); err != nil {
		return nil, ErrInvalidPassword
	}

	// Check if email exists
	existing, err := s.userRepo.FindByEmail(ctx, req.Email)
	if err != nil {
		return nil, err
	}
	if existing != nil {
		return nil, ErrEmailExists
	}

	// Hash password
	hashedPassword, err := s.passwordService.Hash(req.Password)
	if err != nil {
		return nil, err
	}

	// Set default status
	status := user.StatusActive
	if req.Status != "" {
		status = user.StatusFromString(req.Status)
	}

	// Create user
	u := &user.User{
		Name:     req.Name,
		Email:    strings.ToLower(req.Email),
		Phone:    req.Phone,
		Password: hashedPassword,
		Type:     user.TypeFromString(req.Type),
		Status:   status,
	}

	if err := s.userRepo.Create(ctx, u); err != nil {
		return nil, err
	}

	// Assign roles
	if len(req.RoleIDs) > 0 {
		if err := s.userRepo.SyncRoles(ctx, u.ID, req.RoleIDs); err != nil {
			return nil, err
		}
	}

	// Reload with roles
	u, _ = s.userRepo.FindByIDWithRoles(ctx, u.ID)

	// Audit log
	s.logAudit(ctx, createdBy, audit.EventCreated, "User", &u.ID, nil, u)

	return s.toResponse(u), nil
}

func (s *Service) Update(ctx context.Context, id uint64, req *UpdateUserRequest, updatedBy uint64) (*UserResponse, error) {
	u, err := s.userRepo.FindByIDWithRoles(ctx, id)
	if err != nil {
		return nil, err
	}
	if u == nil {
		return nil, ErrUserNotFound
	}

	oldUser := *u // Copy for audit

	// Validate email format
	if !infraAuth.ValidateEmail(req.Email) {
		return nil, ErrInvalidEmail
	}

	// Validate phone if provided
	if req.Phone != nil && *req.Phone != "" && !infraAuth.ValidatePhone(*req.Phone) {
		return nil, ErrInvalidPhone
	}

	// Check if email exists (excluding current user)
	if strings.ToLower(req.Email) != strings.ToLower(u.Email) {
		existing, err := s.userRepo.FindByEmail(ctx, req.Email)
		if err != nil {
			return nil, err
		}
		if existing != nil {
			return nil, ErrEmailExists
		}
	}

	// Update fields
	u.Name = req.Name
	u.Email = strings.ToLower(req.Email)
	u.Phone = req.Phone
	u.Type = user.TypeFromString(req.Type)
	u.Status = user.StatusFromString(req.Status)

	// Update password if provided
	if req.Password != nil && *req.Password != "" {
		if err := s.passwordService.Validate(*req.Password); err != nil {
			return nil, ErrInvalidPassword
		}
		hashedPassword, err := s.passwordService.Hash(*req.Password)
		if err != nil {
			return nil, err
		}
		u.Password = hashedPassword
	}

	if err := s.userRepo.Update(ctx, u); err != nil {
		return nil, err
	}

	// Sync roles
	if req.RoleIDs != nil {
		if err := s.userRepo.SyncRoles(ctx, u.ID, req.RoleIDs); err != nil {
			return nil, err
		}
	}

	// Reload with roles
	u, _ = s.userRepo.FindByIDWithRoles(ctx, u.ID)

	// Audit log
	s.logAudit(ctx, updatedBy, audit.EventUpdated, "User", &u.ID, &oldUser, u)

	return s.toResponse(u), nil
}

func (s *Service) Delete(ctx context.Context, id uint64, deletedBy uint64) error {
	if id == deletedBy {
		return ErrCannotDeleteSelf
	}

	u, err := s.userRepo.FindByID(ctx, id)
	if err != nil {
		return err
	}
	if u == nil {
		return ErrUserNotFound
	}

	if err := s.userRepo.Delete(ctx, id); err != nil {
		return err
	}

	// Audit log
	s.logAudit(ctx, deletedBy, audit.EventDeleted, "User", &id, u, nil)

	return nil
}

func (s *Service) Restore(ctx context.Context, id uint64, restoredBy uint64) error {
	if err := s.userRepo.Restore(ctx, id); err != nil {
		return err
	}

	// Audit log
	s.logAudit(ctx, restoredBy, audit.EventRestored, "User", &id, nil, nil)

	return nil
}

func (s *Service) ForceDelete(ctx context.Context, id uint64, deletedBy uint64) error {
	if id == deletedBy {
		return ErrCannotDeleteSelf
	}

	u, err := s.userRepo.FindByID(ctx, id)
	if err != nil {
		return err
	}
	if u == nil {
		return ErrUserNotFound
	}

	if err := s.userRepo.ForceDelete(ctx, id); err != nil {
		return err
	}

	// Audit log
	s.logAudit(ctx, deletedBy, audit.EventDeleted, "User", &id, u, nil)

	return nil
}

func (s *Service) FindByID(ctx context.Context, id uint64) (*UserResponse, error) {
	u, err := s.userRepo.FindByIDWithRoles(ctx, id)
	if err != nil {
		return nil, err
	}
	if u == nil {
		return nil, ErrUserNotFound
	}
	return s.toResponse(u), nil
}

func (s *Service) List(ctx context.Context, req *ListUsersRequest) (*ListUsersResponse, error) {
	// Build filter
	filter := &user.Filter{
		Search:      req.Search,
		WithTrashed: req.WithTrashed,
		OnlyTrashed: req.OnlyTrashed,
	}

	if req.Status != nil {
		status := user.StatusFromString(*req.Status)
		filter.Status = &status
	}

	if req.Type != nil {
		userType := user.TypeFromString(*req.Type)
		filter.Type = &userType
	}

	if req.RoleID != nil {
		filter.RoleID = req.RoleID
	}

	// Build pagination
	pagination := user.NewPagination()
	if req.Page > 0 {
		pagination.Page = req.Page
	}
	if req.PerPage > 0 {
		pagination.PerPage = req.PerPage
	}
	if req.SortBy != "" {
		pagination.SortBy = req.SortBy
	}
	if req.SortDir != "" {
		pagination.SortDir = req.SortDir
	}

	// Query
	users, total, err := s.userRepo.FindAllWithRoles(ctx, filter, pagination)
	if err != nil {
		return nil, err
	}

	// Convert to response
	data := make([]*UserResponse, len(users))
	for i, u := range users {
		data[i] = s.toResponse(u)
	}

	// Calculate pagination meta
	lastPage := int(total) / pagination.PerPage
	if int(total)%pagination.PerPage > 0 {
		lastPage++
	}

	from := pagination.Offset() + 1
	to := pagination.Offset() + len(users)
	if total == 0 {
		from = 0
		to = 0
	}

	return &ListUsersResponse{
		Data: data,
		Meta: &PaginationMeta{
			CurrentPage: pagination.Page,
			From:        from,
			LastPage:    lastPage,
			PerPage:     pagination.PerPage,
			To:          to,
			Total:       total,
		},
	}, nil
}

// Bulk operations
type BulkDeleteRequest struct {
	IDs []uint64 `json:"ids" validate:"required,min=1"`
}

func (s *Service) BulkDelete(ctx context.Context, req *BulkDeleteRequest, deletedBy uint64) error {
	// Filter out current user
	var ids []uint64
	for _, id := range req.IDs {
		if id != deletedBy {
			ids = append(ids, id)
		}
	}

	if len(ids) == 0 {
		return nil
	}

	return s.userRepo.BulkDelete(ctx, ids)
}

func (s *Service) BulkRestore(ctx context.Context, ids []uint64) error {
	return s.userRepo.BulkRestore(ctx, ids)
}

type BulkAssignRoleRequest struct {
	UserIDs []uint64 `json:"user_ids" validate:"required,min=1"`
	RoleID  uint64   `json:"role_id" validate:"required"`
}

func (s *Service) BulkAssignRole(ctx context.Context, req *BulkAssignRoleRequest) error {
	return s.userRepo.BulkAssignRole(ctx, req.UserIDs, req.RoleID)
}

// Helper methods
func (s *Service) toResponse(u *user.User) *UserResponse {
	resp := &UserResponse{
		ID:    u.ID,
		Name:  u.Name,
		Email: u.Email,
		Phone: u.Phone,
		Status: StatusValue{
			Value: u.Status.String(),
			Label: u.Status.Label(),
		},
		Type: TypeValue{
			Value: u.Type.String(),
			Label: u.Type.Label(),
		},
		CreatedAt: u.CreatedAt.Format("2006-01-02T15:04:05Z"),
		UpdatedAt: u.UpdatedAt.Format("2006-01-02T15:04:05Z"),
	}

	if u.LastLoginAt != nil {
		t := u.LastLoginAt.Format("2006-01-02T15:04:05Z")
		resp.LastLoginAt = &t
	}

	if u.LastLoginIP != nil {
		resp.LastLoginIP = u.LastLoginIP
	}

	if len(u.Roles) > 0 {
		resp.Roles = make([]RoleValue, len(u.Roles))
		for i, r := range u.Roles {
			resp.Roles[i] = RoleValue{
				ID:   r.ID,
				Name: r.Name,
			}
		}
	}

	return resp
}

func (s *Service) logAudit(ctx context.Context, userID uint64, event audit.Event, entityType string, entityID *uint64, oldValues, newValues interface{}) {
	// Implementation would serialize old/new values to JSON and create audit log
	// Simplified for brevity
}
