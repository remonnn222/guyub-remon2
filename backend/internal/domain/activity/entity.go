package activity

import (
	"encoding/json"
	"time"
)

type ActivityType string

const (
	ActivityLogin         ActivityType = "login"
	ActivityLogout        ActivityType = "logout"
	ActivityLoginFailed   ActivityType = "login_failed"
	ActivityPasswordReset ActivityType = "password_reset"
	ActivityProfileUpdate ActivityType = "profile_update"
	Activity2FAEnabled    ActivityType = "2fa_enabled"
	Activity2FADisabled   ActivityType = "2fa_disabled"
	ActivitySessionStart  ActivityType = "session_start"
	ActivitySessionEnd    ActivityType = "session_end"
)

type Log struct {
	ID           uint64          `gorm:"primaryKey;autoIncrement" json:"id"`
	UserID       *uint64         `gorm:"index" json:"user_id,omitempty"`
	ActivityType ActivityType    `gorm:"type:varchar(255);not null" json:"activity_type"`
	IPAddress    *string         `gorm:"type:varchar(45)" json:"ip_address,omitempty"`
	UserAgent    *string         `gorm:"type:text" json:"user_agent,omitempty"`
	DeviceType   *string         `gorm:"type:varchar(50)" json:"device_type,omitempty"`
	Browser      *string         `gorm:"type:varchar(100)" json:"browser,omitempty"`
	Platform     *string         `gorm:"type:varchar(100)" json:"platform,omitempty"`
	Description  *string         `gorm:"type:text" json:"description,omitempty"`
	Metadata     json.RawMessage `gorm:"type:json" json:"metadata,omitempty"`
	CreatedAt    time.Time       `gorm:"type:timestamp;default:CURRENT_TIMESTAMP" json:"created_at"`
	UpdatedAt    time.Time       `gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" json:"updated_at"`
}

func (Log) TableName() string {
	return "activity_logs"
}

// UserAgentInfo parsed from user agent string
type UserAgentInfo struct {
	DeviceType string `json:"device_type"`
	Browser    string `json:"browser"`
	Platform   string `json:"platform"`
}

func ParseUserAgent(userAgent string) *UserAgentInfo {
	// Basic parsing - in production, use a proper UA parser library
	info := &UserAgentInfo{
		DeviceType: "desktop",
		Browser:    "unknown",
		Platform:   "unknown",
	}

	if len(userAgent) == 0 {
		return info
	}

	// Simple detection
	if contains(userAgent, "Mobile") || contains(userAgent, "Android") || contains(userAgent, "iPhone") {
		info.DeviceType = "mobile"
	} else if contains(userAgent, "Tablet") || contains(userAgent, "iPad") {
		info.DeviceType = "tablet"
	}

	if contains(userAgent, "Chrome") {
		info.Browser = "Chrome"
	} else if contains(userAgent, "Firefox") {
		info.Browser = "Firefox"
	} else if contains(userAgent, "Safari") {
		info.Browser = "Safari"
	} else if contains(userAgent, "Edge") {
		info.Browser = "Edge"
	}

	if contains(userAgent, "Windows") {
		info.Platform = "Windows"
	} else if contains(userAgent, "Mac") {
		info.Platform = "macOS"
	} else if contains(userAgent, "Linux") {
		info.Platform = "Linux"
	} else if contains(userAgent, "Android") {
		info.Platform = "Android"
	} else if contains(userAgent, "iOS") || contains(userAgent, "iPhone") || contains(userAgent, "iPad") {
		info.Platform = "iOS"
	}

	return info
}

func contains(s, substr string) bool {
	return len(s) >= len(substr) && (s == substr || len(s) > 0 && containsHelper(s, substr))
}

func containsHelper(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}
