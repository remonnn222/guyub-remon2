package role

import (
	"context"
	"errors"

	"guyub/internal/domain/role"
)

var (
	ErrRoleNotFound     = errors.New("role not found")
	ErrRoleNameExists   = errors.New("role name already exists")
	ErrSystemRole       = errors.New("cannot delete system role")
	ErrRoleHasUsers     = errors.New("cannot delete role with assigned users")
)

type Service struct {
	roleRepo       role.Repository
	permissionRepo role.PermissionRepository
}

func NewService(roleRepo role.Repository, permissionRepo role.PermissionRepository) *Service {
	return &Service{
		roleRepo:       roleRepo,
		permissionRepo: permissionRepo,
	}
}

// DTOs
type CreateRoleRequest struct {
	Name          string   `json:"name" validate:"required,min=2,max=255"`
	Description   *string  `json:"description,omitempty"`
	Level         int      `json:"level"`
	PermissionIDs []uint64 `json:"permission_ids,omitempty"`
}

type UpdateRoleRequest struct {
	Name          string   `json:"name" validate:"required,min=2,max=255"`
	Description   *string  `json:"description,omitempty"`
	Level         int      `json:"level"`
	PermissionIDs []uint64 `json:"permission_ids,omitempty"`
}

type RoleResponse struct {
	ID               uint64               `json:"id"`
	Name             string               `json:"name"`
	GuardName        string               `json:"guard_name"`
	Description      *string              `json:"description,omitempty"`
	Level            int                  `json:"level"`
	IsSystem         bool                 `json:"is_system"`
	PermissionsCount int                  `json:"permissions_count"`
	UsersCount       int                  `json:"users_count"`
	Permissions      []PermissionResponse `json:"permissions,omitempty"`
	CreatedAt        string               `json:"created_at"`
	UpdatedAt        string               `json:"updated_at"`
}

type PermissionResponse struct {
	ID        uint64 `json:"id"`
	Name      string `json:"name"`
	GuardName string `json:"guard_name"`
}

type PermissionGroupResponse struct {
	Module      string               `json:"module"`
	Permissions []PermissionResponse `json:"permissions"`
}

func (s *Service) Create(ctx context.Context, req *CreateRoleRequest) (*RoleResponse, error) {
	// Check if name exists
	existing, err := s.roleRepo.FindByName(ctx, req.Name)
	if err != nil {
		return nil, err
	}
	if existing != nil {
		return nil, ErrRoleNameExists
	}

	r := &role.Role{
		Name:        req.Name,
		GuardName:   "web",
		Description: req.Description,
		Level:       req.Level,
	}

	if err := s.roleRepo.Create(ctx, r); err != nil {
		return nil, err
	}

	// Sync permissions
	if len(req.PermissionIDs) > 0 {
		if err := s.roleRepo.SyncPermissions(ctx, r.ID, req.PermissionIDs); err != nil {
			return nil, err
		}
	}

	// Reload with permissions
	r, _ = s.roleRepo.FindByIDWithPermissions(ctx, r.ID)

	return s.toResponse(r), nil
}

func (s *Service) Update(ctx context.Context, id uint64, req *UpdateRoleRequest) (*RoleResponse, error) {
	r, err := s.roleRepo.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if r == nil {
		return nil, ErrRoleNotFound
	}

	// Check if name exists (excluding current role)
	if r.Name != req.Name {
		existing, err := s.roleRepo.FindByName(ctx, req.Name)
		if err != nil {
			return nil, err
		}
		if existing != nil {
			return nil, ErrRoleNameExists
		}
	}

	r.Name = req.Name
	r.Description = req.Description
	r.Level = req.Level

	if err := s.roleRepo.Update(ctx, r); err != nil {
		return nil, err
	}

	// Sync permissions
	if req.PermissionIDs != nil {
		if err := s.roleRepo.SyncPermissions(ctx, r.ID, req.PermissionIDs); err != nil {
			return nil, err
		}
	}

	// Reload with permissions
	r, _ = s.roleRepo.FindByIDWithPermissions(ctx, r.ID)

	return s.toResponse(r), nil
}

