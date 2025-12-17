package user

import (
	"encoding/json"
	"time"

	"gorm.io/gorm"
)

type User struct {
	ID                     uint64          `gorm:"primaryKey;autoIncrement" json:"id"`
	Name                   string          `gorm:"type:varchar(255);not null" json:"name"`
	Email                  string          `gorm:"type:varchar(255);not null;uniqueIndex" json:"email"`
	EmailVerifiedAt        *time.Time      `gorm:"type:timestamp" json:"email_verified_at,omitempty"`
	Password               string          `gorm:"type:varchar(255);not null" json:"-"`
	Phone                  *string         `gorm:"type:varchar(20)" json:"phone,omitempty"`
	Status                 Status          `gorm:"type:enum('active','inactive','suspended');default:'active'" json:"status"`
	Type                   Type            `gorm:"type:enum('internal','customer','agent');default:'customer'" json:"type"`
	LastLoginAt            *time.Time      `gorm:"type:timestamp" json:"last_login_at,omitempty"`
	LastLoginIP            *string         `gorm:"type:varchar(45)" json:"last_login_ip,omitempty"`
	Preferences            json.RawMessage `gorm:"type:json" json:"preferences,omitempty"`
	RememberToken          *string         `gorm:"type:varchar(100)" json:"-"`
	TwoFactorSecret        *string         `gorm:"type:text" json:"-"`
	TwoFactorRecoveryCodes *string         `gorm:"type:text" json:"-"`
	TwoFactorConfirmedAt   *time.Time      `gorm:"type:timestamp" json:"two_factor_confirmed_at,omitempty"`
	CreatedAt              time.Time       `gorm:"type:timestamp;default:CURRENT_TIMESTAMP" json:"created_at"`
	UpdatedAt              time.Time       `gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" json:"updated_at"`
	DeletedAt              gorm.DeletedAt  `gorm:"index" json:"deleted_at,omitempty"`

	// Relationships
	Roles       []Role       `gorm:"many2many:model_has_roles;foreignKey:ID;joinForeignKey:model_id;References:ID;joinReferences:role_id" json:"roles,omitempty"`
	Permissions []Permission `gorm:"many2many:model_has_permissions;foreignKey:ID;joinForeignKey:model_id;References:ID;joinReferences:permission_id" json:"permissions,omitempty"`
}

func (User) TableName() string {
	return "users"
}

// Role entity (simplified for user package)
type Role struct {
	ID          uint64    `gorm:"primaryKey" json:"id"`
	Name        string    `gorm:"type:varchar(255);not null" json:"name"`
	GuardName   string    `gorm:"type:varchar(255);not null;default:'web'" json:"guard_name"`
	Description *string   `gorm:"type:text" json:"description,omitempty"`
	Level       int       `gorm:"default:0" json:"level"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

func (Role) TableName() string {
	return "roles"
}

// Permission entity (simplified for user package)
type Permission struct {
	ID        uint64    `gorm:"primaryKey" json:"id"`
	Name      string    `gorm:"type:varchar(255);not null" json:"name"`
	GuardName string    `gorm:"type:varchar(255);not null;default:'web'" json:"guard_name"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

func (Permission) TableName() string {
	return "permissions"
}

// Business logic methods
func (u *User) CanLogin() bool {
	return u.Status == StatusActive
}

func (u *User) HasRole(roleName string) bool {
	for _, role := range u.Roles {
		if role.Name == roleName {
			return true
		}
	}
	return false
}

func (u *User) HasAnyRole(roleNames []string) bool {
	for _, roleName := range roleNames {
		if u.HasRole(roleName) {
			return true
		}
	}
	return false
}

func (u *User) IsSuperAdmin() bool {
	return u.HasRole("super_admin")
}

func (u *User) HasPermission(permissionName string) bool {
	// Super admin bypasses all checks
	if u.IsSuperAdmin() {
		return true
	}

	// Check direct permissions
	for _, perm := range u.Permissions {
		if perm.Name == permissionName {
			return true
		}
	}

	// Check role permissions
	for _, role := range u.Roles {
		for _, perm := range u.Permissions {
			if perm.Name == permissionName {
				return true
			}
		}
		_ = role // Role permissions should be loaded separately
	}

	return false
}

func (u *User) GetRoleNames() []string {
	names := make([]string, len(u.Roles))
	for i, role := range u.Roles {
		names[i] = role.Name
	}
	return names
}

func (u *User) GetPermissionNames() []string {
	names := make([]string, len(u.Permissions))
	for i, perm := range u.Permissions {
		names[i] = perm.Name
	}
	return names
}

func (u *User) UpdateLastLogin(ip string) {
	now := time.Now()
	u.LastLoginAt = &now
	u.LastLoginIP = &ip
}

func (u *User) Has2FAEnabled() bool {
	return u.TwoFactorConfirmedAt != nil
}
