package mysql

import (
	"context"
	"errors"
	"strings"
	"time"

	"guyub/internal/domain/user"

	"gorm.io/gorm"
)

type UserRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) user.Repository {
	return &UserRepository{db: db}
}

func (r *UserRepository) Create(ctx context.Context, u *user.User) error {
	// Omit Roles to prevent GORM from auto-managing the polymorphic join table
	// Roles are handled separately via SyncRoles which properly includes model_type
	return r.db.WithContext(ctx).Omit("Roles").Create(u).Error
}

func (r *UserRepository) Update(ctx context.Context, u *user.User) error {
	// Omit Roles to prevent GORM from auto-managing the polymorphic join table
	// Roles are handled separately via SyncRoles which properly includes model_type
	return r.db.WithContext(ctx).Omit("Roles").Save(u).Error
}

func (r *UserRepository) Delete(ctx context.Context, id uint64) error {
	return r.db.WithContext(ctx).Delete(&user.User{}, id).Error
}

func (r *UserRepository) ForceDelete(ctx context.Context, id uint64) error {
	return r.db.WithContext(ctx).Unscoped().Delete(&user.User{}, id).Error
}

func (r *UserRepository) Restore(ctx context.Context, id uint64) error {
	return r.db.WithContext(ctx).Unscoped().Model(&user.User{}).Where("id = ?", id).Update("deleted_at", nil).Error
}

