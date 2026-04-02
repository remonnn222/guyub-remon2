package config

import (
	"strings"
	"time"

	"github.com/spf13/viper"
)

type Config struct {
	App      AppConfig
	Database DatabaseConfig
	JWT      JWTConfig
	Storage  StorageConfig
	CORS     CORSConfig
	Log      LogConfig
	Firebase FirebaseConfig
}

type AppConfig struct {
	Name  string
	Env   string
	Port  int
	URL   string
	Debug bool
}

type DatabaseConfig struct {
	Host            string
	Port            int
	Database        string
	Username        string
	Password        string
	MaxOpenConns    int
	MaxIdleConns    int
	ConnMaxLifetime time.Duration
}

type JWTConfig struct {
	Secret        string
	Expiry        time.Duration
	RefreshExpiry time.Duration
}

type StorageConfig struct {
	Driver string
	Path   string
}

type CORSConfig struct {
	AllowedOrigins []string
	AllowedMethods []string
	AllowedHeaders []string
}

type LogConfig struct {
	Level  string
	Format string
}

type FirebaseConfig struct {
	ServiceAccountPath string
	ProjectID          string
}

func Load() (*Config, error) {
	viper.SetConfigName("config")
	viper.SetConfigType("yaml")
	viper.AddConfigPath("./config")
	viper.AddConfigPath(".")

	// Environment variables
	viper.AutomaticEnv()
	viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))

	// Set defaults
	setDefaults()

	if err := viper.ReadInConfig(); err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
			return nil, err
		}
	}

	config := &Config{
		App: AppConfig{
			Name:  viper.GetString("app.name"),
			Env:   viper.GetString("app.env"),
			Port:  viper.GetInt("app.port"),
			URL:   viper.GetString("app.url"),
			Debug: viper.GetBool("app.debug"),
		},
		Database: DatabaseConfig{
			Host:            viper.GetString("database.host"),
			Port:            viper.GetInt("database.port"),
			Database:        viper.GetString("database.database"),
			Username:        viper.GetString("database.username"),
			Password:        viper.GetString("database.password"),
			MaxOpenConns:    viper.GetInt("database.max_open_conns"),
			MaxIdleConns:    viper.GetInt("database.max_idle_conns"),
			ConnMaxLifetime: viper.GetDuration("database.conn_max_lifetime"),
		},
		JWT: JWTConfig{
			Secret:        viper.GetString("jwt.secret"),
			Expiry:        viper.GetDuration("jwt.expiry"),
			RefreshExpiry: viper.GetDuration("jwt.refresh_expiry"),
		},
		Storage: StorageConfig{
			Driver: viper.GetString("storage.driver"),
			Path:   viper.GetString("storage.path"),
		},
		CORS: CORSConfig{
			AllowedOrigins: viper.GetStringSlice("cors.allowed_origins"),
			AllowedMethods: viper.GetStringSlice("cors.allowed_methods"),
			AllowedHeaders: viper.GetStringSlice("cors.allowed_headers"),
		},
		Log: LogConfig{
			Level:  viper.GetString("log.level"),
			Format: viper.GetString("log.format"),
		},
		Firebase: FirebaseConfig{
			ServiceAccountPath: viper.GetString("firebase.service_account_path"),
			ProjectID:          viper.GetString("firebase.project_id"),
		},
	}

	return config, nil
}

func setDefaults() {
	// App defaults
	viper.SetDefault("app.name", "Guyub-Platform")
	viper.SetDefault("app.env", "development")
	viper.SetDefault("app.port", 8080)
	viper.SetDefault("app.url", "http://localhost:8080")
	viper.SetDefault("app.debug", true)

	// Database defaults
	viper.SetDefault("database.host", "localhost")
	viper.SetDefault("database.port", 3306)
	viper.SetDefault("database.database", "guyub")
	viper.SetDefault("database.username", "root")
	viper.SetDefault("database.password", "")
	viper.SetDefault("database.max_open_conns", 25)
	viper.SetDefault("database.max_idle_conns", 5)
	viper.SetDefault("database.conn_max_lifetime", "5m")

	// JWT defaults
	viper.SetDefault("jwt.secret", "your-256-bit-secret-change-in-production")
	viper.SetDefault("jwt.expiry", "1h")
	viper.SetDefault("jwt.refresh_expiry", "168h") // 7 days

	// Storage defaults
	viper.SetDefault("storage.driver", "local")
	viper.SetDefault("storage.path", "./storage/uploads")

	// CORS defaults
	viper.SetDefault("cors.allowed_origins", []string{"http://localhost:3000", "http://localhost:5173"})
	viper.SetDefault("cors.allowed_methods", []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"})
	viper.SetDefault("cors.allowed_headers", []string{"Authorization", "Content-Type"})

	// Firebase defaults
	viper.SetDefault("firebase.service_account_path", "./service-account.json")
	viper.SetDefault("firebase.project_id", "guyub-61b85")

	// Log defaults
	viper.SetDefault("log.level", "debug")
	viper.SetDefault("log.format", "json")
}