func (s *Service) Delete(ctx context.Context, id uint64) error {
	r, err := s.roleRepo.FindByID(ctx, id)
	if err != nil {
		return err
	}
	if r == nil {
		return ErrRoleNotFound
	}

	// Check if system role
	if r.IsSystemRole() {
		return ErrSystemRole
	}

	// Check if role has users
	hasUsers, err := s.roleRepo.HasUsers(ctx, id)
	if err != nil {
		return err
	}
	if hasUsers {
		return ErrRoleHasUsers
	}

	return s.roleRepo.Delete(ctx, id)
}

func (s *Service) FindByID(ctx context.Context, id uint64) (*RoleResponse, error) {
	r, err := s.roleRepo.FindByIDWithPermissions(ctx, id)
	if err != nil {
		return nil, err
	}
	if r == nil {
		return nil, ErrRoleNotFound
	}
	return s.toResponse(r), nil
}

func (s *Service) FindAll(ctx context.Context) ([]*RoleResponse, error) {
	roles, err := s.roleRepo.FindAllWithCounts(ctx)
	if err != nil {
		return nil, err
	}

	result := make([]*RoleResponse, len(roles))
	for i, r := range roles {
		result[i] = s.toResponse(r)
	}

	return result, nil
}

func (s *Service) SyncPermissions(ctx context.Context, roleID uint64, permissionIDs []uint64) error {
	r, err := s.roleRepo.FindByID(ctx, roleID)
	if err != nil {
		return err
	}
	if r == nil {
		return ErrRoleNotFound
	}

	return s.roleRepo.SyncPermissions(ctx, roleID, permissionIDs)
}

// Permission operations
func (s *Service) GetAllPermissions(ctx context.Context) ([]PermissionResponse, error) {
	permissions, err := s.permissionRepo.FindAll(ctx)
	if err != nil {
		return nil, err
	}

	result := make([]PermissionResponse, len(permissions))
	for i, p := range permissions {
		result[i] = PermissionResponse{
			ID:        p.ID,
			Name:      p.Name,
			GuardName: p.GuardName,
		}
	}

	return result, nil
}

func (s *Service) GetPermissionsGrouped(ctx context.Context) ([]PermissionGroupResponse, error) {
	groups, err := s.permissionRepo.FindAllGrouped(ctx)
	if err != nil {
		return nil, err
	}

	result := make([]PermissionGroupResponse, len(groups))
	for i, g := range groups {
		perms := make([]PermissionResponse, len(g.Permissions))
		for j, p := range g.Permissions {
			perms[j] = PermissionResponse{
				ID:        p.ID,
				Name:      p.Name,
				GuardName: p.GuardName,
			}
		}
		result[i] = PermissionGroupResponse{
			Module:      g.Module,
			Permissions: perms,
		}
	}

	return result, nil
}

// Helper methods
func (s *Service) toResponse(r *role.Role) *RoleResponse {
	resp := &RoleResponse{
		ID:               r.ID,
		Name:             r.Name,
		GuardName:        r.GuardName,
		Description:      r.Description,
		Level:            r.Level,
		IsSystem:         r.IsSystemRole(),
		PermissionsCount: r.PermissionsCount,
		UsersCount:       r.UsersCount,
		CreatedAt:        r.CreatedAt.Format("2006-01-02T15:04:05Z"),
		UpdatedAt:        r.UpdatedAt.Format("2006-01-02T15:04:05Z"),
	}

	if len(r.Permissions) > 0 {
		resp.PermissionsCount = len(r.Permissions)
		resp.Permissions = make([]PermissionResponse, len(r.Permissions))
		for i, p := range r.Permissions {
			resp.Permissions[i] = PermissionResponse{
				ID:        p.ID,
				Name:      p.Name,
				GuardName: p.GuardName,
			}
		}
	}

	return resp
}
