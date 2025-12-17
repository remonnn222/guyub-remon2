package handler

import (
	"guyub/internal/application/auth"
	"guyub/internal/presentation/http/middleware"
	"guyub/internal/presentation/http/response"

	"github.com/gin-gonic/gin"
)

type AuthHandler struct {
	authService *auth.Service
}

func NewAuthHandler(authService *auth.Service) *AuthHandler {
	return &AuthHandler{authService: authService}
}

func (h *AuthHandler) Login(c *gin.Context) {
	var req auth.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "Invalid request body", err.Error())
		return
	}

	ip := middleware.GetClientIP(c)
	userAgent := middleware.GetUserAgent(c)

	result, err := h.authService.Login(c.Request.Context(), &req, ip, userAgent)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Login successful", result)
}

func (h *AuthHandler) Logout(c *gin.Context) {
	userID := middleware.GetUserID(c)
	ip := middleware.GetClientIP(c)
	userAgent := middleware.GetUserAgent(c)

	if err := h.authService.Logout(c.Request.Context(), userID, ip, userAgent); err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Logout successful", nil)
}

func (h *AuthHandler) Refresh(c *gin.Context) {
	var req auth.RefreshRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "Invalid request body", err.Error())
		return
	}

	result, err := h.authService.Refresh(c.Request.Context(), &req)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Token refreshed", result)
}

func (h *AuthHandler) Me(c *gin.Context) {
	userID := middleware.GetUserID(c)

	result, err := h.authService.Me(c.Request.Context(), userID)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "User retrieved", result)
}
