package notification

import (
	"time"
)

// NotificationType represents different types of push notifications
type NotificationType string

const (
	NotificationTypeEventNew      NotificationType = "event_new"
	NotificationTypeEventApproved NotificationType = "event_approved"
	NotificationTypeEventRejected NotificationType = "event_rejected"
	NotificationTypeFamilyJoin    NotificationType = "family_join"
	NotificationTypeFamilyInvite  NotificationType = "family_invite"
	NotificationTypeSystem        NotificationType = "system"
)

// Notification represents a push notification to be sent
type Notification struct {
	ID          string                 `json:"id"`
	UserID      uint64                 `json:"user_id"`
	Type        NotificationType       `json:"type"`
	Title       string                 `json:"title"`
	Body        string                 `json:"body"`
	Data        map[string]interface{} `json:"data,omitempty"`
	FCMToken    string                 `json:"fcm_token"`
	SentAt      *time.Time             `json:"sent_at,omitempty"`
	DeliveredAt *time.Time             `json:"delivered_at,omitempty"`
	Status      string                 `json:"status"` // pending, sent, delivered, failed
	Error       string                 `json:"error,omitempty"`
	CreatedAt   time.Time              `json:"created_at"`
	UpdatedAt   time.Time              `json:"updated_at"`
}

// FCMMessage represents the message structure for FCM
type FCMMessage struct {
	Token        string                 `json:"token"`
	Notification FCMNotification        `json:"notification,omitempty"`
	Data         map[string]interface{} `json:"data,omitempty"`
	Android      FCMAndroidConfig       `json:"android,omitempty"`
	IOS          FCMIOSConfig           `json:"ios,omitempty"`
}

// FCMNotification represents the notification payload
type FCMNotification struct {
	Title string `json:"title"`
	Body  string `json:"body"`
}

// FCMAndroidConfig represents Android-specific configuration
type FCMAndroidConfig struct {
	Priority string `json:"priority"` // normal or high
}

// FCMIOSConfig represents iOS-specific configuration
type FCMIOSConfig struct {
	Sound string `json:"sound,omitempty"`
	Badge int    `json:"badge,omitempty"`
}

// FCMResponse represents the response from FCM
type FCMResponse struct {
	Name    string             `json:"name"`
	Message FCMResponseMessage `json:"message,omitempty"`
	Error   FCMError           `json:"error,omitempty"`
}

// FCMResponseMessage represents the message part of FCM response
type FCMResponseMessage struct {
	Name string `json:"name"`
}

// FCMError represents error from FCM
type FCMError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
	Status  string `json:"status"`
}

// SendRequest represents a request to send a notification
type SendRequest struct {
	UserID uint64                 `json:"user_id"`
	Type   NotificationType       `json:"type"`
	Title  string                 `json:"title"`
	Body   string                 `json:"body"`
	Data   map[string]interface{} `json:"data,omitempty"`
}

// SendResponse represents the response after sending a notification
type SendResponse struct {
	Success   bool   `json:"success"`
	MessageID string `json:"message_id,omitempty"`
	Error     string `json:"error,omitempty"`
}
