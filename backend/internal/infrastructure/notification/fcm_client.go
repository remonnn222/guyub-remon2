package notification

import (
	"context"
	"encoding/json"
	"fmt"

	"guyub/internal/domain/notification"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
)

// FCMClient implements FCM operations using Firebase Admin SDK
type FCMClient struct {
	client *messaging.Client
}

// NewFCMClient creates a new FCM client
func NewFCMClient(serviceAccountPath string) (*FCMClient, error) {
	ctx := context.Background()

	// Initialize Firebase app
	opt := option.WithCredentialsFile(serviceAccountPath)
	app, err := firebase.NewApp(ctx, nil, opt)
	if err != nil {
		return nil, fmt.Errorf("failed to initialize Firebase app: %w", err)
	}

	// Get messaging client
	client, err := app.Messaging(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to get messaging client: %w", err)
	}

	return &FCMClient{
		client: client,
	}, nil
}

// SendMessage sends a message via FCM
func (f *FCMClient) SendMessage(ctx context.Context, message *notification.FCMMessage) (*notification.FCMResponse, error) {
	// Convert to Firebase messaging.Message
	fcmMsg := &messaging.Message{
		Token: message.Token,
		Data:  convertDataToStringMap(message.Data),
		Android: &messaging.AndroidConfig{
			Priority: convertPriority(message.Android.Priority),
		},
		APNS: &messaging.APNSConfig{
			Payload: &messaging.APNSPayload{
				Aps: &messaging.Aps{
					Sound: message.IOS.Sound,
					Badge: &message.IOS.Badge,
				},
			},
		},
	}

	// Add notification if present
	if message.Notification.Title != "" || message.Notification.Body != "" {
		fcmMsg.Notification = &messaging.Notification{
			Title: message.Notification.Title,
			Body:  message.Notification.Body,
		}
	}

	// Send message
	response, err := f.client.Send(ctx, fcmMsg)
	if err != nil {
		return &notification.FCMResponse{
			Error: notification.FCMError{
				Code:    500,
				Message: err.Error(),
				Status:  "INTERNAL_ERROR",
			},
		}, fmt.Errorf("failed to send FCM message: %w", err)
	}

	return &notification.FCMResponse{
		Name: response,
		Message: notification.FCMResponseMessage{
			Name: response,
		},
	}, nil
}

// convertDataToStringMap converts map[string]interface{} to map[string]string
func convertDataToStringMap(data map[string]interface{}) map[string]string {
	if data == nil {
		return nil
	}

	result := make(map[string]string)
	for k, v := range data {
		switch val := v.(type) {
		case string:
			result[k] = val
		default:
			// Convert to JSON string for complex types
			jsonBytes, err := json.Marshal(val)
			if err == nil {
				result[k] = string(jsonBytes)
			}
		}
	}
	return result
}

// convertPriority converts string priority to messaging priority
func convertPriority(priority string) string {
	switch priority {
	case "high":
		return "high"
	case "normal":
		return "normal"
	default:
		return "normal"
	}
}

// NoOpFCMClient is a no-operation FCM client for development/testing
type NoOpFCMClient struct{}

// NewNoOpFCMClient creates a new no-operation FCM client
func NewNoOpFCMClient() *NoOpFCMClient {
	return &NoOpFCMClient{}
}

// SendMessage simulates sending a message (no-op)
func (n *NoOpFCMClient) SendMessage(ctx context.Context, message *notification.FCMMessage) (*notification.FCMResponse, error) {
	// Return a mock successful response
	return &notification.FCMResponse{
		Name: "projects/mock/messages/mock-id",
		Message: notification.FCMResponseMessage{
			Name: "projects/mock/messages/mock-id",
		},
	}, nil
}
