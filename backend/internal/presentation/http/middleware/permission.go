package middleware

import (
	"guyub/internal/presentation/http/response"

	"github.com/gin-gonic/gin"
)

// RequirePermission creates middleware that checks for a single permission
func RequirePermission(permission string) gin.HandlerFunc {
	return func(c *gin.Context) {
		if !HasPermission(c, permission) {
			response.Forbidden(c, "You don't have permission to perform this action")
			c.Abort()
			return
		}
		c.Next()
	}
}

// RequireAnyPermission creates middleware that checks for any of the given permissions
func RequireAnyPermission(permissions ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
		if !HasAnyPermission(c, permissions) {
			response.Forbidden(c, "You don't have permission to perform this action")
			c.Abort()
			return
		}
		c.Next()
	}
}

// RequireRole creates middleware that checks for a specific role
func RequireRole(role string) gin.HandlerFunc {
	return func(c *gin.Context) {
		if !HasRole(c, role) {
			response.Forbidden(c, "You don't have the required role")
			c.Abort()
			return
		}
		c.Next()
	}
}

// RequireSuperAdmin creates middleware that only allows super_admin
func RequireSuperAdmin() gin.HandlerFunc {
	return func(c *gin.Context) {
		if !IsSuperAdmin(c) {
			response.Forbidden(c, "This action requires super admin privileges")
			c.Abort()
			return
		}
		c.Next()
	}
}
