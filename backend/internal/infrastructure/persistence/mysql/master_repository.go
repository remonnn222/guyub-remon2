package mysql

import (
	"context"
	"errors"
	"strings"

	"guyub/internal/domain/master"

	"gorm.io/gorm"
)

type MasterTypeRepository struct {
	db *gorm.DB
}

func NewMasterTypeRepository(db *gorm.DB) master.TypeRepository {
	return &MasterTypeRepository{db: db}
}

func (r *MasterTypeRepository) Create(ctx context.Context, t *master.Type) error {
	return r.db.WithContext(ctx).Create(t).Error
}

func (r *MasterTypeRepository) Update(ctx context.Context, t *master.Type) error {
	return r.db.WithContext(ctx).Save(t).Error
}

func (r *MasterTypeRepository) Delete(ctx context.Context, id uint64) error {
	return WithTransaction(r.db, func(tx *gorm.DB) error {
		// Soft delete all values
		if err := tx.Where("type_id = ?", id).Delete(&master.Value{}).Error; err != nil {
			return err
		}
		// Soft delete child types
		if err := tx.Where("parent_id = ?", id).Delete(&master.Type{}).Error; err != nil {
			return err
		}
		// Soft delete type
		return tx.Delete(&master.Type{}, id).Error
	})
}

func (r *MasterTypeRepository) Restore(ctx context.Context, id uint64) error {
	return WithTransaction(r.db, func(tx *gorm.DB) error {
		// Restore type
		if err := tx.Unscoped().Model(&master.Type{}).Where("id = ?", id).Update("deleted_at", nil).Error; err != nil {
			return err
		}
		// Restore values
		if err := tx.Unscoped().Model(&master.Value{}).Where("type_id = ?", id).Update("deleted_at", nil).Error; err != nil {
			return err
		}
		// Restore child types
		return tx.Unscoped().Model(&master.Type{}).Where("parent_id = ?", id).Update("deleted_at", nil).Error
	})
}

