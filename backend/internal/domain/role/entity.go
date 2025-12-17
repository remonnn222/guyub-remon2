package role

import (
	"time"
)

type Role struct {
	ID               uint64       `gorm:"primaryKey;autoIncrement" json:"id"`
	Name             string       `gorm:"type:varchar(255);not null" json:"name"`
	GuardName        string       `gorm:"type:varchar(255);not null;default:'web'" json:"guard_name"`
	Description      *string      `gorm:"type:text" json:"description,omitempty"`
	Level            int          `gorm:"default:0" json:"level"`
	CreatedAt        time.Time    `gorm:"type:timestamp;default:CURRENT_TIMESTAMP" json:"created_at"`
	UpdatedAt        time.Time    `gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" json:"updated_at"`
	Permissions      []Permission `gorm:"many2many:role_has_permissions" json:"permissions,omitempty"`
	PermissionsCount int          `gorm:"-" json:"permissions_count,omitempty"`
	UsersCount       int          `gorm:"-" json:"users_count,omitempty"`
}

func (Role) TableName() string {
	return "roles"
}

var SystemRoles = []string{"super_admin", "admin"}

func (r *Role) IsSystemRole() bool {
	for _, sr := range SystemRoles {
		if r.Name == sr {
			return true
		}
	}
	return false
}

func (r *Role) HasPermission(permissionName string) bool {
	for _, p := range r.Permissions {
		if p.Name == permissionName {
			return true
		}
	}
	return false
}

func (r *Role) GetPermissionNames() []string {
	names := make([]string, len(r.Permissions))
	for i, p := range r.Permissions {
		names[i] = p.Name
	}
	return names
}

type Permission struct {
	ID        uint64    `gorm:"primaryKey;autoIncrement" json:"id"`
	Name      string    `gorm:"type:varchar(255);not null" json:"name"`
	GuardName string    `gorm:"type:varchar(255);not null;default:'web'" json:"guard_name"`
	CreatedAt time.Time `gorm:"type:timestamp;default:CURRENT_TIMESTAMP" json:"created_at"`
	UpdatedAt time.Time `gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" json:"updated_at"`
}

func (Permission) TableName() string {
	return "permissions"
}

func (p *Permission) Module() string {
	for i, c := range p.Name {
		if c == '.' {
			return p.Name[:i]
		}
	}
	return p.Name
}

func (p *Permission) Action() string {
	for i, c := range p.Name {
		if c == '.' {
			if i+1 < len(p.Name) {
				return p.Name[i+1:]
			}
			return ""
		}
	}
	return ""
}

type PermissionGroup struct {
	Module      string       `json:"module"`
	Permissions []Permission `json:"permissions"`
}

type ModelHasRole struct {
	RoleID    uint64 `gorm:"primaryKey" json:"role_id"`
	ModelType string `gorm:"primaryKey;type:varchar(255)" json:"model_type"`
	ModelID   uint64 `gorm:"primaryKey" json:"model_id"`
}

func (ModelHasRole) TableName() string {
	return "model_has_roles"
}

type RoleHasPermission struct {
	PermissionID uint64 `gorm:"primaryKey" json:"permission_id"`
	RoleID       uint64 `gorm:"primaryKey" json:"role_id"`
}

func (RoleHasPermission) TableName() string {
	return "role_has_permissions"
}
