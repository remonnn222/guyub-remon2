package handler

import (
	"strconv"

	"guyub/internal/application/audit"
	"guyub/internal/presentation/http/response"

	"github.com/gin-gonic/gin"
)

type AuditHandler struct {
	auditService *audit.Service
}

func NewAuditHandler(auditService *audit.Service) *AuditHandler {
	return &AuditHandler{auditService: auditService}
}

func (h *AuditHandler) List(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	perPage, _ := strconv.Atoi(c.DefaultQuery("per_page", "10"))
	sortBy := c.DefaultQuery("sort_by", "created_at")
	sortOrder := c.DefaultQuery("sort_order", "desc")
	event := c.Query("event")
	auditableType := c.Query("auditable_type")
	search := c.Query("search")

	var userID *uint64
	if userIDStr := c.Query("user_id"); userIDStr != "" {
		if id, err := strconv.ParseUint(userIDStr, 10, 64); err == nil {
			userID = &id
		}
	}

	params := audit.ListParams{
		Page:      page,
		PerPage:   perPage,
		SortBy:    sortBy,
		SortOrder: sortOrder,
		UserID:    userID,
		Search:    search,
	}

	if event != "" {
		params.Event = &event
	}
	if auditableType != "" {
		params.AuditableType = &auditableType
	}

	result, err := h.auditService.List(c.Request.Context(), params)
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

	response.Paginated(c, "Audit logs retrieved", result.Data, meta)
}

func (h *AuditHandler) Show(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "Invalid audit log ID", nil)
		return
	}

	log, err := h.auditService.GetByID(c.Request.Context(), id)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Audit log retrieved", log)
}

func (h *AuditHandler) Stats(c *gin.Context) {
	stats, err := h.auditService.GetStats(c.Request.Context())
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Audit stats retrieved", stats)
}