func (r *MasterTypeRepository) FindByID(ctx context.Context, id uint64) (*master.Type, error) {
	var t master.Type
	err := r.db.WithContext(ctx).First(&t, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &t, err
}

func (r *MasterTypeRepository) FindByCode(ctx context.Context, code string) (*master.Type, error) {
	var t master.Type
	err := r.db.WithContext(ctx).Where("code = ?", strings.ToUpper(code)).First(&t).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &t, err
}

func (r *MasterTypeRepository) FindAll(ctx context.Context, activeOnly bool) ([]*master.Type, error) {
	var types []*master.Type
	query := r.db.WithContext(ctx).Order("sort_order ASC, name ASC")
	if activeOnly {
		query = query.Where("is_active = ?", true)
	}
	err := query.Find(&types).Error
	return types, err
}

func (r *MasterTypeRepository) FindAllHierarchical(ctx context.Context, activeOnly bool) ([]*master.Type, error) {
	var types []*master.Type
	query := r.db.WithContext(ctx).Where("parent_id IS NULL").Order("sort_order ASC, name ASC")
	if activeOnly {
		query = query.Where("is_active = ?", true)
	}
	query = query.Preload("Children", func(db *gorm.DB) *gorm.DB {
		q := db.Order("sort_order ASC, name ASC")
		if activeOnly {
			q = q.Where("is_active = ?", true)
		}
		return q.Preload("Children")
	})
	err := query.Find(&types).Error
	return types, err
}

func (r *MasterTypeRepository) FindChildren(ctx context.Context, parentID uint64) ([]*master.Type, error) {
	var types []*master.Type
	err := r.db.WithContext(ctx).Where("parent_id = ?", parentID).Order("sort_order ASC, name ASC").Find(&types).Error
	return types, err
}

func (r *MasterTypeRepository) CountValues(ctx context.Context, typeID uint64) (int64, error) {
	var count int64
	err := r.db.WithContext(ctx).Model(&master.Value{}).Where("type_id = ?", typeID).Count(&count).Error
	return count, err
}

// Master Value Repository
type MasterValueRepository struct {
	db *gorm.DB
}

func NewMasterValueRepository(db *gorm.DB) master.ValueRepository {
	return &MasterValueRepository{db: db}
}

func (r *MasterValueRepository) Create(ctx context.Context, v *master.Value) error {
	return r.db.WithContext(ctx).Create(v).Error
}

func (r *MasterValueRepository) Update(ctx context.Context, v *master.Value) error {
	return r.db.WithContext(ctx).Save(v).Error
}

func (r *MasterValueRepository) Delete(ctx context.Context, id uint64) error {
	return r.db.WithContext(ctx).Delete(&master.Value{}, id).Error
}

func (r *MasterValueRepository) Restore(ctx context.Context, id uint64) error {
	return r.db.WithContext(ctx).Unscoped().Model(&master.Value{}).Where("id = ?", id).Update("deleted_at", nil).Error
}

func (r *MasterValueRepository) FindByID(ctx context.Context, id uint64) (*master.Value, error) {
	var v master.Value
	err := r.db.WithContext(ctx).Preload("Type").First(&v, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &v, err
}

func (r *MasterValueRepository) FindByTypeID(ctx context.Context, typeID uint64, filter *master.ValueFilter) ([]*master.Value, error) {
	var values []*master.Value
	query := r.db.WithContext(ctx).Where("type_id = ?", typeID).Order("sort_order ASC, name ASC")
	query = r.applyValueFilter(query, filter)
	err := query.Find(&values).Error
	return values, err
}

func (r *MasterValueRepository) FindByTypeCode(ctx context.Context, typeCode string, filter *master.ValueFilter) ([]*master.Value, error) {
	var values []*master.Value
	query := r.db.WithContext(ctx).
		Joins("JOIN app_master_types ON app_master_types.id = app_master_values.type_id").
		Where("app_master_types.code = ?", strings.ToUpper(typeCode)).
		Order("app_master_values.sort_order ASC, app_master_values.name ASC")
	query = r.applyValueFilter(query, filter)
	err := query.Find(&values).Error
	return values, err
}

func (r *MasterValueRepository) FindByParentValueID(ctx context.Context, parentValueID uint64) ([]*master.Value, error) {
	var values []*master.Value
	err := r.db.WithContext(ctx).Where("parent_value_id = ?", parentValueID).Order("sort_order ASC, name ASC").Find(&values).Error
	return values, err
}

func (r *MasterValueRepository) FindCascading(ctx context.Context, typeCode string, parentValueID *uint64) ([]*master.Value, error) {
	var values []*master.Value
	query := r.db.WithContext(ctx).
		Joins("JOIN app_master_types ON app_master_types.id = app_master_values.type_id").
		Where("app_master_types.code = ?", strings.ToUpper(typeCode)).
		Where("app_master_values.is_active = ?", true).
		Order("app_master_values.sort_order ASC, app_master_values.name ASC")

	if parentValueID != nil {
		query = query.Where("app_master_values.parent_value_id = ?", *parentValueID)
	} else {
		query = query.Where("app_master_values.parent_value_id IS NULL")
	}

	err := query.Find(&values).Error
	return values, err
}

func (r *MasterValueRepository) ExistsByCode(ctx context.Context, typeID uint64, code string, excludeID *uint64) (bool, error) {
	var count int64
	query := r.db.WithContext(ctx).Model(&master.Value{}).Where("type_id = ? AND code = ?", typeID, code)
	if excludeID != nil {
		query = query.Where("id != ?", *excludeID)
	}
	err := query.Count(&count).Error
	return count > 0, err
}

func (r *MasterValueRepository) applyValueFilter(query *gorm.DB, filter *master.ValueFilter) *gorm.DB {
	if filter == nil {
		return query
	}

	if filter.ParentValueID != nil {
		query = query.Where("app_master_values.parent_value_id = ?", *filter.ParentValueID)
	}

	if filter.ActiveOnly {
		query = query.Where("app_master_values.is_active = ?", true)
	}

	if filter.Search != "" {
		search := "%" + strings.ToLower(filter.Search) + "%"
		query = query.Where("LOWER(app_master_values.name) LIKE ? OR LOWER(app_master_values.code) LIKE ?", search, search)
	}

	return query
}
