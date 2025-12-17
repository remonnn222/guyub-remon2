package handler

import (
	"guyub/internal/application/analytics"
	"guyub/internal/presentation/http/response"

	"github.com/gin-gonic/gin"
)

type AnalyticsHandler struct {
	analyticsService *analytics.Service
}

func NewAnalyticsHandler(analyticsService *analytics.Service) *AnalyticsHandler {
	return &AnalyticsHandler{analyticsService: analyticsService}
}

func (h *AnalyticsHandler) Dashboard(c *gin.Context) {
	stats, err := h.analyticsService.GetDashboardStats(c.Request.Context())
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Dashboard stats retrieved", stats)
}
