package asset

import (
	"context"
	"errors"
	"fmt"
	"io"
	"strconv"

	"guyub/internal/domain/asset"
)

var (
	ErrAssetNotFound     = errors.New("asset not found")
	ErrInvalidMimeType   = errors.New("invalid file type")
	ErrFileTooLarge      = errors.New("file size exceeds limit")
	ErrInvalidKind       = errors.New("invalid asset kind")
	ErrStorageFailed     = errors.New("failed to store file")
	ErrDeleteFailed      = errors.New("failed to delete file")
)

type Service struct {
	assetRepo      asset.Repository
	storageService asset.StorageService
}

func NewService(
	assetRepo asset.Repository,
	storageService asset.StorageService,
) *Service {
	return &Service{
		assetRepo:      assetRepo,
		storageService: storageService,
	}
}

// DTOs
type UploadRequest struct {
	File             io.Reader
	Filename         string
	MimeType         string
	FileSize         int64
	Kind             asset.Kind
	RefID            *string
	Title            *string
	UploadedBy       *uint64
}

type AssetResponse struct {
	ID               string  `json:"id"`
	RefID            *string `json:"ref_id,omitempty"`
	Kind             string  `json:"kind"`
	Title            *string `json:"title,omitempty"`
	OriginalFilename string  `json:"original_filename"`
	MimeType         string  `json:"mime_type"`
	FileSize         uint64  `json:"file_size"`
	HumanSize        string  `json:"human_size"`
	URL              string  `json:"url"`
	IsImage          bool    `json:"is_image"`
	CreatedAt        string  `json:"created_at"`
}

type ListByRefRequest struct {
	RefID string      `json:"ref_id"`
	Kind  *asset.Kind `json:"kind,omitempty"`
}

// Upload handles file upload with validation
func (s *Service) Upload(ctx context.Context, req *UploadRequest) (*AssetResponse, error) {
	// Validate kind
	if !isValidKind(req.Kind) {
		return nil, ErrInvalidKind
	}

	// Validate MIME type
	if !asset.IsAllowedMimeType(req.Kind, req.MimeType) {
		return nil, fmt.Errorf("%w: %s is not allowed for %s", ErrInvalidMimeType, req.MimeType, req.Kind)
	}

	// Validate file size
	maxSize := asset.GetMaxFileSize(req.Kind)
	if req.FileSize > maxSize {
		return nil, fmt.Errorf("%w: max size is %d bytes", ErrFileTooLarge, maxSize)
	}

	// Generate storage path
	storagePath := asset.GenerateStoragePath(req.Kind, req.Filename)

	// Read file content
	content, err := io.ReadAll(req.File)
	if err != nil {
		return nil, fmt.Errorf("failed to read file: %w", err)
	}

	// Store file
	if err := s.storageService.Store(storagePath, content); err != nil {
		return nil, fmt.Errorf("%w: %v", ErrStorageFailed, err)
	}

	// Create asset record
	a := &asset.Asset{
		RefID:            req.RefID,
		Kind:             req.Kind,
		Title:            req.Title,
		OriginalFilename: req.Filename,
		MimeType:         req.MimeType,
		FileSize:         uint64(req.FileSize),
		StoragePath:      storagePath,
		StorageDisk:      "local",
		UploadedBy:       req.UploadedBy,
	}

	if err := s.assetRepo.Create(ctx, a); err != nil {
		// Cleanup: delete stored file on DB error
		_ = s.storageService.Delete(storagePath)
		return nil, err
	}

	return s.toResponse(a), nil
}

// FindByID retrieves an asset by ID
func (s *Service) FindByID(ctx context.Context, id string) (*AssetResponse, error) {
	a, err := s.assetRepo.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if a == nil {
		return nil, ErrAssetNotFound
	}
	return s.toResponse(a), nil
}

