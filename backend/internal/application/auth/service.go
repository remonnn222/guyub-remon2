package auth

import (
	"context"
	"errors"
	"strconv"

	"guyub/internal/domain/activity"
	"guyub/internal/domain/asset"
	"guyub/internal/domain/user"
	infraAuth "guyub/internal/infrastructure/auth"
)

var (
	ErrInvalidCredentials = errors.New("invalid email or password")
	ErrUserInactive       = errors.New("user account is not active")
	ErrUserSuspended      = errors.New("user account is suspended")
	ErrUserNotFound       = errors.New("user not found")
	ErrInvalidToken       = errors.New("invalid or expired token")
)

type Service struct {
	userRepo        user.Repository
	activityRepo    activity.Repository
	assetRepo       asset.Repository
	storageService  asset.StorageService
	jwtService      *infraAuth.JWTService
	passwordService *infraAuth.PasswordService
}

func NewService(
	userRepo user.Repository,
	activityRepo activity.Repository,
	assetRepo asset.Repository,
	storageService asset.StorageService,
	jwtService *infraAuth.JWTService,
	passwordService *infraAuth.PasswordService,
) *Service {
	return &Service{
		userRepo:        userRepo,
		activityRepo:    activityRepo,
		assetRepo:       assetRepo,
		storageService:  storageService,
		jwtService:      jwtService,
		passwordService: passwordService,
	}
}

type LoginRequest struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required"`
}

type LoginResponse struct {
	User         *UserResponse          `json:"user"`
	AccessToken  string                 `json:"access_token"`
	RefreshToken string                 `json:"refresh_token"`
	TokenType    string                 `json:"token_type"`
	ExpiresIn    int64                  `json:"expires_in"`
}

type UserResponse struct {
	ID          uint64   `json:"id"`
	Name        string   `json:"name"`
	Email       string   `json:"email"`
	Phone       *string  `json:"phone,omitempty"`
	AvatarURL   *string  `json:"avatar_url,omitempty"`
	Status      string   `json:"status"`
	Type        string   `json:"type"`
	Roles       []string `json:"roles"`
	Permissions []string `json:"permissions"`
}

func (s *Service) Login(ctx context.Context, req *LoginRequest, ip, userAgent string) (*LoginResponse, error) {
	// Find user by email
	u, err := s.userRepo.FindByEmailWithRoles(ctx, req.Email)
	if err != nil {
		return nil, err
	}
	if u == nil {
		s.logFailedLogin(ctx, nil, ip, userAgent, "User not found")
		return nil, ErrInvalidCredentials
	}

	// Verify password
	if err := s.passwordService.Verify(req.Password, u.Password); err != nil {
		s.logFailedLogin(ctx, &u.ID, ip, userAgent, "Invalid password")
		return nil, ErrInvalidCredentials
	}

	// Check status
	switch u.Status {
	case user.StatusInactive:
		s.logFailedLogin(ctx, &u.ID, ip, userAgent, "Account inactive")
		return nil, ErrUserInactive
	case user.StatusSuspended:
		s.logFailedLogin(ctx, &u.ID, ip, userAgent, "Account suspended")
		return nil, ErrUserSuspended
	}

	// Get all permissions
	permissions, err := s.userRepo.GetAllPermissions(ctx, u.ID)
	if err != nil {
		return nil, err
	}

	// Generate tokens
	roles := u.GetRoleNames()
	tokenPair, err := s.jwtService.GenerateTokenPair(u.ID, u.Email, u.Name, roles, permissions)
	if err != nil {
		return nil, err
	}

	// Update last login
	if err := s.userRepo.UpdateLastLogin(ctx, u.ID, ip); err != nil {
		// Log but don't fail login
	}

	// Log successful login
	s.logLogin(ctx, u.ID, ip, userAgent)

	avatarURL := s.getAvatarURL(ctx, u.ID)

	return &LoginResponse{
		User: &UserResponse{
			ID:          u.ID,
			Name:        u.Name,
			Email:       u.Email,
			Phone:       u.Phone,
			AvatarURL:   avatarURL,
			Status:      u.Status.String(),
			Type:        u.Type.String(),
			Roles:       roles,
			Permissions: permissions,
		},
		AccessToken:  tokenPair.AccessToken,
		RefreshToken: tokenPair.RefreshToken,
		TokenType:    tokenPair.TokenType,
		ExpiresIn:    int64(s.jwtService.GetExpiry().Seconds()),
	}, nil
}

func (s *Service) Logout(ctx context.Context, userID uint64, ip, userAgent string) error {
	s.logLogout(ctx, userID, ip, userAgent)
	return nil
}

