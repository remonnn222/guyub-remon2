package mysql

import (
	"context"
	"errors"

	"guyub/internal/domain/role"

	"gorm.io/gorm"
)

type RoleRepository struct {
	db *gorm.DB
}

func NewRoleRepository(db *gorm.DB) role.Repository {
	return &RoleRepository{db: db}
}

func (r *RoleRepository) Create(ctx context.Context, rl *role.Role) error {
	return r.db.WithContext(ctx).Create(rl).Error
}

func (r *RoleRepository) Update(ctx context.Context, rl *role.Role) error {
	return r.db.WithContext(ctx).Save(rl).Error
}

func (r *RoleRepository) Delete(ctx context.Context, id uint64) error {
	return WithTransaction(r.db, func(tx *gorm.DB) error {
		// Delete role permissions first
		if err := tx.Table("role_has_permissions").Where("role_id = ?", id).Delete(nil).Error; err != nil {
			return err
		}
		// Delete user-role assignments
		if err := tx.Table("model_has_roles").Where("role_id = ?", id).Delete(nil).Error; err != nil {
			return err
		}
		// Delete role
		return tx.Delete(&role.Role{}, id).Error
	})
}

func (r *RoleRepository) FindByID(ctx context.Context, id uint64) (*role.Role, error) {
	var rl role.Role
	err := r.db.WithContext(ctx).First(&rl, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &rl, err
}

func (r *RoleRepository) FindByIDWithPermissions(ctx context.Context, id uint64) (*role.Role, error) {
	var rl role.Role
	err := r.db.WithContext(ctx).Preload("Permissions").First(&rl, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &rl, err
}

func (r *RoleRepository) FindByName(ctx context.Context, name string) (*role.Role, error) {
	var rl role.Role
	err := r.db.WithContext(ctx).Where("name = ?", name).First(&rl).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &rl, err
}

func (r *RoleRepository) FindAll(ctx context.Context) ([]*role.Role, error) {
	var roles []*role.Role
	err := r.db.WithContext(ctx).Order("level DESC, name ASC").Find(&roles).Error
	return roles, err
}

func (r *RoleRepository) FindAllWithCounts(ctx context.Context) ([]*role.Role, error) {
	var roles []*role.Role

	err := r.db.WithContext(ctx).
		Order("level DESC, name ASC").
		Find(&roles).Error

	if err != nil {
		return nil, err
	}

	// Get permission counts
	for _, rl := range roles {
		var permCount int64
		r.db.Table("role_has_permissions").Where("role_id = ?", rl.ID).Count(&permCount)
		rl.PermissionsCount = int(permCount)

		var userCount int64
		r.db.Table("model_has_roles").Where("role_id = ? AND model_type = ?", rl.ID, "User").Count(&userCount)
		rl.UsersCount = int(userCount)
	}

	return roles, nil
}

func (r *RoleRepository) SyncPermissions(ctx context.Context, roleID uint64, permissionIDs []uint64) error {
	return WithTransaction(r.db, func(tx *gorm.DB) error {
		// Remove existing permissions
		if err := tx.Table("role_has_permissions").Where("role_id = ?", roleID).Delete(nil).Error; err != nil {
			return err
		}

		// Add new permissions
		for _, permID := range permissionIDs {
			rhp := role.RoleHasPermission{
				RoleID:       roleID,
				PermissionID: permID,
			}
			if err := tx.Create(&rhp).Error; err != nil {
				return err
			}
		}
		return nil
	})
}

func (r *RoleRepository) GetPermissions(ctx context.Context, roleID uint64) ([]role.Permission, error) {
	var permissions []role.Permission
	err := r.db.WithContext(ctx).Table("permissions").
		Joins("JOIN role_has_permissions ON role_has_permissions.permission_id = permissions.id").
		Where("role_has_permissions.role_id = ?", roleID).
		Find(&permissions).Error
	return permissions, err
}

func (r *RoleRepository) GetUserCount(ctx context.Context, roleID uint64) (int64, error) {
	var count int64
	err := r.db.WithContext(ctx).Table("model_has_roles").
		Where("role_id = ? AND model_type = ?", roleID, "User").
		Count(&count).Error
	return count, err
}

func (r *RoleRepository) HasUsers(ctx context.Context, roleID uint64) (bool, error) {
	count, err := r.GetUserCount(ctx, roleID)
	return count > 0, err
}

// Permission Repository
type PermissionRepository struct {
	db *gorm.DB
}

func NewPermissionRepository(db *gorm.DB) role.PermissionRepository {
	return &PermissionRepository{db: db}
}

func (r *PermissionRepository) Create(ctx context.Context, p *role.Permission) error {
	return r.db.WithContext(ctx).Create(p).Error
}

func (r *PermissionRepository) FindByID(ctx context.Context, id uint64) (*role.Permission, error) {
	var p role.Permission
	err := r.db.WithContext(ctx).First(&p, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &p, err
}

func (r *PermissionRepository) FindByName(ctx context.Context, name string) (*role.Permission, error) {
	var p role.Permission
	err := r.db.WithContext(ctx).Where("name = ?", name).First(&p).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &p, err
}

func (r *PermissionRepository) FindAll(ctx context.Context) ([]role.Permission, error) {
	var permissions []role.Permission
	err := r.db.WithContext(ctx).Order("name ASC").Find(&permissions).Error
	return permissions, err
}

func (r *PermissionRepository) FindAllGrouped(ctx context.Context) ([]role.PermissionGroup, error) {
	permissions, err := r.FindAll(ctx)
	if err != nil {
		return nil, err
	}

	// Group by module
	groupMap := make(map[string][]role.Permission)
	for _, p := range permissions {
		module := p.Module()
		groupMap[module] = append(groupMap[module], p)
	}

	var groups []role.PermissionGroup
	for module, perms := range groupMap {
		groups = append(groups, role.PermissionGroup{
			Module:      module,
			Permissions: perms,
		})
	}

	return groups, nil
}

func (r *PermissionRepository) FindByIDs(ctx context.Context, ids []uint64) ([]role.Permission, error) {
	var permissions []role.Permission
	err := r.db.WithContext(ctx).Where("id IN ?", ids).Find(&permissions).Error
	return permissions, err
}

func (r *PermissionRepository) CreateMany(ctx context.Context, permissions []role.Permission) error {
	return r.db.WithContext(ctx).CreateInBatches(permissions, 100).Error
}
