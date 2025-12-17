package mysql

import (
	"context"
	"errors"

	"guyub/internal/domain/asset"

	"gorm.io/gorm"
)

type AssetRepository struct {
	db *gorm.DB
}

func NewAssetRepository(db *gorm.DB) asset.Repository {
	return &AssetRepository{db: db}
}

func (r *AssetRepository) Create(ctx context.Context, a *asset.Asset) error {
	return r.db.WithContext(ctx).Create(a).Error
}

func (r *AssetRepository) Update(ctx context.Context, a *asset.Asset) error {
	return r.db.WithContext(ctx).Save(a).Error
}

func (r *AssetRepository) Delete(ctx context.Context, id string) error {
	return r.db.WithContext(ctx).Delete(&asset.Asset{}, "id = ?", id).Error
}

func (r *AssetRepository) ForceDelete(ctx context.Context, id string) error {
	return r.db.WithContext(ctx).Unscoped().Delete(&asset.Asset{}, "id = ?", id).Error
}

func (r *AssetRepository) FindByID(ctx context.Context, id string) (*asset.Asset, error) {
	var a asset.Asset
	err := r.db.WithContext(ctx).First(&a, "id = ?", id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &a, err
}

func (r *AssetRepository) FindByRefID(ctx context.Context, refID string, kind *asset.Kind) ([]*asset.Asset, error) {
	var assets []*asset.Asset
	query := r.db.WithContext(ctx).Where("ref_id = ?", refID)
	if kind != nil {
		query = query.Where("kind = ?", *kind)
	}
	err := query.Order("created_at DESC").Find(&assets).Error
	return assets, err
}

func (r *AssetRepository) FindByRefIDAndKind(ctx context.Context, refID string, kind asset.Kind) ([]*asset.Asset, error) {
	var assets []*asset.Asset
	err := r.db.WithContext(ctx).
		Where("ref_id = ? AND kind = ?", refID, kind).
		Order("created_at DESC").
		Find(&assets).Error
	return assets, err
}

func (r *AssetRepository) FindLatestByRefIDAndKind(ctx context.Context, refID string, kind asset.Kind) (*asset.Asset, error) {
	var a asset.Asset
	err := r.db.WithContext(ctx).
		Where("ref_id = ? AND kind = ?", refID, kind).
		Order("created_at DESC").
		First(&a).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &a, err
}

func (r *AssetRepository) DeleteByRefIDAndKind(ctx context.Context, refID string, kind asset.Kind) error {
	return r.db.WithContext(ctx).
		Where("ref_id = ? AND kind = ?", refID, kind).
		Delete(&asset.Asset{}).Error
}
