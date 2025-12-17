// ============================================
// Enums
// ============================================

export enum UserStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  SUSPENDED = 'suspended',
}

export enum UserType {
  INTERNAL = 'internal',
  CUSTOMER = 'customer',
  AGENT = 'agent',
}

export enum AuditEvent {
  CREATED = 'created',
  UPDATED = 'updated',
  DELETED = 'deleted',
  RESTORED = 'restored',
}

export enum ActivityType {
  LOGIN = 'login',
  LOGOUT = 'logout',
  PASSWORD_RESET = 'password_reset',
  PROFILE_UPDATE = 'profile_update',
  FAILED_LOGIN = 'failed_login',
}

// ============================================
// Base Types
// ============================================

export interface BaseEntity {
  id: number;
  created_at: string;
  updated_at: string;
}

export interface SoftDeleteEntity extends BaseEntity {
  deleted_at: string | null;
}

// ============================================
// User Types
// ============================================

export interface User extends SoftDeleteEntity {
  name: string;
  email: string;
  email_verified_at: string | null;
  phone: string | null;
  avatar_url: string | null;
  status: UserStatus;
  type: UserType;
  two_factor_enabled: boolean;
  roles: Role[];
  permissions: Permission[];
}

export interface UserFormData {
  name: string;
  email: string;
  phone?: string;
  password?: string;
  password_confirmation?: string;
  status: UserStatus;
  type: UserType;
  role_ids: number[];
  two_factor_enabled?: boolean;
}

export interface UserFilters {
  search?: string;
  status?: UserStatus;
  type?: UserType;
  role_id?: number;
  with_trashed?: boolean;
  only_trashed?: boolean;
}

// ============================================
// Role & Permission Types
// ============================================

export interface Permission extends BaseEntity {
  name: string;
  guard_name: string;
}

export interface Role extends BaseEntity {
  name: string;
  guard_name: string;
  description: string | null;
  level: number;
  permissions: Permission[];
  users_count?: number;
}

export interface RoleFormData {
  name: string;
  description?: string;
  level: number;
  permission_ids: number[];
}

// ============================================
// Master Data Types
// ============================================

export interface MasterType extends BaseEntity {
  parent_id: number | null;
  code: string;
  name: string;
  description: string | null;
  is_active: boolean;
  sort_order: number;
  children?: MasterType[];
  values?: MasterValue[];
}

export interface MasterValue extends BaseEntity {
  type_id: number;
  parent_value_id: number | null;
  code: string;
  name: string;
  description: string | null;
  metadata: Record<string, unknown> | null;
  is_active: boolean;
  sort_order: number;
  children?: MasterValue[];
}

export interface MasterTypeFormData {
  parent_id?: number | null;
  code: string;
  name: string;
  description?: string;
  is_active: boolean;
  sort_order?: number;
}

export interface MasterValueFormData {
  type_id: number;
  parent_value_id?: number | null;
  code: string;
  name: string;
  description?: string;
  metadata?: Record<string, unknown>;
  is_active: boolean;
  sort_order?: number;
}

// ============================================
// Audit Types
// ============================================

export interface AuditLog extends BaseEntity {
  user_id: number | null;
  event: AuditEvent;
  auditable_type: string;
  auditable_id: number;
  old_values: Record<string, unknown> | null;
  new_values: Record<string, unknown> | null;
  url: string | null;
  ip_address: string | null;
  user_agent: string | null;
  user?: User | null;
}

export interface AuditFilters {
  user_id?: number;
  event?: AuditEvent;
  auditable_type?: string;
  auditable_id?: number;
  date_from?: string;
  date_to?: string;
}

// ============================================
// Activity Types
// ============================================

export interface ActivityLog extends BaseEntity {
  user_id: number;
  activity_type: ActivityType;
  description: string | null;
  ip_address: string | null;
  user_agent: string | null;
  device_type: string | null;
  browser: string | null;
  platform: string | null;
  location: string | null;
  user?: User;
}

export interface ActivityFilters {
  user_id?: number;
  activity_type?: ActivityType;
  date_from?: string;
  date_to?: string;
}

// ============================================
// Asset Types
// ============================================

export type AssetKind = 'user_avatar' | 'product_image' | 'document' | 'attachment';

export interface Asset {
  id: string; // UUID
  ref_id?: string;
  kind: AssetKind;
  title?: string;
  original_filename: string;
  mime_type: string;
  file_size: number;
  human_size: string;
  url: string;
  is_image: boolean;
  created_at: string;
}

// ============================================
// Auth Types
// ============================================

export interface LoginCredentials {
  email: string;
  password: string;
  remember?: boolean;
}

export interface AuthTokens {
  access_token: string;
  refresh_token: string;
  token_type: string;
  expires_in: number;
}

export interface AuthState {
  user: User | null;
  tokens: AuthTokens | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}

// ============================================
// API Response Types
// ============================================

export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
}

export interface ApiErrorResponse {
  success: boolean;
  message: string;
  errors?: Record<string, string[]>;
}

export interface PaginatedResponse<T> {
  success: boolean;
  message: string;
  data: T[];
  meta: PaginationMeta;
}

export interface PaginationMeta {
  current_page: number;
  per_page: number;
  total: number;
  total_pages: number;
  from: number;
  to: number;
}

export interface PaginationParams {
  page?: number;
  per_page?: number;
  sort_by?: string;
  sort_order?: 'asc' | 'desc';
}

// ============================================
// Analytics Types
// ============================================

export interface DashboardStats {
  total_users: number;
  active_users: number;
  total_roles: number;
  total_permissions: number;
  recent_activities: ActivityLog[];
  user_growth: ChartData[];
  activity_trends: ChartData[];
}

export interface ChartData {
  label: string;
  value: number;
}

