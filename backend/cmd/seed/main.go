package main

import (
	"context"
	"fmt"
	"os"

	"guyub/internal/domain/role"
	"guyub/internal/domain/user"
	infraAuth "guyub/internal/infrastructure/auth"
	"guyub/internal/infrastructure/persistence/mysql"
	"guyub/pkg/config"
	"guyub/pkg/logger"

	"gorm.io/gorm"
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

	// Initialize database connection
	db, err := mysql.NewConnection(&cfg.Database)
	if err != nil {
		logger.Fatalf("Failed to connect to database: %v", err)
	}
	defer mysql.Close(db)

	ctx := context.Background()

	// Seed permissions
	logger.Info("Seeding permissions...")
	if err := seedPermissions(ctx, db); err != nil {
		logger.Fatalf("Failed to seed permissions: %v", err)
	}

	// Seed roles
	logger.Info("Seeding roles...")
	if err := seedRoles(ctx, db); err != nil {
		logger.Fatalf("Failed to seed roles: %v", err)
	}

	// Assign all permissions to super_admin
	logger.Info("Assigning permissions to roles...")
	if err := assignRolePermissions(ctx, db); err != nil {
		logger.Fatalf("Failed to assign role permissions: %v", err)
	}

	// Seed admin user
	logger.Info("Seeding admin user...")
	if err := seedAdminUser(ctx, db); err != nil {
		logger.Fatalf("Failed to seed admin user: %v", err)
	}

	// Seed sample master data
	logger.Info("Seeding master data...")
	if err := seedMasterData(ctx, db); err != nil {
		logger.Fatalf("Failed to seed master data: %v", err)
	}

	// Seed sample users
	logger.Info("Seeding sample users...")
	if err := seedSampleUsers(ctx, db); err != nil {
		logger.Fatalf("Failed to seed sample users: %v", err)
	}

	logger.Info("Seeding completed successfully!")
}

func seedPermissions(ctx context.Context, db *gorm.DB) error {
	permissions := []role.Permission{
		// Users
		{Name: "users.view", GuardName: "web"},
		{Name: "users.create", GuardName: "web"},
		{Name: "users.edit", GuardName: "web"},
		{Name: "users.delete", GuardName: "web"},
		{Name: "users.export", GuardName: "web"},
		{Name: "users.import", GuardName: "web"},

		// Roles
		{Name: "roles.view", GuardName: "web"},
		{Name: "roles.create", GuardName: "web"},
		{Name: "roles.edit", GuardName: "web"},
		{Name: "roles.delete", GuardName: "web"},
		{Name: "roles.permissions", GuardName: "web"},

		// Master Data
		{Name: "master.view", GuardName: "web"},
		{Name: "master.create", GuardName: "web"},
		{Name: "master.edit", GuardName: "web"},
		{Name: "master.delete", GuardName: "web"},

		// Audit
		{Name: "audit.view", GuardName: "web"},
		{Name: "audit.export", GuardName: "web"},

		// Activity
		{Name: "activity.view", GuardName: "web"},

		// Analytics
		{Name: "analytics.view", GuardName: "web"},
		{Name: "analytics.charts", GuardName: "web"},

		// Settings
		{Name: "settings.view", GuardName: "web"},
		{Name: "settings.edit", GuardName: "web"},
	}

	for _, p := range permissions {
		var existing role.Permission
		if err := db.Where("name = ?", p.Name).First(&existing).Error; err == gorm.ErrRecordNotFound {
			if err := db.Create(&p).Error; err != nil {
				return err
			}
		}
	}

	return nil
}

func seedRoles(ctx context.Context, db *gorm.DB) error {
	roles := []struct {
		Name        string
		Description string
		Level       int
	}{
		{Name: "super_admin", Description: "Full system access", Level: 100},
		{Name: "admin", Description: "Administrative access", Level: 90},
		{Name: "manager", Description: "Manager access", Level: 70},
		{Name: "agent", Description: "Agent/Staff access", Level: 50},
		{Name: "guest", Description: "Limited guest access", Level: 10},
	}

	for _, r := range roles {
		var existing role.Role
		if err := db.Where("name = ?", r.Name).First(&existing).Error; err == gorm.ErrRecordNotFound {
			newRole := role.Role{
				Name:        r.Name,
				GuardName:   "web",
				Description: &r.Description,
				Level:       r.Level,
			}
			if err := db.Create(&newRole).Error; err != nil {
				return err
			}
		}
	}

	return nil
}

