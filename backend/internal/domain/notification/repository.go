package notification

import (
	"context"
)

// Repository defines the interface for notification data access
type Repository interface {
	// Create stores a new notification record
	Create(ctx context.Context, notification *Notification) error

	// Update updates an existing notification record
	Update(ctx context.Context, notification *Notification) error

	// FindByID finds a notification by ID
	FindByID(ctx context.Context, id string) (*Notification, error)

	// FindByUserID finds notifications for a specific user
	FindByUserID(ctx context.Context, userID uint64, limit, offset int) ([]*Notification, error)

	// UpdateStatus updates the status of a notification
	UpdateStatus(ctx context.Context, id string, status string, errorMsg string) error

	// GetUserFCMToken gets FCM token for a user
	GetUserFCMToken(ctx context.Context, userID uint64) (string, error)

	// CountByUserID counts notifications for a user
	CountByUserID(ctx context.Context, userID uint64) (int64, error)
}
