package handler

import (
	appNotification "guyub/internal/application/notification"
	"guyub/internal/domain/notification"
	"guyub/internal/presentation/http/middleware"
	"guyub/internal/presentation/http/response"
	"strconv"

	"github.com/gin-gonic/gin"
)

type NotificationHandler struct {
	notificationService *appNotification.Service
}

func NewNotificationHandler(notificationService *appNotification.Service) *NotificationHandler {
	return &NotificationHandler{
		notificationService: notificationService,
	}
}

// SendNotification sends a custom notification
func (h *NotificationHandler) SendNotification(c *gin.Context) {
	var req struct {
		UserID uint64                        `json:"user_id" binding:"required"`
		Type   notification.NotificationType `json:"type" binding:"required"`
		Title  string                        `json:"title" binding:"required"`
		Body   string                        `json:"body" binding:"required"`
		Data   map[string]interface{}        `json:"data"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "Invalid request body", err.Error())
		return
	}

	result, err := h.notificationService.SendNotification(c.Request.Context(), &notification.SendRequest{
		UserID: req.UserID,
		Type:   req.Type,
		Title:  req.Title,
		Body:   req.Body,
		Data:   req.Data,
	})

	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Notification sent", result)
}

// SendEventNotification sends event-related notifications
func (h *NotificationHandler) SendEventNotification(c *gin.Context) {
	var req struct {
		UserID     uint64                        `json:"user_id" binding:"required"`
		EventType  notification.NotificationType `json:"event_type" binding:"required"`
		EventTitle string                        `json:"event_title" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "Invalid request body", err.Error())
		return
	}

	err := h.notificationService.SendEventNotification(c.Request.Context(), req.UserID, req.EventType, req.EventTitle)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Event notification sent", nil)
}

// SendFamilyNotification sends family-related notifications
func (h *NotificationHandler) SendFamilyNotification(c *gin.Context) {
	var req struct {
		UserID     uint64                        `json:"user_id" binding:"required"`
		FamilyType notification.NotificationType `json:"family_type" binding:"required"`
		FamilyName string                        `json:"family_name" binding:"required"`
		UserName   string                        `json:"user_name" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "Invalid request body", err.Error())
		return
	}

	err := h.notificationService.SendFamilyNotification(c.Request.Context(), req.UserID, req.FamilyType, req.FamilyName, req.UserName)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Family notification sent", nil)
}

// SendSystemNotification sends system-wide notifications
func (h *NotificationHandler) SendSystemNotification(c *gin.Context) {
	var req struct {
		UserID uint64 `json:"user_id" binding:"required"`
		Title  string `json:"title" binding:"required"`
		Body   string `json:"body" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "Invalid request body", err.Error())
		return
	}

	err := h.notificationService.SendSystemNotification(c.Request.Context(), req.UserID, req.Title, req.Body)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "System notification sent", nil)
}

// ListUserNotifications lists notifications for the authenticated user
func (h *NotificationHandler) ListUserNotifications(c *gin.Context) {
	userID := middleware.GetUserID(c)

	// Parse pagination parameters
	page := 1
	limit := 20

	if pageStr := c.Query("page"); pageStr != "" {
		if p, err := strconv.Atoi(pageStr); err == nil && p > 0 {
			page = p
		}
	}

	if limitStr := c.Query("limit"); limitStr != "" {
		if l, err := strconv.Atoi(limitStr); err == nil && l > 0 && l <= 100 {
			limit = l
		}
	}

	offset := (page - 1) * limit

	notifications, err := h.notificationService.ListUserNotifications(c.Request.Context(), userID, limit, offset)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	total, err := h.notificationService.CountUserNotifications(c.Request.Context(), userID)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Notifications retrieved", gin.H{
		"notifications": notifications,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": total,
		},
	})
}