// ============================================
// UI Types
// ============================================

export interface SelectOption {
  value: string | number;
  label: string;
}

export interface TableColumn<T> {
  key: keyof T | string;
  label: string;
  sortable?: boolean;
  render?: (item: T) => React.ReactNode;
  className?: string;
}

export interface BreadcrumbItem {
  label: string;
  href?: string;
}

export interface MenuItem {
  label: string;
  icon?: React.ReactNode;
  href?: string;
  onClick?: () => void;
  children?: MenuItem[];
  permission?: string;
}

// ============================================
// Form Types
// ============================================

export interface FormFieldProps {
  label: string;
  name: string;
  error?: string;
  required?: boolean;
  helpText?: string;
}

export interface ConfirmDialogProps {
  title: string;
  message: string;
  confirmLabel?: string;
  cancelLabel?: string;
  variant?: 'danger' | 'warning' | 'info';
  onConfirm: () => void;
  onCancel: () => void;
}

// ============================================
// Family Hierarchy Types
// ============================================

export enum Gender {
  MALE = 'male',
  FEMALE = 'female',
  OTHER = 'other',
}

export enum MemberRole {
  OWNER = 'owner',
  ADMIN = 'admin',
  EDITOR = 'editor',
  VIEWER = 'viewer',
}

export enum RelationshipType {
  PARENT = 'parent',
  CHILD = 'child',
  SPOUSE = 'spouse',
  SIBLING = 'sibling',
  STEP_PARENT = 'step_parent',
  STEP_CHILD = 'step_child',
  ADOPTIVE_PARENT = 'adoptive_parent',
  ADOPTED_CHILD = 'adopted_child',
}

export enum MarriageStatus {
  MARRIED = 'married',
  DIVORCED = 'divorced',
  WIDOWED = 'widowed',
  SEPARATED = 'separated',
  ENGAGED = 'engaged',
  PARTNER = 'partner',
}

export interface Family {
  id: string; // UUID
  name: string;
  description: string | null;
  origin: string | null;
  motto: string | null;
  coat_of_arms: string | null;
  cover_image: string | null;
  is_public: boolean;
  invite_code: string;
  created_by: number;
  created_at: string;
  updated_at: string;
  members?: FamilyMember[];
  persons?: Person[];
}

export interface FamilyFormData {
  name: string;
  description?: string;
  origin?: string;
  motto?: string;
  is_public?: boolean;
}

export interface FamilyMember {
  id: number;
  family_id: string;
  user_id: number;
  person_id: string | null;
  role: MemberRole;
  joined_at: string;
  created_at: string;
  updated_at: string;
  user?: User;
  person?: Person;
}

export interface Person {
  id: string; // UUID
  family_id: string;
  first_name: string;
  last_name: string;
  nickname: string | null;
  gender: Gender;
  birth_date: string | null;
  birth_place: string | null;
  death_date: string | null;
  death_place: string | null;
  is_alive: boolean;
  photo_url: string | null;
  bio: string | null;
  occupation: string | null;
  education: string | null;
  email: string | null;
  phone: string | null;
  address: string | null;
  generation_level: number;
  created_by: number;
  created_at: string;
  updated_at: string;
  // Computed fields
  parents?: Person[];
  children?: Person[];
  spouses?: Person[];
  siblings?: Person[];
  tree_position?: TreePosition;
}

export interface PersonFormData {
  family_id: string;
  first_name: string;
  last_name: string;
  nickname?: string;
  gender: Gender;
  birth_date?: string;
  birth_place?: string;
  death_date?: string;
  death_place?: string;
  is_alive?: boolean;
  photo_url?: string;
  bio?: string;
  occupation?: string;
  education?: string;
  email?: string;
  phone?: string;
  address?: string;
  generation_level?: number;
}

export interface Relationship {
  id: number;
  person_id: string;
  related_person_id: string;
  type: RelationshipType;
  marriage_status: MarriageStatus | null;
  marriage_date: string | null;
  marriage_place: string | null;
  divorce_date: string | null;
  notes: string | null;
  created_by: number;
  created_at: string;
  updated_at: string;
  person?: Person;
  related_person?: Person;
}

export interface RelationshipFormData {
  person_id: string;
  related_person_id: string;
  type: RelationshipType;
  marriage_status?: MarriageStatus;
  marriage_date?: string;
  marriage_place?: string;
  divorce_date?: string;
  notes?: string;
}

export interface TreePosition {
  id: number;
  person_id: string;
  family_id: string;
  x: number;
  y: number;
  level: number;
  order: number;
  created_at: string;
  updated_at: string;
}

export interface FamilyTreeData {
  family: Family;
  persons: Person[];
  relationships: Relationship[];
  positions: TreePosition[];
  root_persons: Person[];
  statistics: FamilyTreeStatistics;
}

export interface FamilyTreeStatistics {
  total_persons: number;
  total_living: number;
  total_deceased: number;
  total_male: number;
  total_female: number;
  generations: number;
  oldest_person: Person | null;
  youngest_person: Person | null;
  total_marriages: number;
  average_children: number;
  by_generation: Record<number, number>;
  by_decade: Record<string, number>;
}

// React Flow Types for Family Tree Visualization
export interface FamilyTreeNode {
  id: string;
  type: 'person' | 'couple';
  position: { x: number; y: number };
  data: {
    person?: Person;
    couple?: { person1: Person; person2: Person };
    isHighlighted?: boolean;
    onEdit?: (person: Person) => void;
    onAddRelative?: (person: Person, type: RelationshipType) => void;
  };
}

export interface FamilyTreeEdge {
  id: string;
  source: string;
  target: string;
  type: 'parent-child' | 'spouse' | 'sibling';
  animated?: boolean;
  style?: React.CSSProperties;
}
