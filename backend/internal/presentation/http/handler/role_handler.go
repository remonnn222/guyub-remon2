package handler

import (
	"strconv"

	"guyub/internal/application/role"
	"guyub/internal/presentation/http/response"

	"github.com/gin-gonic/gin"
)

type RoleHandler struct {
	roleService *role.Service
}

func NewRoleHandler(roleService *role.Service) *RoleHandler {
	return &RoleHandler{roleService: roleService}
}

func (h *RoleHandler) List(c *gin.Context) {
	result, err := h.roleService.FindAll(c.Request.Context())
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Roles retrieved", result)
}

func (h *RoleHandler) Create(c *gin.Context) {
	var req role.CreateRoleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "Invalid request body", err.Error())
		return
	}

	result, err := h.roleService.Create(c.Request.Context(), &req)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.Created(c, "Role created successfully", result)
}

func (h *RoleHandler) Show(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "Invalid role ID", nil)
		return
	}

	result, err := h.roleService.FindByID(c.Request.Context(), id)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Role retrieved", result)
}

func (h *RoleHandler) Update(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "Invalid role ID", nil)
		return
	}

	var req role.UpdateRoleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "Invalid request body", err.Error())
		return
	}

	result, err := h.roleService.Update(c.Request.Context(), id, &req)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Role updated successfully", result)
}

func (h *RoleHandler) Delete(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "Invalid role ID", nil)
		return
	}

	if err := h.roleService.Delete(c.Request.Context(), id); err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Role deleted successfully", nil)
}

func (h *RoleHandler) SyncPermissions(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "Invalid role ID", nil)
		return
	}

	var req struct {
		PermissionIDs []uint64 `json:"permission_ids"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "Invalid request body", err.Error())
		return
	}

	if err := h.roleService.SyncPermissions(c.Request.Context(), id, req.PermissionIDs); err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Permissions synced successfully", nil)
}

func (h *RoleHandler) ListPermissions(c *gin.Context) {
	result, err := h.roleService.GetAllPermissions(c.Request.Context())
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Permissions retrieved", result)
}

func (h *RoleHandler) ListPermissionsGrouped(c *gin.Context) {
	result, err := h.roleService.GetPermissionsGrouped(c.Request.Context())
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Permissions retrieved", result)
}
