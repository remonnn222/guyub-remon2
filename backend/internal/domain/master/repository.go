package master

import (
	"context"
)

type TypeRepository interface {
	Create(ctx context.Context, t *Type) error
	Update(ctx context.Context, t *Type) error
	Delete(ctx context.Context, id uint64) error
	Restore(ctx context.Context, id uint64) error
	FindByID(ctx context.Context, id uint64) (*Type, error)
	FindByCode(ctx context.Context, code string) (*Type, error)
	FindAll(ctx context.Context, activeOnly bool) ([]*Type, error)
	FindAllHierarchical(ctx context.Context, activeOnly bool) ([]*Type, error)
	FindChildren(ctx context.Context, parentID uint64) ([]*Type, error)
	CountValues(ctx context.Context, typeID uint64) (int64, error)
}

type ValueRepository interface {
	Create(ctx context.Context, v *Value) error
	Update(ctx context.Context, v *Value) error
	Delete(ctx context.Context, id uint64) error
	Restore(ctx context.Context, id uint64) error
	FindByID(ctx context.Context, id uint64) (*Value, error)
	FindByTypeID(ctx context.Context, typeID uint64, filter *ValueFilter) ([]*Value, error)
	FindByTypeCode(ctx context.Context, typeCode string, filter *ValueFilter) ([]*Value, error)
	FindByParentValueID(ctx context.Context, parentValueID uint64) ([]*Value, error)
	FindCascading(ctx context.Context, typeCode string, parentValueID *uint64) ([]*Value, error)
	ExistsByCode(ctx context.Context, typeID uint64, code string, excludeID *uint64) (bool, error)
}

type ValueFilter struct {
	ParentValueID *uint64
	ActiveOnly    bool
	Search        string
}
