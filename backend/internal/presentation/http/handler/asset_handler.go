package handler

import (
	"errors"
	"strconv"

	appAsset "guyub/internal/application/asset"
	"guyub/internal/domain/asset"
	"guyub/internal/presentation/http/middleware"
	"guyub/internal/presentation/http/response"

	"github.com/gin-gonic/gin"
)

type AssetHandler struct {
	assetService *appAsset.Service
}

func NewAssetHandler(assetService *appAsset.Service) *AssetHandler {
	return &AssetHandler{assetService: assetService}
}

// Upload handles file upload via multipart form
// POST /api/v1/assets/upload
func (h *AssetHandler) Upload(c *gin.Context) {
	// Get file from form
	file, header, err := c.Request.FormFile("file")
	if err != nil {
		response.BadRequest(c, "No file provided", err.Error())
		return
	}
	defer file.Close()

	// Get kind from form
	kindStr := c.PostForm("kind")
	if kindStr == "" {
		response.BadRequest(c, "Kind is required", nil)
		return
	}
	kind := asset.Kind(kindStr)

	// Get optional fields
	var refID *string
	if ref := c.PostForm("ref_id"); ref != "" {
		refID = &ref
	}

	var title *string
	if t := c.PostForm("title"); t != "" {
		title = &t
	}

	// Get current user
	userID := middleware.GetUserID(c)

	// Detect MIME type from header
	mimeType := header.Header.Get("Content-Type")
	if mimeType == "" {
		mimeType = "application/octet-stream"
	}

	req := &appAsset.UploadRequest{
		File:       file,
		Filename:   header.Filename,
		MimeType:   mimeType,
		FileSize:   header.Size,
		Kind:       kind,
		RefID:      refID,
		Title:      title,
		UploadedBy: &userID,
	}

	result, err := h.assetService.Upload(c.Request.Context(), req)
	if err != nil {
		handleAssetError(c, err)
		return
	}

	response.Created(c, "File uploaded successfully", result)
}

// Show retrieves an asset by ID
// GET /api/v1/assets/:id
func (h *AssetHandler) Show(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		response.BadRequest(c, "Asset ID is required", nil)
		return
	}

	result, err := h.assetService.FindByID(c.Request.Context(), id)
	if err != nil {
		handleAssetError(c, err)
		return
	}

	response.OK(c, "Asset retrieved", result)
}

// ListByRef retrieves assets by reference ID
// GET /api/v1/assets/by-ref?ref_id=xxx&kind=user_avatar
func (h *AssetHandler) ListByRef(c *gin.Context) {
	refID := c.Query("ref_id")
	if refID == "" {
		response.BadRequest(c, "ref_id is required", nil)
		return
	}

	req := &appAsset.ListByRefRequest{
		RefID: refID,
	}

	if kindStr := c.Query("kind"); kindStr != "" {
		kind := asset.Kind(kindStr)
		req.Kind = &kind
	}

	result, err := h.assetService.FindByRef(c.Request.Context(), req)
	if err != nil {
		handleAssetError(c, err)
		return
	}

	response.OK(c, "Assets retrieved", result)
}

// GetUserAvatar retrieves user avatar URL
// GET /api/v1/assets/user/:user_id/avatar
func (h *AssetHandler) GetUserAvatar(c *gin.Context) {
	userIDStr := c.Param("user_id")
	userID, err := strconv.ParseUint(userIDStr, 10, 64)
	if err != nil {
		response.BadRequest(c, "Invalid user ID", nil)
		return
	}

	url, err := h.assetService.GetUserAvatarURL(c.Request.Context(), userID)
	if err != nil {
		handleAssetError(c, err)
		return
	}

	response.OK(c, "Avatar URL retrieved", gin.H{
		"url": url,
	})
}

// Delete removes an asset
// DELETE /api/v1/assets/:id
func (h *AssetHandler) Delete(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		response.BadRequest(c, "Asset ID is required", nil)
		return
	}

	if err := h.assetService.Delete(c.Request.Context(), id); err != nil {
		handleAssetError(c, err)
		return
	}

	response.OK(c, "Asset deleted successfully", nil)
}

// LinkToRef links an asset to a reference
// POST /api/v1/assets/:id/link
func (h *AssetHandler) LinkToRef(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		response.BadRequest(c, "Asset ID is required", nil)
		return
	}

	var req struct {
		RefID string `json:"ref_id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "Invalid request body", err.Error())
		return
	}

	if err := h.assetService.LinkToRef(c.Request.Context(), id, req.RefID); err != nil {
		handleAssetError(c, err)
		return
	}

	response.OK(c, "Asset linked successfully", nil)
}

// Serve serves the actual file (for local storage)
// GET /assets/*path
func (h *AssetHandler) Serve(c *gin.Context) {
	// This route is handled by static file serving
	// See router setup for static file handler
	response.NotFound(c, "Asset not found")
}

func handleAssetError(c *gin.Context, err error) {
	switch {
	case errors.Is(err, appAsset.ErrAssetNotFound):
		response.NotFound(c, "Asset not found")
	case errors.Is(err, appAsset.ErrInvalidMimeType):
		response.BadRequest(c, err.Error(), nil)
	case errors.Is(err, appAsset.ErrFileTooLarge):
		response.BadRequest(c, err.Error(), nil)
	case errors.Is(err, appAsset.ErrInvalidKind):
		response.BadRequest(c, "Invalid asset kind", nil)
	case errors.Is(err, appAsset.ErrStorageFailed):
		response.InternalError(c, "Failed to store file")
	case errors.Is(err, appAsset.ErrDeleteFailed):
		response.InternalError(c, "Failed to delete file")
	default:
		response.InternalError(c, "")
	}
}
