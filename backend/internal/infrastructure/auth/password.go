package auth

import (
	"errors"
	"regexp"
	"unicode"

	"golang.org/x/crypto/bcrypt"
)

var (
	ErrPasswordTooShort     = errors.New("password must be at least 8 characters")
	ErrPasswordNoUppercase  = errors.New("password must contain at least one uppercase letter")
	ErrPasswordNoLowercase  = errors.New("password must contain at least one lowercase letter")
	ErrPasswordNoNumber     = errors.New("password must contain at least one number")
	ErrPasswordNoSpecial    = errors.New("password must contain at least one special character")
	ErrPasswordMismatch     = errors.New("password does not match")
)

const (
	MinPasswordLength = 8
	BcryptCost        = 12
)

type PasswordService struct {
	cost int
}

func NewPasswordService() *PasswordService {
	return &PasswordService{
		cost: BcryptCost,
	}
}

func (s *PasswordService) Hash(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), s.cost)
	if err != nil {
		return "", err
	}
	return string(bytes), nil
}

func (s *PasswordService) Verify(password, hash string) error {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	if err != nil {
		if errors.Is(err, bcrypt.ErrMismatchedHashAndPassword) {
			return ErrPasswordMismatch
		}
		return err
	}
	return nil
}

func (s *PasswordService) Validate(password string) error {
	if len(password) < MinPasswordLength {
		return ErrPasswordTooShort
	}

	var hasUpper, hasLower, hasNumber, hasSpecial bool

	for _, char := range password {
		switch {
		case unicode.IsUpper(char):
			hasUpper = true
		case unicode.IsLower(char):
			hasLower = true
		case unicode.IsNumber(char):
			hasNumber = true
		case unicode.IsPunct(char) || unicode.IsSymbol(char):
			hasSpecial = true
		}
	}

	if !hasUpper {
		return ErrPasswordNoUppercase
	}
	if !hasLower {
		return ErrPasswordNoLowercase
	}
	if !hasNumber {
		return ErrPasswordNoNumber
	}
	if !hasSpecial {
		return ErrPasswordNoSpecial
	}

	return nil
}

// ValidateEmail validates email format
func ValidateEmail(email string) bool {
	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	return emailRegex.MatchString(email)
}

// ValidatePhone validates phone format
func ValidatePhone(phone string) bool {
	phoneRegex := regexp.MustCompile(`^[+]?[(]?[0-9]{1,4}[)]?[-\s./0-9]*$`)
	return phoneRegex.MatchString(phone)
}
