package response

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type Response struct {
	Success bool        `json:"success"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
	Errors  interface{} `json:"errors,omitempty"`
}

type PaginatedResponse struct {
	Success bool        `json:"success"`
	Message string      `json:"message"`
	Data    interface{} `json:"data"`
	Meta    *Meta       `json:"meta"`
	Links   *Links      `json:"links,omitempty"`
}

type Meta struct {
	CurrentPage int   `json:"current_page"`
	From        int   `json:"from"`
	LastPage    int   `json:"last_page"`
	PerPage     int   `json:"per_page"`
	To          int   `json:"to"`
	Total       int64 `json:"total"`
}

type Links struct {
	First string `json:"first,omitempty"`
	Last  string `json:"last,omitempty"`
	Prev  string `json:"prev,omitempty"`
	Next  string `json:"next,omitempty"`
}

// Success responses
func OK(c *gin.Context, message string, data interface{}) {
	c.JSON(http.StatusOK, Response{
		Success: true,
		Message: message,
		Data:    data,
	})
}

func Created(c *gin.Context, message string, data interface{}) {
	c.JSON(http.StatusCreated, Response{
		Success: true,
		Message: message,
		Data:    data,
	})
}

func NoContent(c *gin.Context) {
	c.Status(http.StatusNoContent)
}

func Paginated(c *gin.Context, message string, data interface{}, meta *Meta) {
	c.JSON(http.StatusOK, PaginatedResponse{
		Success: true,
		Message: message,
		Data:    data,
		Meta:    meta,
	})
}

// Error responses
func BadRequest(c *gin.Context, message string, errors interface{}) {
	c.JSON(http.StatusBadRequest, Response{
		Success: false,
		Message: message,
		Errors:  errors,
	})
}

func Unauthorized(c *gin.Context, message string) {
	if message == "" {
		message = "Unauthorized"
	}
	c.JSON(http.StatusUnauthorized, Response{
		Success: false,
		Message: message,
	})
}

func Forbidden(c *gin.Context, message string) {
	if message == "" {
		message = "Forbidden"
	}
	c.JSON(http.StatusForbidden, Response{
		Success: false,
		Message: message,
	})
}

func NotFound(c *gin.Context, message string) {
	if message == "" {
		message = "Resource not found"
	}
	c.JSON(http.StatusNotFound, Response{
		Success: false,
		Message: message,
	})
}

func Conflict(c *gin.Context, message string) {
	c.JSON(http.StatusConflict, Response{
		Success: false,
		Message: message,
	})
}

func ValidationError(c *gin.Context, errors interface{}) {
	c.JSON(http.StatusUnprocessableEntity, Response{
		Success: false,
		Message: "Validation failed",
		Errors:  errors,
	})
}

func InternalError(c *gin.Context, message string) {
	if message == "" {
		message = "Internal server error"
	}
	c.JSON(http.StatusInternalServerError, Response{
		Success: false,
		Message: message,
	})
}

func TooManyRequests(c *gin.Context, message string) {
	if message == "" {
		message = "Too many requests"
	}
	c.JSON(http.StatusTooManyRequests, Response{
		Success: false,
		Message: message,
	})
}

// Error helper for common domain errors
func HandleError(c *gin.Context, err error) {
	switch err.Error() {
	case "user not found", "role not found", "master type not found", "master value not found":
		NotFound(c, err.Error())
	case "email already exists", "role name already exists", "code already exists":
		Conflict(c, err.Error())
	case "invalid email or password", "invalid or expired token":
		Unauthorized(c, err.Error())
	case "user account is not active", "user account is suspended":
		Forbidden(c, err.Error())
	case "cannot delete system role", "cannot delete role with assigned users", "cannot delete your own account":
		BadRequest(c, err.Error(), nil)
	default:
		InternalError(c, "")
	}
}