func assignRolePermissions(ctx context.Context, db *gorm.DB) error {
	// Get all permissions
	var permissions []role.Permission
	if err := db.Find(&permissions).Error; err != nil {
		return err
	}

	// Get super_admin role
	var superAdmin role.Role
	if err := db.Where("name = ?", "super_admin").First(&superAdmin).Error; err != nil {
		return err
	}

	// Assign all permissions to super_admin
	for _, p := range permissions {
		rhp := role.RoleHasPermission{
			RoleID:       superAdmin.ID,
			PermissionID: p.ID,
		}
		// Insert if not exists
		db.FirstOrCreate(&rhp, rhp)
	}

	// Get admin role and assign most permissions
	var admin role.Role
	if err := db.Where("name = ?", "admin").First(&admin).Error; err != nil {
		return err
	}

	adminPermissions := []string{
		"users.view", "users.create", "users.edit", "users.delete", "users.export", "users.import",
		"roles.view", "roles.create", "roles.edit",
		"master.view", "master.create", "master.edit", "master.delete",
		"audit.view", "audit.export",
		"activity.view",
		"analytics.view", "analytics.charts",
	}

	for _, permName := range adminPermissions {
		var perm role.Permission
		if err := db.Where("name = ?", permName).First(&perm).Error; err == nil {
			rhp := role.RoleHasPermission{
				RoleID:       admin.ID,
				PermissionID: perm.ID,
			}
			db.FirstOrCreate(&rhp, rhp)
		}
	}

	// Manager permissions
	var manager role.Role
	if err := db.Where("name = ?", "manager").First(&manager).Error; err != nil {
		return err
	}

	managerPermissions := []string{
		"users.view", "users.create", "users.edit",
		"roles.view",
		"master.view", "master.create", "master.edit",
		"audit.view",
		"activity.view",
		"analytics.view",
	}

	for _, permName := range managerPermissions {
		var perm role.Permission
		if err := db.Where("name = ?", permName).First(&perm).Error; err == nil {
			rhp := role.RoleHasPermission{
				RoleID:       manager.ID,
				PermissionID: perm.ID,
			}
			db.FirstOrCreate(&rhp, rhp)
		}
	}

	return nil
}

func seedAdminUser(ctx context.Context, db *gorm.DB) error {
	// Check if admin user exists
	var existingUser user.User
	if err := db.Where("email = ?", "admin@guyub.id").First(&existingUser).Error; err == nil {
		logger.Info("Admin user already exists")
		return nil
	}

	// Hash password
	passwordService := infraAuth.NewPasswordService()
	hashedPassword, err := passwordService.Hash("Admin@123")
	if err != nil {
		return err
	}

	// Create admin user
	adminUser := user.User{
		Name:     "Super Admin",
		Email:    "admin@guyub.id",
		Password: hashedPassword,
		Type:     user.TypeInternal,
		Status:   user.StatusActive,
	}

	if err := db.Create(&adminUser).Error; err != nil {
		return err
	}

	// Get super_admin role
	var superAdminRole role.Role
	if err := db.Where("name = ?", "super_admin").First(&superAdminRole).Error; err != nil {
		return err
	}

	// Assign role to user
	mhr := role.ModelHasRole{
		RoleID:    superAdminRole.ID,
		ModelType: "User",
		ModelID:   adminUser.ID,
	}

	return db.Create(&mhr).Error
}

func seedMasterData(ctx context.Context, db *gorm.DB) error {
	// Seed Gender
	genderType := struct {
		Code   string
		Name   string
		Values []struct{ Code, Name string }
	}{
		Code: "GENDER",
		Name: "Gender",
		Values: []struct{ Code, Name string }{
			{Code: "M", Name: "Male"},
			{Code: "F", Name: "Female"},
		},
	}

	var gender struct {
		ID uint64
	}
	if err := db.Table("app_master_types").Where("code = ?", genderType.Code).First(&gender).Error; err == gorm.ErrRecordNotFound {
		if err := db.Exec("INSERT INTO app_master_types (code, name, is_active, sort_order) VALUES (?, ?, 1, 1)", genderType.Code, genderType.Name).Error; err != nil {
			return err
		}
		db.Table("app_master_types").Where("code = ?", genderType.Code).First(&gender)

		for i, v := range genderType.Values {
			db.Exec("INSERT INTO app_master_values (type_id, code, name, is_active, sort_order) VALUES (?, ?, ?, 1, ?)", gender.ID, v.Code, v.Name, i+1)
		}
	}

	// Seed Marital Status
	maritalType := struct {
		Code   string
		Name   string
		Values []struct{ Code, Name string }
	}{
		Code: "MARITAL",
		Name: "Marital Status",
		Values: []struct{ Code, Name string }{
			{Code: "SINGLE", Name: "Single"},
			{Code: "MARRIED", Name: "Married"},
			{Code: "DIVORCED", Name: "Divorced"},
			{Code: "WIDOWED", Name: "Widowed"},
		},
	}

	var marital struct {
		ID uint64
	}
	if err := db.Table("app_master_types").Where("code = ?", maritalType.Code).First(&marital).Error; err == gorm.ErrRecordNotFound {
		if err := db.Exec("INSERT INTO app_master_types (code, name, is_active, sort_order) VALUES (?, ?, 1, 2)", maritalType.Code, maritalType.Name).Error; err != nil {
			return err
		}
		db.Table("app_master_types").Where("code = ?", maritalType.Code).First(&marital)

		for i, v := range maritalType.Values {
			db.Exec("INSERT INTO app_master_values (type_id, code, name, is_active, sort_order) VALUES (?, ?, ?, 1, ?)", marital.ID, v.Code, v.Name, i+1)
		}
	}

	// Seed Religion
	religionType := struct {
		Code   string
		Name   string
		Values []struct{ Code, Name string }
	}{
		Code: "RELIGION",
		Name: "Religion",
		Values: []struct{ Code, Name string }{
			{Code: "ISLAM", Name: "Islam"},
			{Code: "CHRISTIAN", Name: "Christian"},
			{Code: "CATHOLIC", Name: "Catholic"},
			{Code: "HINDU", Name: "Hindu"},
			{Code: "BUDDHA", Name: "Buddha"},
			{Code: "OTHER", Name: "Other"},
		},
	}

	var religion struct {
		ID uint64
	}
	if err := db.Table("app_master_types").Where("code = ?", religionType.Code).First(&religion).Error; err == gorm.ErrRecordNotFound {
		if err := db.Exec("INSERT INTO app_master_types (code, name, is_active, sort_order) VALUES (?, ?, 1, 3)", religionType.Code, religionType.Name).Error; err != nil {
			return err
		}
		db.Table("app_master_types").Where("code = ?", religionType.Code).First(&religion)

		for i, v := range religionType.Values {
			db.Exec("INSERT INTO app_master_values (type_id, code, name, is_active, sort_order) VALUES (?, ?, ?, 1, ?)", religion.ID, v.Code, v.Name, i+1)
		}
	}

	return nil
}

