package audit

import (
	"encoding/json"
	"time"
)

type SecurityLevel string

const (
	SecurityLevelLow      SecurityLevel = "low"
	SecurityLevelMedium   SecurityLevel = "medium"
	SecurityLevelHigh     SecurityLevel = "high"
	SecurityLevelCritical SecurityLevel = "critical"
)

type Event string

const (
	EventCreated  Event = "created"
	EventUpdated  Event = "updated"
	EventDeleted  Event = "deleted"
	EventRestored Event = "restored"
	EventLogin    Event = "login"
	EventLogout   Event = "logout"
	EventViewed   Event = "viewed"
	EventExported Event = "exported"
)

type Log struct {
	ID            uint64          `gorm:"primaryKey;autoIncrement" json:"id"`
	UserID        *uint64         `gorm:"index" json:"user_id,omitempty"`
	UserName      *string         `gorm:"type:varchar(255)" json:"user_name,omitempty"`
	Event         Event           `gorm:"type:varchar(50);not null" json:"event"`
	AuditableType string          `gorm:"type:varchar(255);not null" json:"auditable_type"`
	AuditableID   *uint64         `json:"auditable_id,omitempty"`
	OldValues     json.RawMessage `gorm:"type:json" json:"old_values,omitempty"`
	NewValues     json.RawMessage `gorm:"type:json" json:"new_values,omitempty"`
	Description   *string         `gorm:"type:text" json:"description,omitempty"`
	IPAddress     *string         `gorm:"type:varchar(45)" json:"ip_address,omitempty"`
	UserAgent     *string         `gorm:"type:text" json:"user_agent,omitempty"`
	URL           *string         `gorm:"type:text" json:"url,omitempty"`
	HTTPMethod    *string         `gorm:"type:varchar(10)" json:"http_method,omitempty"`
	SecurityLevel SecurityLevel   `gorm:"type:enum('low','medium','high','critical');default:'low'" json:"security_level"`
	Tags          json.RawMessage `gorm:"type:json" json:"tags,omitempty"`
	CreatedAt     time.Time       `gorm:"type:timestamp;default:CURRENT_TIMESTAMP" json:"created_at"`
}

func (Log) TableName() string {
	return "audit_logs"
}

// Sensitive fields to exclude from audit logging
var SensitiveFields = []string{
	"password",
	"remember_token",
	"two_factor_secret",
	"two_factor_recovery_codes",
	"api_token",
	"secret",
}

func IsSensitiveField(field string) bool {
	for _, sf := range SensitiveFields {
		if field == sf {
			return true
		}
	}
	return false
}

func FilterSensitiveData(data map[string]interface{}) map[string]interface{} {
	result := make(map[string]interface{})
	for key, value := range data {
		if !IsSensitiveField(key) {
			result[key] = value
		} else {
			result[key] = "[REDACTED]"
		}
	}
	return result
}

// Security level mapping for different events
func GetSecurityLevel(event Event, entityType string) SecurityLevel {
	switch event {
	case EventDeleted:
		if entityType == "User" || entityType == "Role" {
			return SecurityLevelHigh
		}
		return SecurityLevelMedium
	case EventCreated, EventUpdated:
		if entityType == "User" || entityType == "Role" || entityType == "Permission" {
			return SecurityLevelMedium
		}
		return SecurityLevelLow
	case EventLogin, EventLogout:
		return SecurityLevelLow
	case EventExported:
		return SecurityLevelMedium
	default:
		return SecurityLevelLow
	}
}