type RefreshRequest struct {
	RefreshToken string `json:"refresh_token" validate:"required"`
}

func (s *Service) Refresh(ctx context.Context, req *RefreshRequest) (*LoginResponse, error) {
	// Validate refresh token
	claims, err := s.jwtService.ValidateRefreshToken(req.RefreshToken)
	if err != nil {
		return nil, ErrInvalidToken
	}

	// Get user
	u, err := s.userRepo.FindByIDWithRoles(ctx, claims.UserID)
	if err != nil {
		return nil, err
	}
	if u == nil {
		return nil, ErrUserNotFound
	}

	// Check status
	if u.Status != user.StatusActive {
		return nil, ErrUserInactive
	}

	// Get all permissions
	permissions, err := s.userRepo.GetAllPermissions(ctx, u.ID)
	if err != nil {
		return nil, err
	}

	// Generate new tokens
	roles := u.GetRoleNames()
	tokenPair, err := s.jwtService.GenerateTokenPair(u.ID, u.Email, u.Name, roles, permissions)
	if err != nil {
		return nil, err
	}

	avatarURL := s.getAvatarURL(ctx, u.ID)

	return &LoginResponse{
		User: &UserResponse{
			ID:          u.ID,
			Name:        u.Name,
			Email:       u.Email,
			Phone:       u.Phone,
			AvatarURL:   avatarURL,
			Status:      u.Status.String(),
			Type:        u.Type.String(),
			Roles:       roles,
			Permissions: permissions,
		},
		AccessToken:  tokenPair.AccessToken,
		RefreshToken: tokenPair.RefreshToken,
		TokenType:    tokenPair.TokenType,
		ExpiresIn:    int64(s.jwtService.GetExpiry().Seconds()),
	}, nil
}

func (s *Service) Me(ctx context.Context, userID uint64) (*UserResponse, error) {
	u, err := s.userRepo.FindByIDWithRoles(ctx, userID)
	if err != nil {
		return nil, err
	}
	if u == nil {
		return nil, ErrUserNotFound
	}

	permissions, err := s.userRepo.GetAllPermissions(ctx, u.ID)
	if err != nil {
		return nil, err
	}

	avatarURL := s.getAvatarURL(ctx, u.ID)

	return &UserResponse{
		ID:          u.ID,
		Name:        u.Name,
		Email:       u.Email,
		Phone:       u.Phone,
		AvatarURL:   avatarURL,
		Status:      u.Status.String(),
		Type:        u.Type.String(),
		Roles:       u.GetRoleNames(),
		Permissions: permissions,
	}, nil
}

// getAvatarURL fetches the avatar URL for a user
func (s *Service) getAvatarURL(ctx context.Context, userID uint64) *string {
	if s.assetRepo == nil || s.storageService == nil {
		return nil
	}
	refID := strconv.FormatUint(userID, 10)
	avatar, err := s.assetRepo.FindLatestByRefIDAndKind(ctx, refID, asset.KindUserAvatar)
	if err != nil || avatar == nil {
		return nil
	}
	url := s.storageService.URL(avatar.StoragePath)
	return &url
}

// Activity logging helpers
func (s *Service) logLogin(ctx context.Context, userID uint64, ip, userAgent string) {
	info := activity.ParseUserAgent(userAgent)
	log := &activity.Log{
		UserID:       &userID,
		ActivityType: activity.ActivityLogin,
		IPAddress:    &ip,
		UserAgent:    &userAgent,
		DeviceType:   &info.DeviceType,
		Browser:      &info.Browser,
		Platform:     &info.Platform,
	}
	_ = s.activityRepo.Create(ctx, log)
}

func (s *Service) logLogout(ctx context.Context, userID uint64, ip, userAgent string) {
	info := activity.ParseUserAgent(userAgent)
	log := &activity.Log{
		UserID:       &userID,
		ActivityType: activity.ActivityLogout,
		IPAddress:    &ip,
		UserAgent:    &userAgent,
		DeviceType:   &info.DeviceType,
		Browser:      &info.Browser,
		Platform:     &info.Platform,
	}
	_ = s.activityRepo.Create(ctx, log)
}

func (s *Service) logFailedLogin(ctx context.Context, userID *uint64, ip, userAgent, reason string) {
	info := activity.ParseUserAgent(userAgent)
	log := &activity.Log{
		UserID:       userID,
		ActivityType: activity.ActivityLoginFailed,
		IPAddress:    &ip,
		UserAgent:    &userAgent,
		DeviceType:   &info.DeviceType,
		Browser:      &info.Browser,
		Platform:     &info.Platform,
		Description:  &reason,
	}
	_ = s.activityRepo.Create(ctx, log)
}
