package role

import (
	"context"
)

type Repository interface {
	Create(ctx context.Context, role *Role) error
	Update(ctx context.Context, role *Role) error
	Delete(ctx context.Context, id uint64) error
	FindByID(ctx context.Context, id uint64) (*Role, error)
	FindByIDWithPermissions(ctx context.Context, id uint64) (*Role, error)
	FindByName(ctx context.Context, name string) (*Role, error)
	FindAll(ctx context.Context) ([]*Role, error)
	FindAllWithCounts(ctx context.Context) ([]*Role, error)
	SyncPermissions(ctx context.Context, roleID uint64, permissionIDs []uint64) error
	GetPermissions(ctx context.Context, roleID uint64) ([]Permission, error)
	GetUserCount(ctx context.Context, roleID uint64) (int64, error)
	HasUsers(ctx context.Context, roleID uint64) (bool, error)
}

type PermissionRepository interface {
	Create(ctx context.Context, permission *Permission) error
	FindByID(ctx context.Context, id uint64) (*Permission, error)
	FindByName(ctx context.Context, name string) (*Permission, error)
	FindAll(ctx context.Context) ([]Permission, error)
	FindAllGrouped(ctx context.Context) ([]PermissionGroup, error)
	FindByIDs(ctx context.Context, ids []uint64) ([]Permission, error)
	CreateMany(ctx context.Context, permissions []Permission) error
}
