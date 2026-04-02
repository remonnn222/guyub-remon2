package main

import (
	"fmt"
	"os"
	"os/signal"
	"syscall"

	// Application layer
	appActivity "guyub/internal/application/activity"
	appAnalytics "guyub/internal/application/analytics"
	appAsset "guyub/internal/application/asset"
	appAudit "guyub/internal/application/audit"
	appAuth "guyub/internal/application/auth"
	appMaster "guyub/internal/application/master"
	appNotification "guyub/internal/application/notification"
	appRole "guyub/internal/application/role"
	appUser "guyub/internal/application/user"

	// Infrastructure layer
	infraAuth "guyub/internal/infrastructure/auth"
	infraNotification "guyub/internal/infrastructure/notification"
	"guyub/internal/infrastructure/persistence/mysql"
	"guyub/internal/infrastructure/storage"

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
	storageService := storage.NewLocalStorage(&cfg.Storage, cfg.App.URL)

	// Initialize FCM client
	fcmClient, err := infraNotification.NewFCMClient(cfg.Firebase.ServiceAccountPath)
	if err != nil {
		logger.Fatalf("Failed to initialize FCM client: %v", err)
	}

	// Initialize repositories
	userRepo := mysql.NewUserRepository(db)
	roleRepo := mysql.NewRoleRepository(db)
	permissionRepo := mysql.NewPermissionRepository(db)
	masterTypeRepo := mysql.NewMasterTypeRepository(db)
	masterValueRepo := mysql.NewMasterValueRepository(db)
	activityRepo := mysql.NewActivityRepository(db)
	auditRepo := mysql.NewAuditRepository(db)
	assetRepo := mysql.NewAssetRepository(db)
	notificationRepo := mysql.NewNotificationRepository(db)

	// Initialize application services
	authService := appAuth.NewService(userRepo, activityRepo, assetRepo, storageService, jwtService, passwordService)
	userService := appUser.NewService(userRepo, auditRepo, assetRepo, storageService, passwordService)
	roleService := appRole.NewService(roleRepo, permissionRepo)
	masterService := appMaster.NewService(masterTypeRepo, masterValueRepo)
	analyticsService := appAnalytics.NewService(userRepo, roleRepo, permissionRepo, activityRepo)
	activityService := appActivity.NewService(activityRepo)
	auditService := appAudit.NewService(auditRepo)
	assetService := appAsset.NewService(assetRepo, storageService)
	notificationService := appNotification.NewService(notificationRepo, userRepo, fcmClient)

	// Initialize middleware
	authMiddleware := middleware.NewAuthMiddleware(jwtService)

	// Initialize handlers
	authHandler := handler.NewAuthHandler(authService)
	userHandler := handler.NewUserHandler(userService)
	roleHandler := handler.NewRoleHandler(roleService)
	masterHandler := handler.NewMasterHandler(masterService)
	analyticsHandler := handler.NewAnalyticsHandler(analyticsService)
	activityHandler := handler.NewActivityHandler(activityService)
	auditHandler := handler.NewAuditHandler(auditService)
	assetHandler := handler.NewAssetHandler(assetService)
	notificationHandler := handler.NewNotificationHandler(notificationService)

	// Initialize router
	r := router.New(
		authMiddleware,
		authHandler,
		userHandler,
		roleHandler,
		masterHandler,
		analyticsHandler,
		activityHandler,
		auditHandler,
		assetHandler,
		notificationHandler,
		&router.Config{
			CORSAllowedOrigins: cfg.CORS.AllowedOrigins,
			CORSAllowedMethods: cfg.CORS.AllowedMethods,
			CORSAllowedHeaders: cfg.CORS.AllowedHeaders,
			StoragePath:        cfg.Storage.Path,
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
