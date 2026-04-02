package notification

import (
	"context"
	"fmt"
	"time"

	"guyub/internal/domain/notification"
	"guyub/internal/domain/user"

	"github.com/google/uuid"
)

// Service handles notification business logic
type Service struct {
	notificationRepo notification.Repository
	userRepo         user.Repository
	fcmClient        FCMClient
}

// FCMClient defines the interface for FCM operations
type FCMClient interface {
	SendMessage(ctx context.Context, message *notification.FCMMessage) (*notification.FCMResponse, error)
}

// NewService creates a new notification service
func NewService(
	notificationRepo notification.Repository,
	userRepo user.Repository,
	fcmClient FCMClient,
) *Service {
	return &Service{
		notificationRepo: notificationRepo,
		userRepo:         userRepo,
		fcmClient:        fcmClient,
	}
}

// SendNotification sends a push notification to a user
func (s *Service) SendNotification(ctx context.Context, req *notification.SendRequest) (*notification.SendResponse, error) {
	// Get user's FCM token
	fcmToken, err := s.notificationRepo.GetUserFCMToken(ctx, req.UserID)
	if err != nil {
		return &notification.SendResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to get FCM token: %v", err),
		}, nil
	}

	if fcmToken == "" {
		return &notification.SendResponse{
			Success: false,
			Error:   "user has no FCM token",
		}, nil
	}

	// Create notification record
	notif := &notification.Notification{
		ID:        uuid.New().String(),
		UserID:    req.UserID,
		Type:      req.Type,
		Title:     req.Title,
		Body:      req.Body,
		Data:      req.Data,
		FCMToken:  fcmToken,
		Status:    "pending",
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	// Save notification record
	if err := s.notificationRepo.Create(ctx, notif); err != nil {
		return &notification.SendResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to save notification: %v", err),
		}, nil
	}

	// Prepare FCM message
	fcmMessage := &notification.FCMMessage{
		Token: fcmToken,
		Notification: notification.FCMNotification{
			Title: req.Title,
			Body:  req.Body,
		},
		Data: req.Data,
		Android: notification.FCMAndroidConfig{
			Priority: "high",
		},
		IOS: notification.FCMIOSConfig{
			Sound: "default",
			Badge: 1,
		},
	}

	// Add notification type to data
	if fcmMessage.Data == nil {
		fcmMessage.Data = make(map[string]interface{})
	}
	fcmMessage.Data["type"] = string(req.Type)

	// Send FCM message
	response, err := s.fcmClient.SendMessage(ctx, fcmMessage)
	if err != nil {
		// Update notification status to failed
		s.notificationRepo.UpdateStatus(ctx, notif.ID, "failed", err.Error())
		return &notification.SendResponse{
			Success: false,
			Error:   fmt.Sprintf("failed to send FCM message: %v", err),
		}, nil
	}

	// Update notification status to sent
	now := time.Now()
	notif.SentAt = &now
	notif.Status = "sent"
	if response.Message.Name != "" {
		notif.Status = "delivered"
		notif.DeliveredAt = &now
	}

	if err := s.notificationRepo.Update(ctx, notif); err != nil {
		// Log error but don't fail the operation
		fmt.Printf("Failed to update notification status: %v\n", err)
	}

	return &notification.SendResponse{
		Success:   true,
		MessageID: response.Message.Name,
	}, nil
}

// SendEventNotification sends notification for event-related actions
func (s *Service) SendEventNotification(ctx context.Context, userID uint64, eventType notification.NotificationType, eventTitle string) error {
	var title, body string

	switch eventType {
	case notification.NotificationTypeEventNew:
		title = "Event Baru"
		body = fmt.Sprintf("Ada event baru: %s", eventTitle)
	case notification.NotificationTypeEventApproved:
		title = "Event Disetujui"
		body = "Event kamu telah disetujui"
	case notification.NotificationTypeEventRejected:
		title = "Event Ditolak"
		body = "Event kamu telah ditolak"
	default:
		return fmt.Errorf("unsupported event type: %s", eventType)
	}

	req := &notification.SendRequest{
		UserID: userID,
		Type:   eventType,
		Title:  title,
		Body:   body,
		Data: map[string]interface{}{
			"event_title": eventTitle,
		},
	}

	_, err := s.SendNotification(ctx, req)
	return err
}

// SendFamilyNotification sends notification for family-related actions
func (s *Service) SendFamilyNotification(ctx context.Context, userID uint64, familyType notification.NotificationType, familyName, userName string) error {
	var title, body string

	switch familyType {
	case notification.NotificationTypeFamilyJoin:
		title = "Bergabung Keluarga"
		body = fmt.Sprintf("%s bergabung ke keluarga", userName)
	case notification.NotificationTypeFamilyInvite:
		title = "Undangan Keluarga"
		body = fmt.Sprintf("Kamu diundang ke keluarga %s", familyName)
	default:
		return fmt.Errorf("unsupported family type: %s", familyType)
	}

	req := &notification.SendRequest{
		UserID: userID,
		Type:   familyType,
		Title:  title,
		Body:   body,
		Data: map[string]interface{}{
			"family_name": familyName,
			"user_name":   userName,
		},
	}

	_, err := s.SendNotification(ctx, req)
	return err
}

// SendSystemNotification sends system-wide notifications
func (s *Service) SendSystemNotification(ctx context.Context, userID uint64, title, body string) error {
	req := &notification.SendRequest{
		UserID: userID,
		Type:   notification.NotificationTypeSystem,
		Title:  title,
		Body:   body,
		Data:   map[string]interface{}{},
	}

	_, err := s.SendNotification(ctx, req)
	return err
}

// ListUserNotifications lists notifications for a user
func (s *Service) ListUserNotifications(ctx context.Context, userID uint64, limit, offset int) ([]*notification.Notification, error) {
	return s.notificationRepo.FindByUserID(ctx, userID, limit, offset)
}

// CountUserNotifications counts notifications for a user
func (s *Service) CountUserNotifications(ctx context.Context, userID uint64) (int64, error) {
	return s.notificationRepo.CountByUserID(ctx, userID)
}