func seedSampleUsers(ctx context.Context, db *gorm.DB) error {
	// Hash password
	passwordService := infraAuth.NewPasswordService()
	hashedPassword, err := passwordService.Hash("Password@123")
	if err != nil {
		return err
	}

	// Get roles
	var adminRole, managerRole, agentRole role.Role
	if err := db.Where("name = ?", "admin").First(&adminRole).Error; err != nil {
		logger.Errorf("Failed to find admin role: %v", err)
	} else {
		logger.Infof("Found admin role with ID: %d", adminRole.ID)
	}
	if err := db.Where("name = ?", "manager").First(&managerRole).Error; err != nil {
		logger.Errorf("Failed to find manager role: %v", err)
	} else {
		logger.Infof("Found manager role with ID: %d", managerRole.ID)
	}
	if err := db.Where("name = ?", "agent").First(&agentRole).Error; err != nil {
		logger.Errorf("Failed to find agent role: %v", err)
	} else {
		logger.Infof("Found agent role with ID: %d", agentRole.ID)
	}

	sampleUsers := []struct {
		Name   string
		Email  string
		Type   user.Type
		Status user.Status
		RoleID uint64
	}{
		{Name: "John Admin", Email: "john@guyub.id", Type: user.TypeInternal, Status: user.StatusActive, RoleID: adminRole.ID},
		{Name: "Jane Manager", Email: "jane@guyub.id", Type: user.TypeInternal, Status: user.StatusActive, RoleID: managerRole.ID},
		{Name: "Bob Agent", Email: "bob@guyub.id", Type: user.TypeInternal, Status: user.StatusActive, RoleID: agentRole.ID},
		{Name: "Alice Agent", Email: "alice@guyub.id", Type: user.TypeInternal, Status: user.StatusActive, RoleID: agentRole.ID},
		{Name: "Charlie Member", Email: "charlie@gmail.com", Type: user.TypeCustomer, Status: user.StatusActive, RoleID: agentRole.ID},
		{Name: "Diana Member", Email: "diana@gmail.com", Type: user.TypeCustomer, Status: user.StatusActive, RoleID: agentRole.ID},
		{Name: "Eve Suspended", Email: "eve@gmail.com", Type: user.TypeCustomer, Status: user.StatusSuspended, RoleID: agentRole.ID},
		{Name: "Frank Inactive", Email: "frank@gmail.com", Type: user.TypeCustomer, Status: user.StatusInactive, RoleID: agentRole.ID},
	}

	for _, u := range sampleUsers {
		logger.Infof("Checking user: %s", u.Email)
		var existingUser user.User
		if err := db.Where("email = ?", u.Email).First(&existingUser).Error; err == nil {
			logger.Infof("User %s already exists, skipping", u.Email)
			continue // User already exists
		}

		logger.Infof("Creating user: %s with RoleID: %d", u.Email, u.RoleID)
		newUser := user.User{
			Name:     u.Name,
			Email:    u.Email,
			Password: hashedPassword,
			Type:     u.Type,
			Status:   u.Status,
		}

		if err := db.Create(&newUser).Error; err != nil {
			logger.Errorf("Failed to create user %s: %v", u.Email, err)
			continue
		}
		logger.Infof("Created user %s with ID: %d", u.Email, newUser.ID)

		// Assign role
		mhr := role.ModelHasRole{
			RoleID:    u.RoleID,
			ModelType: "User",
			ModelID:   newUser.ID,
		}
		if err := db.Create(&mhr).Error; err != nil {
			logger.Errorf("Failed to assign role to user %s: %v", u.Email, err)
		} else {
			logger.Infof("Assigned role %d to user %s", u.RoleID, u.Email)
		}
	}

	return nil
}
