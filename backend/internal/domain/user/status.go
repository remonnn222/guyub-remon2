package user

type Status string

const (
	StatusActive    Status = "active"
	StatusInactive  Status = "inactive"
	StatusSuspended Status = "suspended"
)

func (s Status) String() string {
	return string(s)
}

func (s Status) Label() string {
	switch s {
	case StatusActive:
		return "Active"
	case StatusInactive:
		return "Inactive"
	case StatusSuspended:
		return "Suspended"
	default:
		return "Unknown"
	}
}

func (s Status) IsValid() bool {
	switch s {
	case StatusActive, StatusInactive, StatusSuspended:
		return true
	}
	return false
}

func StatusFromString(s string) Status {
	switch s {
	case "active":
		return StatusActive
	case "inactive":
		return StatusInactive
	case "suspended":
		return StatusSuspended
	default:
		return StatusActive
	}
}

var AllStatuses = []Status{StatusActive, StatusInactive, StatusSuspended}