// FindByRef retrieves assets by reference ID and optional kind
func (s *Service) FindByRef(ctx context.Context, req *ListByRefRequest) ([]*AssetResponse, error) {
	assets, err := s.assetRepo.FindByRefID(ctx, req.RefID, req.Kind)
	if err != nil {
		return nil, err
	}

	responses := make([]*AssetResponse, len(assets))
	for i, a := range assets {
		responses[i] = s.toResponse(a)
	}
	return responses, nil
}

// FindLatestByRefAndKind retrieves the latest asset for a ref+kind combination
func (s *Service) FindLatestByRefAndKind(ctx context.Context, refID string, kind asset.Kind) (*AssetResponse, error) {
	a, err := s.assetRepo.FindLatestByRefIDAndKind(ctx, refID, kind)
	if err != nil {
		return nil, err
	}
	if a == nil {
		return nil, nil // Not found is OK, return nil
	}
	return s.toResponse(a), nil
}

// Delete removes an asset by ID
func (s *Service) Delete(ctx context.Context, id string) error {
	a, err := s.assetRepo.FindByID(ctx, id)
	if err != nil {
		return err
	}
	if a == nil {
		return ErrAssetNotFound
	}

	// Delete from storage
	if err := s.storageService.Delete(a.StoragePath); err != nil {
		// Log but don't fail - file might already be deleted
		fmt.Printf("Warning: failed to delete file from storage: %v\n", err)
	}

	// Delete from database
	if err := s.assetRepo.ForceDelete(ctx, id); err != nil {
		return fmt.Errorf("%w: %v", ErrDeleteFailed, err)
	}

	return nil
}

// DeleteByRefAndKind removes all assets for a ref+kind combination
func (s *Service) DeleteByRefAndKind(ctx context.Context, refID string, kind asset.Kind) error {
	// Find all assets first
	assets, err := s.assetRepo.FindByRefIDAndKind(ctx, refID, kind)
	if err != nil {
		return err
	}

	// Delete files from storage
	for _, a := range assets {
		_ = s.storageService.Delete(a.StoragePath)
	}

	// Delete from database
	return s.assetRepo.DeleteByRefIDAndKind(ctx, refID, kind)
}

// LinkToRef updates an asset to link it to a reference
func (s *Service) LinkToRef(ctx context.Context, assetID string, refID string) error {
	a, err := s.assetRepo.FindByID(ctx, assetID)
	if err != nil {
		return err
	}
	if a == nil {
		return ErrAssetNotFound
	}

	a.RefID = &refID
	return s.assetRepo.Update(ctx, a)
}

// GetURL returns the public URL for an asset
func (s *Service) GetURL(ctx context.Context, id string) (string, error) {
	a, err := s.assetRepo.FindByID(ctx, id)
	if err != nil {
		return "", err
	}
	if a == nil {
		return "", ErrAssetNotFound
	}
	return s.storageService.URL(a.StoragePath), nil
}

// GetUserAvatarURL returns the avatar URL for a user
func (s *Service) GetUserAvatarURL(ctx context.Context, userID uint64) (string, error) {
	refID := strconv.FormatUint(userID, 10)
	a, err := s.assetRepo.FindLatestByRefIDAndKind(ctx, refID, asset.KindUserAvatar)
	if err != nil {
		return "", err
	}
	if a == nil {
		return "", nil // No avatar
	}
	return s.storageService.URL(a.StoragePath), nil
}

// Helper methods
func (s *Service) toResponse(a *asset.Asset) *AssetResponse {
	return &AssetResponse{
		ID:               a.ID,
		RefID:            a.RefID,
		Kind:             string(a.Kind),
		Title:            a.Title,
		OriginalFilename: a.OriginalFilename,
		MimeType:         a.MimeType,
		FileSize:         a.FileSize,
		HumanSize:        a.HumanSize(),
		URL:              s.storageService.URL(a.StoragePath),
		IsImage:          a.IsImage(),
		CreatedAt:        a.CreatedAt.Format("2006-01-02T15:04:05Z"),
	}
}

func isValidKind(kind asset.Kind) bool {
	switch kind {
	case asset.KindUserAvatar, asset.KindProductImage, asset.KindDocument, asset.KindAttachment:
		return true
	default:
		return false
	}
}
