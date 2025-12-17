package handler

import (
	"strconv"

	"guyub/internal/application/activity"
	"guyub/internal/presentation/http/response"

	"github.com/gin-gonic/gin"
)

type ActivityHandler struct {
	activityService *activity.Service
}

func NewActivityHandler(activityService *activity.Service) *ActivityHandler {
	return &ActivityHandler{activityService: activityService}
}

func (h *ActivityHandler) List(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	perPage, _ := strconv.Atoi(c.DefaultQuery("per_page", "10"))
	sortBy := c.DefaultQuery("sort_by", "created_at")
	sortOrder := c.DefaultQuery("sort_order", "desc")
	activityType := c.Query("activity_type")

	var userID *uint64
	if userIDStr := c.Query("user_id"); userIDStr != "" {
		if id, err := strconv.ParseUint(userIDStr, 10, 64); err == nil {
			userID = &id
		}
	}

	params := activity.ListParams{
		Page:      page,
		PerPage:   perPage,
		SortBy:    sortBy,
		SortOrder: sortOrder,
		UserID:    userID,
	}

	if activityType != "" {
		params.ActivityType = &activityType
	}

	result, err := h.activityService.List(c.Request.Context(), params)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	meta := &response.Meta{
		CurrentPage: result.Meta.CurrentPage,
		From:        result.Meta.From,
		LastPage:    result.Meta.TotalPages,
		PerPage:     result.Meta.PerPage,
		To:          result.Meta.To,
		Total:       result.Meta.Total,
	}

	response.Paginated(c, "Activity logs retrieved", result.Data, meta)
}

func (h *ActivityHandler) Show(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "Invalid activity log ID", nil)
		return
	}

	log, err := h.activityService.GetByID(c.Request.Context(), id)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Activity log retrieved", log)
}

func (h *ActivityHandler) UserStats(c *gin.Context) {
	userID, err := strconv.ParseUint(c.Param("user_id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "Invalid user ID", nil)
		return
	}

	stats, err := h.activityService.GetUserStats(c.Request.Context(), userID)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "User activity stats retrieved", stats)
}

func (h *ActivityHandler) Stats(c *gin.Context) {
	stats, err := h.activityService.GetStats(c.Request.Context())
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Activity stats retrieved", stats)
}
