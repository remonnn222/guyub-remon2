package master

import (
	"context"
	"errors"
	"strings"

	"guyub/internal/domain/master"
)

var (
	ErrTypeNotFound    = errors.New("master type not found")
	ErrValueNotFound   = errors.New("master value not found")
	ErrCodeExists      = errors.New("code already exists")
	ErrInvalidCode     = errors.New("code must be uppercase alphanumeric")
)

type Service struct {
	typeRepo  master.TypeRepository
	valueRepo master.ValueRepository
}

func NewService(typeRepo master.TypeRepository, valueRepo master.ValueRepository) *Service {
	return &Service{
		typeRepo:  typeRepo,
		valueRepo: valueRepo,
	}
}

// Type DTOs
type CreateTypeRequest struct {
	ParentID    *uint64 `json:"parent_id,omitempty"`
	Code        string  `json:"code" validate:"required,min=2,max=50"`
	Name        string  `json:"name" validate:"required,min=2,max=255"`
	Description *string `json:"description,omitempty"`
	IsActive    bool    `json:"is_active"`
	SortOrder   int     `json:"sort_order"`
}

type UpdateTypeRequest struct {
	ParentID    *uint64 `json:"parent_id,omitempty"`
	Code        string  `json:"code" validate:"required,min=2,max=50"`
	Name        string  `json:"name" validate:"required,min=2,max=255"`
	Description *string `json:"description,omitempty"`
	IsActive    bool    `json:"is_active"`
	SortOrder   int     `json:"sort_order"`
}

type TypeResponse struct {
	ID          uint64          `json:"id"`
	ParentID    *uint64         `json:"parent_id,omitempty"`
	Code        string          `json:"code"`
	Name        string          `json:"name"`
	Description *string         `json:"description,omitempty"`
	IsActive    bool            `json:"is_active"`
	SortOrder   int             `json:"sort_order"`
	ValuesCount int             `json:"values_count"`
	Children    []*TypeResponse `json:"children,omitempty"`
	CreatedAt   string          `json:"created_at"`
	UpdatedAt   string          `json:"updated_at"`
}

// Value DTOs
type CreateValueRequest struct {
	TypeID        uint64  `json:"type_id" validate:"required"`
	ParentValueID *uint64 `json:"parent_value_id,omitempty"`
	Code          string  `json:"code" validate:"required,min=1,max=50"`
	Name          string  `json:"name" validate:"required,min=1,max=255"`
	Description   *string `json:"description,omitempty"`
	IsActive      bool    `json:"is_active"`
	SortOrder     int     `json:"sort_order"`
}

type UpdateValueRequest struct {
	ParentValueID *uint64 `json:"parent_value_id,omitempty"`
	Code          string  `json:"code" validate:"required,min=1,max=50"`
	Name          string  `json:"name" validate:"required,min=1,max=255"`
	Description   *string `json:"description,omitempty"`
	IsActive      bool    `json:"is_active"`
	SortOrder     int     `json:"sort_order"`
}

type ValueResponse struct {
	ID            uint64  `json:"id"`
	TypeID        uint64  `json:"type_id"`
	ParentValueID *uint64 `json:"parent_value_id,omitempty"`
	Code          string  `json:"code"`
	Name          string  `json:"name"`
	Description   *string `json:"description,omitempty"`
	IsActive      bool    `json:"is_active"`
	SortOrder     int     `json:"sort_order"`
	CreatedAt     string  `json:"created_at"`
	UpdatedAt     string  `json:"updated_at"`
}

