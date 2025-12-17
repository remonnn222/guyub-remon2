package storage

import (
	"fmt"
	"io"
	"os"
	"path/filepath"

	"guyub/internal/domain/asset"
	"guyub/pkg/config"
)

type LocalStorage struct {
	basePath string
	baseURL  string
}

func NewLocalStorage(cfg *config.StorageConfig, appURL string) asset.StorageService {
	return &LocalStorage{
		basePath: cfg.Path,
		baseURL:  appURL + "/assets",
	}
}

func (s *LocalStorage) Store(path string, content []byte) error {
	fullPath := s.FullPath(path)

	// Create directory if not exists
	dir := filepath.Dir(fullPath)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return fmt.Errorf("failed to create directory: %w", err)
	}

	// Write file
	if err := os.WriteFile(fullPath, content, 0644); err != nil {
		return fmt.Errorf("failed to write file: %w", err)
	}

	return nil
}

func (s *LocalStorage) StoreReader(path string, reader io.Reader) error {
	fullPath := s.FullPath(path)

	// Create directory if not exists
	dir := filepath.Dir(fullPath)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return fmt.Errorf("failed to create directory: %w", err)
	}

	// Create file
	file, err := os.Create(fullPath)
	if err != nil {
		return fmt.Errorf("failed to create file: %w", err)
	}
	defer file.Close()

	// Copy content
	if _, err := io.Copy(file, reader); err != nil {
		return fmt.Errorf("failed to write file: %w", err)
	}

	return nil
}

func (s *LocalStorage) Get(path string) ([]byte, error) {
	fullPath := s.FullPath(path)
	content, err := os.ReadFile(fullPath)
	if err != nil {
		if os.IsNotExist(err) {
			return nil, fmt.Errorf("file not found: %s", path)
		}
		return nil, fmt.Errorf("failed to read file: %w", err)
	}
	return content, nil
}

func (s *LocalStorage) Delete(path string) error {
	fullPath := s.FullPath(path)
	if err := os.Remove(fullPath); err != nil {
		if os.IsNotExist(err) {
			return nil // File already deleted
		}
		return fmt.Errorf("failed to delete file: %w", err)
	}
	return nil
}

func (s *LocalStorage) Exists(path string) bool {
	fullPath := s.FullPath(path)
	_, err := os.Stat(fullPath)
	return err == nil
}

func (s *LocalStorage) URL(path string) string {
	return s.baseURL + "/" + path
}

func (s *LocalStorage) FullPath(path string) string {
	return filepath.Join(s.basePath, path)
}

// Helper to get file size
func (s *LocalStorage) Size(path string) (int64, error) {
	fullPath := s.FullPath(path)
	info, err := os.Stat(fullPath)
	if err != nil {
		return 0, err
	}
	return info.Size(), nil
}

// Helper to ensure storage directories exist
func (s *LocalStorage) EnsureDirectories() error {
	dirs := []string{
		filepath.Join(s.basePath, "user_avatar"),
		filepath.Join(s.basePath, "product_image"),
		filepath.Join(s.basePath, "document"),
		filepath.Join(s.basePath, "attachment"),
	}

	for _, dir := range dirs {
		if err := os.MkdirAll(dir, 0755); err != nil {
			return fmt.Errorf("failed to create directory %s: %w", dir, err)
		}
	}

	return nil
}
