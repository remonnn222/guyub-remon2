package asset

import (
	"context"
)

type Repository interface {
	Create(ctx context.Context, asset *Asset) error
	Update(ctx context.Context, asset *Asset) error
	Delete(ctx context.Context, id string) error
	ForceDelete(ctx context.Context, id string) error
	FindByID(ctx context.Context, id string) (*Asset, error)
	FindByRefID(ctx context.Context, refID string, kind *Kind) ([]*Asset, error)
	FindByRefIDAndKind(ctx context.Context, refID string, kind Kind) ([]*Asset, error)
	FindLatestByRefIDAndKind(ctx context.Context, refID string, kind Kind) (*Asset, error)
	DeleteByRefIDAndKind(ctx context.Context, refID string, kind Kind) error
}

// StorageService interface for file operations
type StorageService interface {
	Store(path string, content []byte) error
	Get(path string) ([]byte, error)
	Delete(path string) error
	Exists(path string) bool
	URL(path string) string
	FullPath(path string) string
}
