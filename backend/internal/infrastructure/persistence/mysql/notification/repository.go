package notification

import (
	"context"
	"time"

	"guyub/internal/domain/notification"

	"gorm.io/gorm"
)

// Repository implements notification.Repository
type Repository struct {
	db *gorm.DB
}

// NewNotificationRepository creates a new notification repository
func NewNotificationRepository(db *gorm.DB) notification.Repository {
	return &Repository{db: db}
}

// Create stores a new notification record
func (r *Repository) Create(ctx context.Context, notif *notification.Notification) error {
	return r.db.WithContext(ctx).Create(notif).Error
}

// Update updates an existing notification record
func (r *Repository) Update(ctx context.Context, notif *notification.Notification) error {
	notif.UpdatedAt = time.Now()
	return r.db.WithContext(ctx).Save(notif).Error
}

// FindByID finds a notification by ID
func (r *Repository) FindByID(ctx context.Context, id string) (*notification.Notification, error) {
	var notif notification.Notification
	err := r.db.WithContext(ctx).First(&notif, "id = ?", id).Error
	if err != nil {
		return nil, err
	}
	return &notif, nil
}

// FindByUserID finds notifications for a specific user
func (r *Repository) FindByUserID(ctx context.Context, userID uint64, limit, offset int) ([]*notification.Notification, error) {
	var notifications []*notification.Notification
	err := r.db.WithContext(ctx).
		Where("user_id = ?", userID).
		Order("created_at DESC").
		Limit(limit).
		Offset(offset).
		Find(&notifications).Error
	return notifications, err
}

// UpdateStatus updates the status of a notification
func (r *Repository) UpdateStatus(ctx context.Context, id string, status string, errorMsg string) error {
	updateData := map[string]interface{}{
		"status":     status,
		"updated_at": time.Now(),
	}

	if errorMsg != "" {
		updateData["error"] = errorMsg
	}

	if status == "delivered" {
		updateData["delivered_at"] = time.Now()
	}

	return r.db.WithContext(ctx).
		Model(&notification.Notification{}).
		Where("id = ?", id).
		Updates(updateData).Error
}

// GetUserFCMToken gets FCM token for a user
func (r *Repository) GetUserFCMToken(ctx context.Context, userID uint64) (string, error) {
	var token string
	err := r.db.WithContext(ctx).
		Table("users").
		Where("id = ?", userID).
		Select("fcm_token").
		Scan(&token).Error
	return token, err
}

// CountByUserID counts notifications for a user
func (r *Repository) CountByUserID(ctx context.Context, userID uint64) (int64, error) {
	var count int64
	err := r.db.WithContext(ctx).
		Model(&notification.Notification{}).
		Where("user_id = ?", userID).
		Count(&count).Error
	return count, err
}
