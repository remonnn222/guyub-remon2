package handler

import (
	"strconv"

	"guyub/internal/application/user"
	"guyub/internal/presentation/http/middleware"
	"guyub/internal/presentation/http/response"

	"github.com/gin-gonic/gin"
)

type UserHandler struct {
	userService *user.Service
}

func NewUserHandler(userService *user.Service) *UserHandler {
	return &UserHandler{userService: userService}
}

func (h *UserHandler) List(c *gin.Context) {
	req := &user.ListUsersRequest{
		Page:    1,
		PerPage: 15,
		SortBy:  "created_at",
		SortDir: "desc",
	}

	if page, err := strconv.Atoi(c.DefaultQuery("page", "1")); err == nil {
		req.Page = page
	}
	if perPage, err := strconv.Atoi(c.DefaultQuery("per_page", "15")); err == nil {
		req.PerPage = perPage
	}

	req.Search = c.Query("search")
	if status := c.Query("status"); status != "" {
		req.Status = &status
	}
	if userType := c.Query("type"); userType != "" {
		req.Type = &userType
	}
	if roleID, err := strconv.ParseUint(c.Query("role_id"), 10, 64); err == nil {
		req.RoleID = &roleID
	}
	if sortBy := c.Query("sort_by"); sortBy != "" {
		req.SortBy = sortBy
	}
	if sortDir := c.Query("sort_dir"); sortDir != "" {
		req.SortDir = sortDir
	}
	req.WithTrashed = c.Query("with_trashed") == "true"
	req.OnlyTrashed = c.Query("only_trashed") == "true"

	result, err := h.userService.List(c.Request.Context(), req)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.Paginated(c, "Users retrieved", result.Data, &response.Meta{
		CurrentPage: result.Meta.CurrentPage,
		From:        result.Meta.From,
		LastPage:    result.Meta.LastPage,
		PerPage:     result.Meta.PerPage,
		To:          result.Meta.To,
		Total:       result.Meta.Total,
	})
}

func (h *UserHandler) Create(c *gin.Context) {
	var req user.CreateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "Invalid request body", err.Error())
		return
	}

	createdBy := middleware.GetUserID(c)
	result, err := h.userService.Create(c.Request.Context(), &req, createdBy)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.Created(c, "User created successfully", result)
}

func (h *UserHandler) Show(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "Invalid user ID", nil)
		return
	}

	result, err := h.userService.FindByID(c.Request.Context(), id)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "User retrieved", result)
}

func (h *UserHandler) Update(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "Invalid user ID", nil)
		return
	}

	var req user.UpdateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "Invalid request body", err.Error())
		return
	}

	updatedBy := middleware.GetUserID(c)
	result, err := h.userService.Update(c.Request.Context(), id, &req, updatedBy)
	if err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "User updated successfully", result)
}

func (h *UserHandler) Delete(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "Invalid user ID", nil)
		return
	}

	deletedBy := middleware.GetUserID(c)
	if err := h.userService.Delete(c.Request.Context(), id, deletedBy); err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "User deleted successfully", nil)
}

func (h *UserHandler) Restore(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "Invalid user ID", nil)
		return
	}

	restoredBy := middleware.GetUserID(c)
	if err := h.userService.Restore(c.Request.Context(), id, restoredBy); err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "User restored successfully", nil)
}

func (h *UserHandler) ForceDelete(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		response.BadRequest(c, "Invalid user ID", nil)
		return
	}

	deletedBy := middleware.GetUserID(c)
	if err := h.userService.ForceDelete(c.Request.Context(), id, deletedBy); err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "User permanently deleted", nil)
}

func (h *UserHandler) BulkDelete(c *gin.Context) {
	var req user.BulkDeleteRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "Invalid request body", err.Error())
		return
	}

	deletedBy := middleware.GetUserID(c)
	if err := h.userService.BulkDelete(c.Request.Context(), &req, deletedBy); err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Users deleted successfully", nil)
}

func (h *UserHandler) BulkRestore(c *gin.Context) {
	var req struct {
		IDs []uint64 `json:"ids"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "Invalid request body", err.Error())
		return
	}

	if err := h.userService.BulkRestore(c.Request.Context(), req.IDs); err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Users restored successfully", nil)
}

func (h *UserHandler) BulkAssignRole(c *gin.Context) {
	var req user.BulkAssignRoleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "Invalid request body", err.Error())
		return
	}

	if err := h.userService.BulkAssignRole(c.Request.Context(), &req); err != nil {
		response.HandleError(c, err)
		return
	}

	response.OK(c, "Role assigned to users successfully", nil)
}
