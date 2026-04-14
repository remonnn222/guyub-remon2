/// API Constants for Guyub Mobile
class ApiConstants {
  ApiConstants._();

  // Base URL - Change based on environment
  static const String baseUrl = 'http://192.168.1.100:8080/api/v1';
  // Alternative URLs
  static const String localUrl = 'http://localhost:8080/api/v1';
  static const String androidEmulatorUrl = 'http://10.0.2.2:8080/api/v1';
  static const String physicalDeviceUrl = 'http://192.168.2.164:8080/api/v1';
  static const String productionUrl = 'https://api.guyub.id/api/v1';

  // Timeouts (in milliseconds)
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // Headers
  static const String contentType = 'application/json';
  static const String acceptHeader = 'application/json';
  static const String authHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer';

  // Endpoints - Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
  static const String profile = '/auth/profile';
  static const String changePassword = '/auth/change-password';

  // Endpoints - Users
  static const String users = '/users';
  static const String usersRestore = '/users/{id}/restore';
  static const String usersBulkDelete = '/users/bulk/delete';
  static const String usersBulkRestore = '/users/bulk/restore';
  static const String usersBulkAssignRole = '/users/bulk/assign-role';

  // Endpoints - Roles
  static const String roles = '/roles';
  static const String permissions = '/permissions';
  static const String rolePermissions = '/roles/{id}/permissions';

  // Endpoints - Family
  static const String families = '/families';
  static const String familyTree = '/families/{id}/tree';
  static const String familyPersons = '/families/{id}/persons';
  static const String familyJoin = '/families/join';

  // Endpoints - Persons
  static const String persons = '/persons';
  static const String personRelationships = '/persons/{id}/relationships';

  // Endpoints - Relationships
  static const String relationships = '/relationships';

  // Endpoints - Tree Positions
  static const String treePositions = '/tree-positions';
  static const String treePositionsBulkUpdate = '/tree-positions/bulk';

  // Endpoints - Events **NEW**
  static const String events = '/events';
  static const String eventDetail = '/events/{id}';
  static const String eventApprove = '/events/{id}/approve';
  static const String eventReject = '/events/{id}/reject';

  // Endpoints - Master Data
  static const String masterTypes = '/master/types';
  static const String masterValues = '/master/values';
  static const String masterCascade = '/master/cascade/{type_code}';

  // Endpoints - Assets
  static const String assetsUpload = '/assets/upload';
  static const String assets = '/assets';
  static const String assetsByRef = '/assets/by-ref';
  static const String userAvatar = '/assets/user/{id}/avatar';

  // Endpoints - Audit & Activity
  static const String audit = '/audit';
  static const String activity = '/activity';

  // Endpoints - Analytics
  static const String dashboard = '/analytics/dashboard';
  static const String analytics = '/analytics';

  // Endpoints - Health
  static const String health = '/health';

  // Pagination defaults
  static const int defaultPage = 1;
  static const int defaultLimit = 20;
  static const int maxLimit = 100;

  /// Build endpoint with path parameters
  static String buildPath(String endpoint, Map<String, String> params) {
    String result = endpoint;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}
