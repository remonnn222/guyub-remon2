package auth

import (
	"errors"
	"time"

	"guyub/pkg/config"

	"github.com/golang-jwt/jwt/v5"
)

var (
	ErrInvalidToken = errors.New("invalid token")
	ErrExpiredToken = errors.New("token has expired")
)

type JWTService struct {
	secret        []byte
	expiry        time.Duration
	refreshExpiry time.Duration
}

type Claims struct {
	UserID      uint64   `json:"user_id"`
	Email       string   `json:"email"`
	Name        string   `json:"name"`
	Roles       []string `json:"roles"`
	Permissions []string `json:"permissions"`
	TokenType   string   `json:"token_type"`
	jwt.RegisteredClaims
}

type TokenPair struct {
	AccessToken  string    `json:"access_token"`
	RefreshToken string    `json:"refresh_token"`
	TokenType    string    `json:"token_type"`
	ExpiresAt    time.Time `json:"expires_at"`
}

func NewJWTService(cfg *config.JWTConfig) *JWTService {
	return &JWTService{
		secret:        []byte(cfg.Secret),
		expiry:        cfg.Expiry,
		refreshExpiry: cfg.RefreshExpiry,
	}
}

func (s *JWTService) GenerateTokenPair(userID uint64, email, name string, roles, permissions []string) (*TokenPair, error) {
	now := time.Now()
	accessExpiresAt := now.Add(s.expiry)
	refreshExpiresAt := now.Add(s.refreshExpiry)

	// Access token
	accessClaims := &Claims{
		UserID:      userID,
		Email:       email,
		Name:        name,
		Roles:       roles,
		Permissions: permissions,
		TokenType:   "access",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(accessExpiresAt),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
			Subject:   email,
		},
	}

	accessToken := jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims)
	accessTokenString, err := accessToken.SignedString(s.secret)
	if err != nil {
		return nil, err
	}

	// Refresh token
	refreshClaims := &Claims{
		UserID:    userID,
		Email:     email,
		TokenType: "refresh",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(refreshExpiresAt),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
			Subject:   email,
		},
	}

	refreshToken := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims)
	refreshTokenString, err := refreshToken.SignedString(s.secret)
	if err != nil {
		return nil, err
	}

	return &TokenPair{
		AccessToken:  accessTokenString,
		RefreshToken: refreshTokenString,
		TokenType:    "Bearer",
		ExpiresAt:    accessExpiresAt,
	}, nil
}

func (s *JWTService) ValidateToken(tokenString string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, ErrInvalidToken
		}
		return s.secret, nil
	})

	if err != nil {
		if errors.Is(err, jwt.ErrTokenExpired) {
			return nil, ErrExpiredToken
		}
		return nil, ErrInvalidToken
	}

	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, ErrInvalidToken
	}

	return claims, nil
}

func (s *JWTService) ValidateAccessToken(tokenString string) (*Claims, error) {
	claims, err := s.ValidateToken(tokenString)
	if err != nil {
		return nil, err
	}

	if claims.TokenType != "access" {
		return nil, ErrInvalidToken
	}

	return claims, nil
}

func (s *JWTService) ValidateRefreshToken(tokenString string) (*Claims, error) {
	claims, err := s.ValidateToken(tokenString)
	if err != nil {
		return nil, err
	}

	if claims.TokenType != "refresh" {
		return nil, ErrInvalidToken
	}

	return claims, nil
}

func (s *JWTService) GetExpiry() time.Duration {
	return s.expiry
}

func (s *JWTService) GetRefreshExpiry() time.Duration {
	return s.refreshExpiry
}
