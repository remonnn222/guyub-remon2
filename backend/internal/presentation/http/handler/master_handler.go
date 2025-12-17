package handler

import (
	"strconv"

	"guyub/internal/application/master"
	"guyub/internal/presentation/http/response"

	"github.com/gin-gonic/gin"
)

type MasterHandler struct {
	masterService *master.Service
}

func NewMasterHandler(masterService *master.Service) *MasterHandler {
	return &MasterHandler{masterService: masterService}
}

// Type handlers
func (h *MasterHandler) ListTypes(c *gin.Context) {
	activeOnly := c.Query("active_only") == "true"

	result, err := h.masterService.GetAllTypes(c.Request.Context(), activeOnly)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Types retrieved", result)
}

func (h *MasterHandler) CreateType(c *gin.Context) {
	var req master.CreateTypeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "Invalid request body", err.Error())
		return
	}

	result, err := h.masterService.CreateType(c.Request.Context(), &req)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.Created(c, "Type created successfully", result)
}

func (h *MasterHandler) ShowType(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "Invalid type ID", nil)
		return
	}

	result, err := h.masterService.GetType(c.Request.Context(), id)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Type retrieved", result)
}

func (h *MasterHandler) UpdateType(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "Invalid type ID", nil)
		return
	}

	var req master.UpdateTypeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "Invalid request body", err.Error())
		return
	}

	result, err := h.masterService.UpdateType(c.Request.Context(), id, &req)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Type updated successfully", result)
}

func (h *MasterHandler) DeleteType(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "Invalid type ID", nil)
		return
	}

	if err := h.masterService.DeleteType(c.Request.Context(), id); err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Type deleted successfully", nil)
}

func (h *MasterHandler) RestoreType(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "Invalid type ID", nil)
		return
	}

	if err := h.masterService.RestoreType(c.Request.Context(), id); err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Type restored successfully", nil)
}

// Value handlers
func (h *MasterHandler) ListValuesByTypeID(c *gin.Context) {
	typeID, err := strconv.ParseUint(c.Param("type_id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "Invalid type ID", nil)
		return
	}

	activeOnly := c.Query("active_only") == "true"

	result, err := h.masterService.GetValuesByTypeID(c.Request.Context(), typeID, activeOnly)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Values retrieved", result)
}

func (h *MasterHandler) ListValuesByTypeCode(c *gin.Context) {
	typeCode := c.Param("type_code")
	activeOnly := c.Query("active_only") == "true"

	result, err := h.masterService.GetValuesByTypeCode(c.Request.Context(), typeCode, activeOnly)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Values retrieved", result)
}

func (h *MasterHandler) CreateValue(c *gin.Context) {
	var req master.CreateValueRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "Invalid request body", err.Error())
		return
	}

	result, err := h.masterService.CreateValue(c.Request.Context(), &req)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.Created(c, "Value created successfully", result)
}

func (h *MasterHandler) ShowValue(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "Invalid value ID", nil)
		return
	}

	result, err := h.masterService.GetValue(c.Request.Context(), id)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Value retrieved", result)
}

func (h *MasterHandler) UpdateValue(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "Invalid value ID", nil)
		return
	}

	var req master.UpdateValueRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "Invalid request body", err.Error())
		return
	}

	result, err := h.masterService.UpdateValue(c.Request.Context(), id, &req)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Value updated successfully", result)
}

func (h *MasterHandler) DeleteValue(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "Invalid value ID", nil)
		return
	}

	if err := h.masterService.DeleteValue(c.Request.Context(), id); err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Value deleted successfully", nil)
}

// Cascading dropdown
func (h *MasterHandler) GetCascading(c *gin.Context) {
	typeCode := c.Param("type_code")

	var parentValueID *uint64
	if pvID := c.Query("parent_value_id"); pvID != "" {
		if id, err := strconv.ParseUint(pvID, 10, 64); err == nil {
			parentValueID = &id
		}
	}

	result, err := h.masterService.GetCascadingValues(c.Request.Context(), typeCode, parentValueID)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Values retrieved", result)
}
