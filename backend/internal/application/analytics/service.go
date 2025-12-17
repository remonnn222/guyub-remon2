package analytics

import (
	"context"

	"guyub/internal/domain/activity"
	"guyub/internal/domain/role"
	"guyub/internal/domain/user"
)

type Service struct {
	userRepo       user.Repository
	roleRepo       role.Repository
	permissionRepo role.PermissionRepository
	activityRepo   activity.Repository
}

func NewService(
	userRepo user.Repository,
	roleRepo role.Repository,
	permissionRepo role.PermissionRepository,
	activityRepo activity.Repository,
) *Service {
	return &Service{
		userRepo:       userRepo,
		roleRepo:       roleRepo,
		permissionRepo: permissionRepo,
		activityRepo:   activityRepo,
	}
}

type DashboardStats struct {
	TotalUsers       int64            `json:"total_users"`
	ActiveUsers      int64            `json:"active_users"`
	TotalRoles       int64            `json:"total_roles"`
	TotalPermissions int64            `json:"total_permissions"`
	RecentActivities []ActivityItem   `json:"recent_activities"`
	UserGrowth       []ChartDataPoint `json:"user_growth"`
	ActivityTrends   []ChartDataPoint `json:"activity_trends"`
}

type ActivityItem struct {
	ID           uint64  `json:"id"`
	UserID       *uint64 `json:"user_id,omitempty"`
	UserName     string  `json:"user_name,omitempty"`
	ActivityType string  `json:"activity_type"`
	Description  string  `json:"description"`
	IPAddress    string  `json:"ip_address"`
	CreatedAt    string  `json:"created_at"`
}

type ChartDataPoint struct {
	Label string `json:"label"`
	Value int64  `json:"value"`
}

func (s *Service) GetDashboardStats(ctx context.Context) (*DashboardStats, error) {
	// Get total users
	totalUsers, err := s.userRepo.Count(ctx, &user.Filter{})
	if err != nil {
		return nil, err
	}

	// Get active users
	activeStatus := user.StatusActive
	activeUsers, err := s.userRepo.Count(ctx, &user.Filter{Status: &activeStatus})
	if err != nil {
		return nil, err
	}

	// Get total roles
	roles, err := s.roleRepo.FindAll(ctx)
	if err != nil {
		return nil, err
	}
	totalRoles := int64(len(roles))

	// Get total permissions
	permissions, err := s.permissionRepo.FindAll(ctx)
	if err != nil {
		return nil, err
	}
	totalPermissions := int64(len(permissions))

	// Get recent activities
	activities, _, err := s.activityRepo.FindAll(ctx, &activity.Filter{}, &activity.Pagination{
		Page:    1,
		PerPage: 10,
		SortBy:  "created_at",
		SortDir: "desc",
	})
	if err != nil {
		// Don't fail if activities fail
		activities = []*activity.Log{}
	}

	recentActivities := make([]ActivityItem, 0, len(activities))
	for _, a := range activities {
		item := ActivityItem{
			ID:           a.ID,
			UserID:       a.UserID,
			ActivityType: string(a.ActivityType),
			CreatedAt:    a.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		}
		if a.Description != nil {
			item.Description = *a.Description
		}
		if a.IPAddress != nil {
			item.IPAddress = *a.IPAddress
		}
		recentActivities = append(recentActivities, item)
	}

	// For now, return empty chart data (can be implemented later)
	userGrowth := []ChartDataPoint{
		{Label: "Jan", Value: 0},
		{Label: "Feb", Value: 0},
		{Label: "Mar", Value: 0},
		{Label: "Apr", Value: 0},
		{Label: "May", Value: 0},
		{Label: "Jun", Value: 0},
	}

	activityTrends := []ChartDataPoint{
		{Label: "Mon", Value: 0},
		{Label: "Tue", Value: 0},
		{Label: "Wed", Value: 0},
		{Label: "Thu", Value: 0},
		{Label: "Fri", Value: 0},
		{Label: "Sat", Value: 0},
		{Label: "Sun", Value: 0},
	}

	return &DashboardStats{
		TotalUsers:       totalUsers,
		ActiveUsers:      activeUsers,
		TotalRoles:       totalRoles,
		TotalPermissions: totalPermissions,
		RecentActivities: recentActivities,
		UserGrowth:       userGrowth,
		ActivityTrends:   activityTrends,
	}, nil
}