// Type operations
func (s *Service) CreateType(ctx context.Context, req *CreateTypeRequest) (*TypeResponse, error) {
	// Validate and uppercase code
	code := strings.ToUpper(strings.TrimSpace(req.Code))
	if !isValidCode(code) {
		return nil, ErrInvalidCode
	}

	// Check if code exists
	existing, err := s.typeRepo.FindByCode(ctx, code)
	if err != nil {
		return nil, err
	}
	if existing != nil {
		return nil, ErrCodeExists
	}

	t := &master.Type{
		ParentID:    req.ParentID,
		Code:        code,
		Name:        req.Name,
		Description: req.Description,
		IsActive:    req.IsActive,
		SortOrder:   req.SortOrder,
	}

	if err := s.typeRepo.Create(ctx, t); err != nil {
		return nil, err
	}

	return s.typeToResponse(t), nil
}

func (s *Service) UpdateType(ctx context.Context, id uint64, req *UpdateTypeRequest) (*TypeResponse, error) {
	t, err := s.typeRepo.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if t == nil {
		return nil, ErrTypeNotFound
	}

	// Validate and uppercase code
	code := strings.ToUpper(strings.TrimSpace(req.Code))
	if !isValidCode(code) {
		return nil, ErrInvalidCode
	}

	// Check if code exists (excluding current)
	if t.Code != code {
		existing, err := s.typeRepo.FindByCode(ctx, code)
		if err != nil {
			return nil, err
		}
		if existing != nil {
			return nil, ErrCodeExists
		}
	}

	t.ParentID = req.ParentID
	t.Code = code
	t.Name = req.Name
	t.Description = req.Description
	t.IsActive = req.IsActive
	t.SortOrder = req.SortOrder

	if err := s.typeRepo.Update(ctx, t); err != nil {
		return nil, err
	}

	return s.typeToResponse(t), nil
}

func (s *Service) DeleteType(ctx context.Context, id uint64) error {
	t, err := s.typeRepo.FindByID(ctx, id)
	if err != nil {
		return err
	}
	if t == nil {
		return ErrTypeNotFound
	}

	return s.typeRepo.Delete(ctx, id)
}

func (s *Service) RestoreType(ctx context.Context, id uint64) error {
	return s.typeRepo.Restore(ctx, id)
}

func (s *Service) GetType(ctx context.Context, id uint64) (*TypeResponse, error) {
	t, err := s.typeRepo.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if t == nil {
		return nil, ErrTypeNotFound
	}
	return s.typeToResponse(t), nil
}

func (s *Service) GetAllTypes(ctx context.Context, activeOnly bool) ([]*TypeResponse, error) {
	types, err := s.typeRepo.FindAllHierarchical(ctx, activeOnly)
	if err != nil {
		return nil, err
	}

	result := make([]*TypeResponse, len(types))
	for i, t := range types {
		result[i] = s.typeToResponseWithChildren(t)
	}

	return result, nil
}

// Value operations
func (s *Service) CreateValue(ctx context.Context, req *CreateValueRequest) (*ValueResponse, error) {
	// Check if type exists
	t, err := s.typeRepo.FindByID(ctx, req.TypeID)
	if err != nil {
		return nil, err
	}
	if t == nil {
		return nil, ErrTypeNotFound
	}

	// Check if code exists within type
	exists, err := s.valueRepo.ExistsByCode(ctx, req.TypeID, req.Code, nil)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, ErrCodeExists
	}

	v := &master.Value{
		TypeID:        req.TypeID,
		ParentValueID: req.ParentValueID,
		Code:          req.Code,
		Name:          req.Name,
		Description:   req.Description,
		IsActive:      req.IsActive,
		SortOrder:     req.SortOrder,
	}

	if err := s.valueRepo.Create(ctx, v); err != nil {
		return nil, err
	}

	return s.valueToResponse(v), nil
}

func (s *Service) UpdateValue(ctx context.Context, id uint64, req *UpdateValueRequest) (*ValueResponse, error) {
	v, err := s.valueRepo.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if v == nil {
		return nil, ErrValueNotFound
	}

	// Check if code exists within type (excluding current)
	exists, err := s.valueRepo.ExistsByCode(ctx, v.TypeID, req.Code, &id)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, ErrCodeExists
	}

	v.ParentValueID = req.ParentValueID
	v.Code = req.Code
	v.Name = req.Name
	v.Description = req.Description
	v.IsActive = req.IsActive
	v.SortOrder = req.SortOrder

	if err := s.valueRepo.Update(ctx, v); err != nil {
		return nil, err
	}

	return s.valueToResponse(v), nil
}

