package asset

import (
	"encoding/json"
	"fmt"
	"path/filepath"
	"strings"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Kind string

const (
	KindUserAvatar   Kind = "user_avatar"
	KindProductImage Kind = "product_image"
	KindDocument     Kind = "document"
	KindAttachment   Kind = "attachment"
)

type Asset struct {
	ID               string          `gorm:"type:char(36);primaryKey" json:"id"`
	RefID            *string         `gorm:"type:varchar(255);index" json:"ref_id,omitempty"`
	Kind             Kind            `gorm:"type:varchar(50);not null;index" json:"kind"`
	Title            *string         `gorm:"type:varchar(255)" json:"title,omitempty"`
	OriginalFilename string          `gorm:"type:varchar(255);not null" json:"original_filename"`
	MimeType         string          `gorm:"type:varchar(100);not null" json:"mime_type"`
	FileSize         uint64          `gorm:"not null" json:"file_size"`
	StoragePath      string          `gorm:"type:varchar(500);not null" json:"storage_path"`
	StorageDisk      string          `gorm:"type:varchar(50);default:'local'" json:"storage_disk"`
	Metadata         json.RawMessage `gorm:"type:json" json:"metadata,omitempty"`
	UploadedBy       *uint64         `gorm:"index" json:"uploaded_by,omitempty"`
	CreatedAt        time.Time       `gorm:"type:timestamp;default:CURRENT_TIMESTAMP" json:"created_at"`
	UpdatedAt        time.Time       `gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" json:"updated_at"`
	DeletedAt        gorm.DeletedAt  `gorm:"index" json:"deleted_at,omitempty"`
}

func (Asset) TableName() string {
	return "app_assets"
}

func (a *Asset) BeforeCreate(tx *gorm.DB) error {
	if a.ID == "" {
		a.ID = uuid.New().String()
	}
	return nil
}

func (a *Asset) IsImage() bool {
	return strings.HasPrefix(a.MimeType, "image/")
}

func (a *Asset) IsPDF() bool {
	return a.MimeType == "application/pdf"
}

func (a *Asset) IsVideo() bool {
	return strings.HasPrefix(a.MimeType, "video/")
}

func (a *Asset) IsDocument() bool {
	docTypes := []string{
		"application/pdf",
		"application/msword",
		"application/vnd.openxmlformats-officedocument.wordprocessingml.document",
		"application/vnd.ms-excel",
		"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
		"text/plain",
	}
	for _, t := range docTypes {
		if a.MimeType == t {
			return true
		}
	}
	return false
}

func (a *Asset) Extension() string {
	return strings.TrimPrefix(filepath.Ext(a.OriginalFilename), ".")
}

func (a *Asset) HumanSize() string {
	const (
		KB = 1024
		MB = KB * 1024
		GB = MB * 1024
	)

	switch {
	case a.FileSize >= GB:
		return fmt.Sprintf("%.2f GB", float64(a.FileSize)/GB)
	case a.FileSize >= MB:
		return fmt.Sprintf("%.2f MB", float64(a.FileSize)/MB)
	case a.FileSize >= KB:
		return fmt.Sprintf("%.2f KB", float64(a.FileSize)/KB)
	default:
		return fmt.Sprintf("%d B", a.FileSize)
	}
}

// GenerateStoragePath creates path: {kind}/{year}/{month}/{uuid}.{ext}
func GenerateStoragePath(kind Kind, filename string) string {
	now := time.Now()
	ext := filepath.Ext(filename)
	id := uuid.New().String()
	return fmt.Sprintf("%s/%d/%02d/%s%s", kind, now.Year(), now.Month(), id, ext)
}

// ImageMetadata for image files
type ImageMetadata struct {
	Width  int `json:"width"`
	Height int `json:"height"`
}

// Allowed MIME types for upload
var AllowedMimeTypes = map[Kind][]string{
	KindUserAvatar: {
		"image/jpeg",
		"image/png",
		"image/gif",
		"image/webp",
	},
	KindProductImage: {
		"image/jpeg",
		"image/png",
		"image/gif",
		"image/webp",
	},
	KindDocument: {
		"application/pdf",
		"application/msword",
		"application/vnd.openxmlformats-officedocument.wordprocessingml.document",
		"application/vnd.ms-excel",
		"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
		"text/plain",
		"text/csv",
	},
	KindAttachment: {
		"image/jpeg",
		"image/png",
		"image/gif",
		"image/webp",
		"application/pdf",
		"application/zip",
		"application/x-rar-compressed",
		"text/plain",
		"text/csv",
	},
}

func IsAllowedMimeType(kind Kind, mimeType string) bool {
	allowed, ok := AllowedMimeTypes[kind]
	if !ok {
		return false
	}
	for _, t := range allowed {
		if t == mimeType {
			return true
		}
	}
	return false
}

// Max file sizes in bytes
var MaxFileSizes = map[Kind]int64{
	KindUserAvatar:   2 * 1024 * 1024,  // 2MB
	KindProductImage: 5 * 1024 * 1024,  // 5MB
	KindDocument:     10 * 1024 * 1024, // 10MB
	KindAttachment:   20 * 1024 * 1024, // 20MB
}

func GetMaxFileSize(kind Kind) int64 {
	if size, ok := MaxFileSizes[kind]; ok {
		return size
	}
	return 10 * 1024 * 1024 // Default 10MB
}