func (r *UserRepository) FindByID(ctx context.Context, id uint64) (*user.User, error) {
	var u user.User
	err := r.db.WithContext(ctx).First(&u, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &u, err
}

func (r *UserRepository) FindByIDWithRoles(ctx context.Context, id uint64) (*user.User, error) {
	var u user.User
	err := r.db.WithContext(ctx).Preload("Roles").First(&u, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &u, err
}

func (r *UserRepository) FindByEmail(ctx context.Context, email string) (*user.User, error) {
	var u user.User
	err := r.db.WithContext(ctx).Where("LOWER(email) = LOWER(?)", email).First(&u).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &u, err
}

func (r *UserRepository) FindByEmailWithRoles(ctx context.Context, email string) (*user.User, error) {
	var u user.User
	err := r.db.WithContext(ctx).Preload("Roles").Where("LOWER(email) = LOWER(?)", email).First(&u).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &u, err
}

func (r *UserRepository) FindAll(ctx context.Context, filter *user.Filter, pagination *user.Pagination) ([]*user.User, int64, error) {
	var users []*user.User
	var total int64

	query := r.db.WithContext(ctx).Model(&user.User{})
	query = r.applyFilter(query, filter)

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	query = r.applySorting(query, pagination)
	query = query.Offset(pagination.Offset()).Limit(pagination.Limit())

	if err := query.Find(&users).Error; err != nil {
		return nil, 0, err
	}

	return users, total, nil
}

func (r *UserRepository) FindAllWithRoles(ctx context.Context, filter *user.Filter, pagination *user.Pagination) ([]*user.User, int64, error) {
	var users []*user.User
	var total int64

	query := r.db.WithContext(ctx).Model(&user.User{})
	query = r.applyFilter(query, filter)

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	query = r.applySorting(query, pagination)
	query = query.Offset(pagination.Offset()).Limit(pagination.Limit())
	query = query.Preload("Roles")

	if err := query.Find(&users).Error; err != nil {
		return nil, 0, err
	}

	return users, total, nil
}

func (r *UserRepository) applyFilter(query *gorm.DB, filter *user.Filter) *gorm.DB {
	if filter == nil {
		return query
	}

	if filter.Search != "" {
		search := "%" + strings.ToLower(filter.Search) + "%"
		query = query.Where("LOWER(name) LIKE ? OR LOWER(email) LIKE ?", search, search)
	}

	if filter.Status != nil {
		query = query.Where("status = ?", *filter.Status)
	}

	if filter.Type != nil {
		query = query.Where("type = ?", *filter.Type)
	}

	if filter.RoleID != nil {
		query = query.Joins("JOIN model_has_roles ON model_has_roles.model_id = users.id AND model_has_roles.model_type = 'User'").
			Where("model_has_roles.role_id = ?", *filter.RoleID)
	}

	if filter.OnlyTrashed {
		query = query.Unscoped().Where("deleted_at IS NOT NULL")
	} else if filter.WithTrashed {
		query = query.Unscoped()
	}

	return query
}

func (r *UserRepository) applySorting(query *gorm.DB, pagination *user.Pagination) *gorm.DB {
	if pagination == nil {
		return query.Order("created_at DESC")
	}

	sortBy := pagination.SortBy
	if sortBy == "" {
		sortBy = "created_at"
	}

	sortDir := strings.ToUpper(pagination.SortDir)
	if sortDir != "ASC" && sortDir != "DESC" {
		sortDir = "DESC"
	}

	return query.Order(sortBy + " " + sortDir)
}

// Bulk operations
func (r *UserRepository) BulkDelete(ctx context.Context, ids []uint64) error {
	return r.db.WithContext(ctx).Delete(&user.User{}, ids).Error
}

func (r *UserRepository) BulkRestore(ctx context.Context, ids []uint64) error {
	return r.db.WithContext(ctx).Unscoped().Model(&user.User{}).Where("id IN ?", ids).Update("deleted_at", nil).Error
}

func (r *UserRepository) BulkAssignRole(ctx context.Context, userIDs []uint64, roleID uint64) error {
	return WithTransaction(r.db, func(tx *gorm.DB) error {
		for _, userID := range userIDs {
			mhr := map[string]interface{}{
				"role_id":    roleID,
				"model_type": "User",
				"model_id":   userID,
			}
			if err := tx.Table("model_has_roles").Create(mhr).Error; err != nil {
				if !strings.Contains(err.Error(), "Duplicate") {
					return err
				}
			}
		}
		return nil
	})
}

// Role management
func (r *UserRepository) AssignRoles(ctx context.Context, userID uint64, roleIDs []uint64) error {
	return WithTransaction(r.db, func(tx *gorm.DB) error {
		for _, roleID := range roleIDs {
			mhr := map[string]interface{}{
				"role_id":    roleID,
				"model_type": "User",
				"model_id":   userID,
			}
			if err := tx.Table("model_has_roles").Create(mhr).Error; err != nil {
				if !strings.Contains(err.Error(), "Duplicate") {
					return err
				}
			}
		}
		return nil
	})
}

func (r *UserRepository) SyncRoles(ctx context.Context, userID uint64, roleIDs []uint64) error {
	return WithTransaction(r.db, func(tx *gorm.DB) error {
		// Remove existing roles
		if err := tx.Table("model_has_roles").Where("model_id = ? AND model_type = ?", userID, "User").Delete(nil).Error; err != nil {
			return err
		}

		// Add new roles
		for _, roleID := range roleIDs {
			mhr := map[string]interface{}{
				"role_id":    roleID,
				"model_type": "User",
				"model_id":   userID,
			}
			if err := tx.Table("model_has_roles").Create(mhr).Error; err != nil {
				return err
			}
		}
		return nil
	})
}

func (r *UserRepository) RemoveRole(ctx context.Context, userID uint64, roleID uint64) error {
	return r.db.WithContext(ctx).Table("model_has_roles").
		Where("model_id = ? AND model_type = ? AND role_id = ?", userID, "User", roleID).
		Delete(nil).Error
}

func (r *UserRepository) GetRoles(ctx context.Context, userID uint64) ([]user.Role, error) {
	var roles []user.Role
	err := r.db.WithContext(ctx).Table("roles").
		Joins("JOIN model_has_roles ON model_has_roles.role_id = roles.id").
		Where("model_has_roles.model_id = ? AND model_has_roles.model_type = ?", userID, "User").
		Find(&roles).Error
	return roles, err
}

func (r *UserRepository) GetPermissions(ctx context.Context, userID uint64) ([]user.Permission, error) {
	var permissions []user.Permission
	err := r.db.WithContext(ctx).Table("permissions").
		Joins("JOIN model_has_permissions ON model_has_permissions.permission_id = permissions.id").
		Where("model_has_permissions.model_id = ? AND model_has_permissions.model_type = ?", userID, "User").
		Find(&permissions).Error
	return permissions, err
}

func (r *UserRepository) GetAllPermissions(ctx context.Context, userID uint64) ([]string, error) {
	var permissions []string

	// Direct permissions
	var directPerms []string
	r.db.WithContext(ctx).Table("permissions").
		Select("permissions.name").
		Joins("JOIN model_has_permissions ON model_has_permissions.permission_id = permissions.id").
		Where("model_has_permissions.model_id = ? AND model_has_permissions.model_type = ?", userID, "User").
		Pluck("name", &directPerms)

	// Role permissions
	var rolePerms []string
	r.db.WithContext(ctx).Table("permissions").
		Select("DISTINCT permissions.name").
		Joins("JOIN role_has_permissions ON role_has_permissions.permission_id = permissions.id").
		Joins("JOIN model_has_roles ON model_has_roles.role_id = role_has_permissions.role_id").
		Where("model_has_roles.model_id = ? AND model_has_roles.model_type = ?", userID, "User").
		Pluck("name", &rolePerms)

	// Merge and deduplicate
	permMap := make(map[string]bool)
	for _, p := range directPerms {
		permMap[p] = true
	}
	for _, p := range rolePerms {
		permMap[p] = true
	}

	for p := range permMap {
		permissions = append(permissions, p)
	}

	return permissions, nil
}

// Statistics
func (r *UserRepository) Count(ctx context.Context, filter *user.Filter) (int64, error) {
	var count int64
	query := r.db.WithContext(ctx).Model(&user.User{})
	query = r.applyFilter(query, filter)
	return count, query.Count(&count).Error
}

func (r *UserRepository) CountByStatus(ctx context.Context) (map[user.Status]int64, error) {
	result := make(map[user.Status]int64)
	var counts []struct {
		Status user.Status
		Count  int64
	}

	err := r.db.WithContext(ctx).Model(&user.User{}).
		Select("status, COUNT(*) as count").
		Group("status").
		Scan(&counts).Error

	if err != nil {
		return nil, err
	}

	for _, c := range counts {
		result[c.Status] = c.Count
	}

	return result, nil
}

func (r *UserRepository) CountByType(ctx context.Context) (map[user.Type]int64, error) {
	result := make(map[user.Type]int64)
	var counts []struct {
		Type  user.Type
		Count int64
	}

	err := r.db.WithContext(ctx).Model(&user.User{}).
		Select("type, COUNT(*) as count").
		Group("type").
		Scan(&counts).Error

	if err != nil {
		return nil, err
	}

	for _, c := range counts {
		result[c.Type] = c.Count
	}

	return result, nil
}

// Token management
func (r *UserRepository) UpdateRememberToken(ctx context.Context, userID uint64, token string) error {
	return r.db.WithContext(ctx).Model(&user.User{}).Where("id = ?", userID).Update("remember_token", token).Error
}

func (r *UserRepository) UpdateLastLogin(ctx context.Context, userID uint64, ip string) error {
	now := time.Now()
	return r.db.WithContext(ctx).Model(&user.User{}).Where("id = ?", userID).Updates(map[string]interface{}{
		"last_login_at": now,
		"last_login_ip": ip,
	}).Error
}

// 2FA management
func (r *UserRepository) Update2FA(ctx context.Context, userID uint64, secret string, recoveryCodes string) error {
	return r.db.WithContext(ctx).Model(&user.User{}).Where("id = ?", userID).Updates(map[string]interface{}{
		"two_factor_secret":         secret,
		"two_factor_recovery_codes": recoveryCodes,
	}).Error
}

func (r *UserRepository) Confirm2FA(ctx context.Context, userID uint64) error {
	now := time.Now()
	return r.db.WithContext(ctx).Model(&user.User{}).Where("id = ?", userID).Update("two_factor_confirmed_at", now).Error
}

func (r *UserRepository) Disable2FA(ctx context.Context, userID uint64) error {
	return r.db.WithContext(ctx).Model(&user.User{}).Where("id = ?", userID).Updates(map[string]interface{}{
		"two_factor_secret":         nil,
		"two_factor_recovery_codes": nil,
		"two_factor_confirmed_at":   nil,
	}).Error
}
