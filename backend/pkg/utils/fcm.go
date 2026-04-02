package utils

import (
	"context"
	"fmt"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
)

// SendPushNotification mengirim pesan ke satu device berdasarkan token
func SendPushNotification(token string, title string, body string) error {
	ctx := context.Background()

	// Inisialisasi Firebase App
	opt := option.WithServiceAccountFile("service-account.json")
	app, err := firebase.NewApp(ctx, nil, opt)
	if err != nil {
		return fmt.Errorf("error initializing app: %v", err)
	}

	// Dapatkan client Messaging
	client, err := app.Messaging(ctx)
	if err != nil {
		return fmt.Errorf("error getting Messaging client: %v", err)
	}

	// Konfigurasi pesan
	message := &messaging.Message{
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Token: token,
	}

	// Kirim pesan
	_, err = client.Send(ctx, message)
	if err != nil {
		return fmt.Errorf("error sending message: %v", err)
	}

	return nil
}
