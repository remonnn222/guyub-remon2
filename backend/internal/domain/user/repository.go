package user

import (
	"context"
)

// Repository defines the interface for user data access
type Repository interface {
	// CRUD operations
	Create(ctx context.Context, user *User) error
	Update(ctx context.Context, user *User) error
	Delete(ctx context.Context, id uint64) error
	ForceDelete(ctx context.Context, id uint64) error
	Restore(ctx context.Context, id uint64) error

	// Query operations
	FindByID(ctx context.Context, id uint64) (*User, error)
	FindByIDWithRoles(ctx context.Context, id uint64) (*User, error)
	FindByEmail(ctx context.Context, email string) (*User, error)
	FindByEmailWithRoles(ctx context.Context, email string) (*User, error)
	FindAll(ctx context.Context, filter *Filter, pagination *Pagination) ([]*User, int64, error)
	FindAllWithRoles(ctx context.Context, filter *Filter, pagination *Pagination) ([]*User, int64, error)

	// Bulk operations
	BulkDelete(ctx context.Context, ids []uint64) error
	BulkRestore(ctx context.Context, ids []uint64) error
	BulkAssignRole(ctx context.Context, userIDs []uint64, roleID uint64) error

	// Role management
	AssignRoles(ctx context.Context, userID uint64, roleIDs []uint64) error
	SyncRoles(ctx context.Context, userID uint64, roleIDs []uint64) error
	RemoveRole(ctx context.Context, userID uint64, roleID uint64) error
	GetRoles(ctx context.Context, userID uint64) ([]Role, error)

	// Permission management
	GetPermissions(ctx context.Context, userID uint64) ([]Permission, error)
	GetAllPermissions(ctx context.Context, userID uint64) ([]string, error) // Including role permissions

	// Statistics
	Count(ctx context.Context, filter *Filter) (int64, error)
	CountByStatus(ctx context.Context) (map[Status]int64, error)
	CountByType(ctx context.Context) (map[Type]int64, error)

	// Token management
	UpdateRememberToken(ctx context.Context, userID uint64, token string) error
	UpdateLastLogin(ctx context.Context, userID uint64, ip string) error

	// 2FA management
	Update2FA(ctx context.Context, userID uint64, secret string, recoveryCodes string) error
	Confirm2FA(ctx context.Context, userID uint64) error
	Disable2FA(ctx context.Context, userID uint64) error
}

// Filter for querying users
type Filter struct {
	Search    string
	Status    *Status
	Type      *Type
	RoleID    *uint64
	WithTrashed bool
	OnlyTrashed bool
}

// Pagination for list queries
type Pagination struct {
	Page    int
	PerPage int
	SortBy  string
	SortDir string
}

func (p *Pagination) Offset() int {
	return (p.Page - 1) * p.PerPage
}

func (p *Pagination) Limit() int {
	return p.PerPage
}

func NewPagination() *Pagination {
	return &Pagination{
		Page:    1,
		PerPage: 15,
		SortBy:  "created_at",
		SortDir: "desc",
	}
}