func (s *Service) DeleteValue(ctx context.Context, id uint64) error {
	v, err := s.valueRepo.FindByID(ctx, id)
	if err != nil {
		return err
	}
	if v == nil {
		return ErrValueNotFound
	}

	return s.valueRepo.Delete(ctx, id)
}

func (s *Service) GetValue(ctx context.Context, id uint64) (*ValueResponse, error) {
	v, err := s.valueRepo.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if v == nil {
		return nil, ErrValueNotFound
	}
	return s.valueToResponse(v), nil
}

func (s *Service) GetValuesByTypeID(ctx context.Context, typeID uint64, activeOnly bool) ([]*ValueResponse, error) {
	filter := &master.ValueFilter{ActiveOnly: activeOnly}
	values, err := s.valueRepo.FindByTypeID(ctx, typeID, filter)
	if err != nil {
		return nil, err
	}

	result := make([]*ValueResponse, len(values))
	for i, v := range values {
		result[i] = s.valueToResponse(v)
	}

	return result, nil
}

func (s *Service) GetValuesByTypeCode(ctx context.Context, typeCode string, activeOnly bool) ([]*ValueResponse, error) {
	filter := &master.ValueFilter{ActiveOnly: activeOnly}
	values, err := s.valueRepo.FindByTypeCode(ctx, typeCode, filter)
	if err != nil {
		return nil, err
	}

	result := make([]*ValueResponse, len(values))
	for i, v := range values {
		result[i] = s.valueToResponse(v)
	}

	return result, nil
}

func (s *Service) GetCascadingValues(ctx context.Context, typeCode string, parentValueID *uint64) ([]*ValueResponse, error) {
	values, err := s.valueRepo.FindCascading(ctx, typeCode, parentValueID)
	if err != nil {
		return nil, err
	}

	result := make([]*ValueResponse, len(values))
	for i, v := range values {
		result[i] = s.valueToResponse(v)
	}

	return result, nil
}

// Helper methods
func (s *Service) typeToResponse(t *master.Type) *TypeResponse {
	resp := &TypeResponse{
		ID:          t.ID,
		ParentID:    t.ParentID,
		Code:        t.Code,
		Name:        t.Name,
		Description: t.Description,
		IsActive:    t.IsActive,
		SortOrder:   t.SortOrder,
		ValuesCount: t.ValuesCount,
		CreatedAt:   t.CreatedAt.Format("2006-01-02T15:04:05Z"),
		UpdatedAt:   t.UpdatedAt.Format("2006-01-02T15:04:05Z"),
	}

	return resp
}

func (s *Service) typeToResponseWithChildren(t *master.Type) *TypeResponse {
	resp := s.typeToResponse(t)

	if len(t.Children) > 0 {
		resp.Children = make([]*TypeResponse, len(t.Children))
		for i, child := range t.Children {
			resp.Children[i] = s.typeToResponseWithChildren(&child)
		}
	}

	return resp
}

func (s *Service) valueToResponse(v *master.Value) *ValueResponse {
	return &ValueResponse{
		ID:            v.ID,
		TypeID:        v.TypeID,
		ParentValueID: v.ParentValueID,
		Code:          v.Code,
		Name:          v.Name,
		Description:   v.Description,
		IsActive:      v.IsActive,
		SortOrder:     v.SortOrder,
		CreatedAt:     v.CreatedAt.Format("2006-01-02T15:04:05Z"),
		UpdatedAt:     v.UpdatedAt.Format("2006-01-02T15:04:05Z"),
	}
}

func isValidCode(code string) bool {
	if len(code) == 0 {
		return false
	}
	for _, c := range code {
		if !((c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_') {
			return false
		}
	}
	return true
}
