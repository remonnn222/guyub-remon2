package router

import (
	"guyub/internal/presentation/http/handler"
	"guyub/internal/presentation/http/middleware"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

type Router struct {
	engine           *gin.Engine
	authMiddleware   *middleware.AuthMiddleware
	authHandler      *handler.AuthHandler
	userHandler      *handler.UserHandler
	roleHandler      *handler.RoleHandler
	masterHandler    *handler.MasterHandler
	analyticsHandler *handler.AnalyticsHandler
	activityHandler  *handler.ActivityHandler
	auditHandler     *handler.AuditHandler
	assetHandler     *handler.AssetHandler
	storagePath      string
}

type Config struct {
	CORSAllowedOrigins []string
	CORSAllowedMethods []string
	CORSAllowedHeaders []string
	StoragePath        string
}

func New(
	authMiddleware *middleware.AuthMiddleware,
	authHandler *handler.AuthHandler,
	userHandler *handler.UserHandler,
	roleHandler *handler.RoleHandler,
	masterHandler *handler.MasterHandler,
	analyticsHandler *handler.AnalyticsHandler,
	activityHandler *handler.ActivityHandler,
	auditHandler *handler.AuditHandler,
	assetHandler *handler.AssetHandler,
	cfg *Config,
) *Router {
	engine := gin.New()

	// Global middleware
	engine.Use(gin.Recovery())
	engine.Use(gin.Logger())

	// CORS
	engine.Use(cors.New(cors.Config{
		AllowOrigins:     cfg.CORSAllowedOrigins,
		AllowMethods:     cfg.CORSAllowedMethods,
		AllowHeaders:     cfg.CORSAllowedHeaders,
		AllowCredentials: true,
	}))

	return &Router{
		engine:           engine,
		authMiddleware:   authMiddleware,
		authHandler:      authHandler,
		userHandler:      userHandler,
		roleHandler:      roleHandler,
		masterHandler:    masterHandler,
		analyticsHandler: analyticsHandler,
		activityHandler:  activityHandler,
		auditHandler:     auditHandler,
		assetHandler:     assetHandler,
		storagePath:      cfg.StoragePath,
	}
}

func (r *Router) Setup() *gin.Engine {
	// Health check
	r.engine.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	// API v1
	v1 := r.engine.Group("/api/v1")
	{
		// Auth routes (public)
		auth := v1.Group("/auth")
		{
			auth.POST("/login", r.authHandler.Login)
			auth.POST("/refresh", r.authHandler.Refresh)
		}

		// Protected routes
		protected := v1.Group("")
		protected.Use(r.authMiddleware.Authenticate())
		{
			// Auth (protected)
			protectedAuth := protected.Group("/auth")
			{
				protectedAuth.POST("/logout", r.authHandler.Logout)
				protectedAuth.GET("/me", r.authHandler.Me)
			}

			// Users
			users := protected.Group("/users")
			{
				users.GET("", middleware.RequirePermission("users.view"), r.userHandler.List)
				users.POST("", middleware.RequirePermission("users.create"), r.userHandler.Create)
				users.GET("/:id", middleware.RequirePermission("users.view"), r.userHandler.Show)
				users.PUT("/:id", middleware.RequirePermission("users.edit"), r.userHandler.Update)
				users.DELETE("/:id", middleware.RequirePermission("users.delete"), r.userHandler.Delete)
				users.POST("/:id/restore", middleware.RequirePermission("users.delete"), r.userHandler.Restore)
				users.DELETE("/:id/force", middleware.RequireSuperAdmin(), r.userHandler.ForceDelete)

				// Bulk operations
				users.POST("/bulk/delete", middleware.RequirePermission("users.delete"), r.userHandler.BulkDelete)
				users.POST("/bulk/restore", middleware.RequirePermission("users.delete"), r.userHandler.BulkRestore)
				users.POST("/bulk/assign-role", middleware.RequirePermission("users.edit"), r.userHandler.BulkAssignRole)
			}

			// Roles
			roles := protected.Group("/roles")
			{
				roles.GET("", middleware.RequirePermission("roles.view"), r.roleHandler.List)
				roles.POST("", middleware.RequirePermission("roles.create"), r.roleHandler.Create)
				roles.GET("/:id", middleware.RequirePermission("roles.view"), r.roleHandler.Show)
				roles.PUT("/:id", middleware.RequirePermission("roles.edit"), r.roleHandler.Update)
				roles.DELETE("/:id", middleware.RequirePermission("roles.delete"), r.roleHandler.Delete)
				roles.PUT("/:id/permissions", middleware.RequirePermission("roles.permissions"), r.roleHandler.SyncPermissions)
			}

			// Permissions
			permissions := protected.Group("/permissions")
			{
				permissions.GET("", middleware.RequirePermission("roles.view"), r.roleHandler.ListPermissions)
				permissions.GET("/grouped", middleware.RequirePermission("roles.view"), r.roleHandler.ListPermissionsGrouped)
			}

			// Master Data
			master := protected.Group("/master")
			{
				// Types
				types := master.Group("/types")
				{
					types.GET("", middleware.RequirePermission("master.view"), r.masterHandler.ListTypes)
					types.POST("", middleware.RequirePermission("master.create"), r.masterHandler.CreateType)
					types.GET("/:id", middleware.RequirePermission("master.view"), r.masterHandler.ShowType)
					types.PUT("/:id", middleware.RequirePermission("master.edit"), r.masterHandler.UpdateType)
					types.DELETE("/:id", middleware.RequirePermission("master.delete"), r.masterHandler.DeleteType)
					types.POST("/:id/restore", middleware.RequirePermission("master.delete"), r.masterHandler.RestoreType)
					types.GET("/:id/values", middleware.RequirePermission("master.view"), r.masterHandler.ListValuesByTypeID)
				}

				// Values
				values := master.Group("/values")
				{
					values.POST("", middleware.RequirePermission("master.create"), r.masterHandler.CreateValue)
					values.GET("/:id", middleware.RequirePermission("master.view"), r.masterHandler.ShowValue)
					values.PUT("/:id", middleware.RequirePermission("master.edit"), r.masterHandler.UpdateValue)
					values.DELETE("/:id", middleware.RequirePermission("master.delete"), r.masterHandler.DeleteValue)
				}

				// Cascading dropdown
				master.GET("/cascade/:type_code", middleware.RequirePermission("master.view"), r.masterHandler.GetCascading)
				master.GET("/by-code/:type_code/values", middleware.RequirePermission("master.view"), r.masterHandler.ListValuesByTypeCode)
			}

			// Analytics
			analyticsGroup := protected.Group("/analytics")
			{
				analyticsGroup.GET("/dashboard", r.analyticsHandler.Dashboard)
			}

			// Activity Logs
			activityGroup := protected.Group("/activity")
			{
				activityGroup.GET("", middleware.RequirePermission("activity.view"), r.activityHandler.List)
				activityGroup.GET("/stats", middleware.RequirePermission("activity.view"), r.activityHandler.Stats)
				activityGroup.GET("/:id", middleware.RequirePermission("activity.view"), r.activityHandler.Show)
				activityGroup.GET("/user/:user_id/stats", middleware.RequirePermission("activity.view"), r.activityHandler.UserStats)
			}

			// Audit Logs
			auditGroup := protected.Group("/audit")
			{
				auditGroup.GET("", middleware.RequirePermission("audit.view"), r.auditHandler.List)
				auditGroup.GET("/stats", middleware.RequirePermission("audit.view"), r.auditHandler.Stats)
				auditGroup.GET("/:id", middleware.RequirePermission("audit.view"), r.auditHandler.Show)
			}

			// Assets
			assets := protected.Group("/assets")
			{
				assets.POST("/upload", r.assetHandler.Upload)
				assets.GET("/by-ref", r.assetHandler.ListByRef)
				assets.GET("/user/:user_id/avatar", r.assetHandler.GetUserAvatar)
				assets.GET("/:id", r.assetHandler.Show)
				assets.DELETE("/:id", r.assetHandler.Delete)
				assets.POST("/:id/link", r.assetHandler.LinkToRef)
			}
		}
	}

	// Static file serving for uploaded assets
	r.engine.Static("/assets", r.storagePath)

	return r.engine
}
