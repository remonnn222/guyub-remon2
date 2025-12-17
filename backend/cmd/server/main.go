package main

import (
	"fmt"
	"os"
	"os/signal"
	"syscall"

	// Application layer
	appAuth "guyub/internal/application/auth"
	appMaster "guyub/internal/application/master"
	appRole "guyub/internal/application/role"
	appUser "guyub/internal/application/user"

	// Infrastructure layer
	infraAuth "guyub/internal/infrastructure/auth"
	"guyub/internal/infrastructure/persistence/mysql"

	// Presentation layer
	"guyub/internal/presentation/http/handler"
	"guyub/internal/presentation/http/middleware"
	"guyub/internal/presentation/router"

	// Packages
	"guyub/pkg/config"
	"guyub/pkg/logger"
)

func main() {
	// Load configuration
	cfg, err := config.Load()
	if err != nil {
		fmt.Printf("Failed to load configuration: %v\n", err)
		os.Exit(1)
	}

	// Initialize logger
	if err := logger.Init(cfg.Log.Level, cfg.Log.Format); err != nil {
		fmt.Printf("Failed to initialize logger: %v\n", err)
		os.Exit(1)
	}
	defer logger.Sync()

	logger.Infof("Starting %s in %s mode", cfg.App.Name, cfg.App.Env)

	// Initialize database connection
	db, err := mysql.NewConnection(&cfg.Database)
	if err != nil {
		logger.Fatalf("Failed to connect to database: %v", err)
	}
	defer func() {
		if err := mysql.Close(db); err != nil {
			logger.Errorf("Failed to close database connection: %v", err)
		}
	}()

	// Initialize infrastructure services
	jwtService := infraAuth.NewJWTService(&cfg.JWT)
	passwordService := infraAuth.NewPasswordService()

	// Initialize repositories
	userRepo := mysql.NewUserRepository(db)
	roleRepo := mysql.NewRoleRepository(db)
	permissionRepo := mysql.NewPermissionRepository(db)
	masterTypeRepo := mysql.NewMasterTypeRepository(db)
	masterValueRepo := mysql.NewMasterValueRepository(db)
	activityRepo := mysql.NewActivityRepository(db)
	auditRepo := mysql.NewAuditRepository(db)

	// Initialize application services
	authService := appAuth.NewService(userRepo, activityRepo, jwtService, passwordService)
	userService := appUser.NewService(userRepo, auditRepo, passwordService)
	roleService := appRole.NewService(roleRepo, permissionRepo)
	masterService := appMaster.NewService(masterTypeRepo, masterValueRepo)

	// Initialize middleware
	authMiddleware := middleware.NewAuthMiddleware(jwtService)

	// Initialize handlers
	authHandler := handler.NewAuthHandler(authService)
	userHandler := handler.NewUserHandler(userService)
	roleHandler := handler.NewRoleHandler(roleService)
	masterHandler := handler.NewMasterHandler(masterService)

	// Initialize router
	r := router.New(
		authMiddleware,
		authHandler,
		userHandler,
		roleHandler,
		masterHandler,
		&router.Config{
			CORSAllowedOrigins: cfg.CORS.AllowedOrigins,
			CORSAllowedMethods: cfg.CORS.AllowedMethods,
			CORSAllowedHeaders: cfg.CORS.AllowedHeaders,
		},
	)

	engine := r.Setup()

	// Start server
	addr := fmt.Sprintf(":%d", cfg.App.Port)
	logger.Infof("Server starting on %s", addr)

	// Graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		if err := engine.Run(addr); err != nil {
			logger.Fatalf("Failed to start server: %v", err)
		}
	}()

	<-quit
	logger.Info("Shutting down server...")
}
