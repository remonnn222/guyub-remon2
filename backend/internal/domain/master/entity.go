package master

import (
	"encoding/json"
	"time"

	"gorm.io/gorm"
)

type Type struct {
	ID          uint64          `gorm:"primaryKey;autoIncrement" json:"id"`
	ParentID    *uint64         `gorm:"index" json:"parent_id,omitempty"`
	Code        string          `gorm:"type:varchar(50);not null;uniqueIndex" json:"code"`
	Name        string          `gorm:"type:varchar(255);not null" json:"name"`
	Description *string         `gorm:"type:text" json:"description,omitempty"`
	IsActive    bool            `gorm:"default:true" json:"is_active"`
	SortOrder   int             `gorm:"default:0" json:"sort_order"`
	Metadata    json.RawMessage `gorm:"type:json" json:"metadata,omitempty"`
	CreatedAt   time.Time       `gorm:"type:timestamp;default:CURRENT_TIMESTAMP" json:"created_at"`
	UpdatedAt   time.Time       `gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" json:"updated_at"`
	DeletedAt   gorm.DeletedAt  `gorm:"index" json:"deleted_at,omitempty"`

	Parent      *Type   `gorm:"foreignKey:ParentID" json:"parent,omitempty"`
	Children    []Type  `gorm:"foreignKey:ParentID" json:"children,omitempty"`
	Values      []Value `gorm:"foreignKey:TypeID" json:"values,omitempty"`
	ValuesCount int     `gorm:"-" json:"values_count,omitempty"`
}

func (Type) TableName() string {
	return "app_master_types"
}

func (t *Type) HasChildren() bool {
	return len(t.Children) > 0
}

func (t *Type) IsRoot() bool {
	return t.ParentID == nil
}

type Value struct {
	ID            uint64          `gorm:"primaryKey;autoIncrement" json:"id"`
	TypeID        uint64          `gorm:"not null;index" json:"type_id"`
	ParentValueID *uint64         `gorm:"index" json:"parent_value_id,omitempty"`
	Code          string          `gorm:"type:varchar(50);not null" json:"code"`
	Name          string          `gorm:"type:varchar(255);not null" json:"name"`
	Description   *string         `gorm:"type:text" json:"description,omitempty"`
	IsActive      bool            `gorm:"default:true" json:"is_active"`
	SortOrder     int             `gorm:"default:0" json:"sort_order"`
	Metadata      json.RawMessage `gorm:"type:json" json:"metadata,omitempty"`
	CreatedAt     time.Time       `gorm:"type:timestamp;default:CURRENT_TIMESTAMP" json:"created_at"`
	UpdatedAt     time.Time       `gorm:"type:timestamp;default:CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" json:"updated_at"`
	DeletedAt     gorm.DeletedAt  `gorm:"index" json:"deleted_at,omitempty"`

	Type        *Type   `gorm:"foreignKey:TypeID" json:"type,omitempty"`
	ParentValue *Value  `gorm:"foreignKey:ParentValueID" json:"parent_value,omitempty"`
	Children    []Value `gorm:"foreignKey:ParentValueID" json:"children,omitempty"`
}

func (Value) TableName() string {
	return "app_master_values"
}

func (v *Value) HasParent() bool {
	return v.ParentValueID != nil
}

func (v *Value) HasChildren() bool {
	return len(v.Children) > 0
}
