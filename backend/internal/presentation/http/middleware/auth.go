package middleware

import (
	"strings"

	"guyub/internal/infrastructure/auth"
	"guyub/internal/presentation/http/response"

	"github.com/gin-gonic/gin"
)

const (
	AuthUserKey        = "auth_user"
	AuthUserIDKey      = "auth_user_id"
	AuthUserEmailKey   = "auth_user_email"
	AuthUserRolesKey   = "auth_user_roles"
	AuthUserPermsKey   = "auth_user_permissions"
)

type AuthMiddleware struct {
	jwtService *auth.JWTService
}

func NewAuthMiddleware(jwtService *auth.JWTService) *AuthMiddleware {
	return &AuthMiddleware{jwtService: jwtService}
}

func (m *AuthMiddleware) Authenticate() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			response.Unauthorized(c, "Missing authorization header")
			c.Abort()
			return
		}

		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
			response.Unauthorized(c, "Invalid authorization header format")
			c.Abort()
			return
		}

		token := parts[1]
		claims, err := m.jwtService.ValidateAccessToken(token)
		if err != nil {
			if err == auth.ErrExpiredToken {
				response.Unauthorized(c, "Token has expired")
			} else {
				response.Unauthorized(c, "Invalid token")
			}
			c.Abort()
			return
		}

		// Set user context
		c.Set(AuthUserIDKey, claims.UserID)
		c.Set(AuthUserEmailKey, claims.Email)
		c.Set(AuthUserRolesKey, claims.Roles)
		c.Set(AuthUserPermsKey, claims.Permissions)
		c.Set(AuthUserKey, claims)

		c.Next()
	}
}

func (m *AuthMiddleware) Optional() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.Next()
			return
		}

		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
			c.Next()
			return
		}

		token := parts[1]
		claims, err := m.jwtService.ValidateAccessToken(token)
		if err != nil {
			c.Next()
			return
		}

		c.Set(AuthUserIDKey, claims.UserID)
		c.Set(AuthUserEmailKey, claims.Email)
		c.Set(AuthUserRolesKey, claims.Roles)
		c.Set(AuthUserPermsKey, claims.Permissions)
		c.Set(AuthUserKey, claims)

		c.Next()
	}
}

// Helper functions to get auth context
func GetUserID(c *gin.Context) uint64 {
	if id, exists := c.Get(AuthUserIDKey); exists {
		return id.(uint64)
	}
	return 0
}

func GetUserEmail(c *gin.Context) string {
	if email, exists := c.Get(AuthUserEmailKey); exists {
		return email.(string)
	}
	return ""
}

func GetUserRoles(c *gin.Context) []string {
	if roles, exists := c.Get(AuthUserRolesKey); exists {
		return roles.([]string)
	}
	return nil
}

func GetUserPermissions(c *gin.Context) []string {
	if perms, exists := c.Get(AuthUserPermsKey); exists {
		return perms.([]string)
	}
	return nil
}

func IsSuperAdmin(c *gin.Context) bool {
	roles := GetUserRoles(c)
	for _, role := range roles {
		if role == "super_admin" {
			return true
		}
	}
	return false
}

func HasRole(c *gin.Context, roleName string) bool {
	roles := GetUserRoles(c)
	for _, role := range roles {
		if role == roleName {
			return true
		}
	}
	return false
}

func HasPermission(c *gin.Context, permission string) bool {
	if IsSuperAdmin(c) {
		return true
	}

	permissions := GetUserPermissions(c)
	for _, p := range permissions {
		if p == permission {
			return true
		}
	}
	return false
}

func HasAnyPermission(c *gin.Context, permissions []string) bool {
	if IsSuperAdmin(c) {
		return true
	}

	userPerms := GetUserPermissions(c)
	for _, required := range permissions {
		for _, p := range userPerms {
			if p == required {
				return true
			}
		}
	}
	return false
}

func GetClientIP(c *gin.Context) string {
	ip := c.ClientIP()
	if ip == "" {
		ip = c.GetHeader("X-Forwarded-For")
		if ip == "" {
			ip = c.GetHeader("X-Real-IP")
		}
	}
	return ip
}

func GetUserAgent(c *gin.Context) string {
	return c.GetHeader("User-Agent")
}
