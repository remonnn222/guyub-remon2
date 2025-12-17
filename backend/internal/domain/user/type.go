package user

type Type string

const (
	TypeInternal Type = "internal"
	TypeCustomer Type = "customer"
	TypeAgent    Type = "agent"
)

func (t Type) String() string {
	return string(t)
}

func (t Type) Label() string {
	switch t {
	case TypeInternal:
		return "Internal"
	case TypeCustomer:
		return "Customer"
	case TypeAgent:
		return "Agent"
	default:
		return "Unknown"
	}
}

func (t Type) IsValid() bool {
	switch t {
	case TypeInternal, TypeCustomer, TypeAgent:
		return true
	}
	return false
}

func TypeFromString(s string) Type {
	switch s {
	case "internal":
		return TypeInternal
	case "customer":
		return TypeCustomer
	case "agent":
		return TypeAgent
	default:
		return TypeCustomer
	}
}

var AllTypes = []Type{TypeInternal, TypeCustomer, TypeAgent}
