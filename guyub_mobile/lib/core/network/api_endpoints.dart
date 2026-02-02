import '../../config/constants/api_constants.dart';

/// API Endpoints helper class
/// Provides easy access to API endpoints with cleaner names
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static String get login => ApiConstants.login;
  static String get logout => ApiConstants.logout;
  static String get refresh => ApiConstants.refresh;
  static String get me => ApiConstants.me;
  static String get profile => ApiConstants.profile;
  static String get changePassword => ApiConstants.changePassword;

  // Users
  static String get users => ApiConstants.users;
  static String userById(int id) => '${ApiConstants.users}/$id';
  static String userRestore(int id) =>
      ApiConstants.buildPath(ApiConstants.usersRestore, {'id': id.toString()});
  static String get usersBulkDelete => ApiConstants.usersBulkDelete;
  static String get usersBulkRestore => ApiConstants.usersBulkRestore;
  static String get usersBulkAssignRole => ApiConstants.usersBulkAssignRole;

  // Roles
  static String get roles => ApiConstants.roles;
  static String roleById(int id) => '${ApiConstants.roles}/$id';
  static String get permissions => ApiConstants.permissions;
  static String rolePermissions(int id) =>
      ApiConstants.buildPath(ApiConstants.rolePermissions, {'id': id.toString()});

  // Families
  static String get families => ApiConstants.families;
  static String familyById(int id) => '${ApiConstants.families}/$id';
  static String familyTree(int id) =>
      ApiConstants.buildPath(ApiConstants.familyTree, {'id': id.toString()});
  static String familyPersons(int id) =>
      ApiConstants.buildPath(ApiConstants.familyPersons, {'id': id.toString()});
  static String get familyJoin => ApiConstants.familyJoin;

  // Persons
  static String get persons => ApiConstants.persons;
  static String personById(int id) => '${ApiConstants.persons}/$id';
  static String personRelationships(int id) =>
      ApiConstants.buildPath(ApiConstants.personRelationships, {'id': id.toString()});

  // Relationships
  static String get relationships => ApiConstants.relationships;
  static String relationshipById(int id) => '${ApiConstants.relationships}/$id';

  // Tree Positions
  static String get treePositions => ApiConstants.treePositions;
  static String get treePositionsBulkUpdate => ApiConstants.treePositionsBulkUpdate;

  // Master Data
  static String get masterTypes => ApiConstants.masterTypes;
  static String get masterValues => ApiConstants.masterValues;
  static String masterCascade(String typeCode) =>
      ApiConstants.buildPath(ApiConstants.masterCascade, {'type_code': typeCode});

  // Assets
  static String get assetsUpload => ApiConstants.assetsUpload;
  static String get assets => ApiConstants.assets;
  static String assetById(String id) => '${ApiConstants.assets}/$id';
  static String get assetsByRef => ApiConstants.assetsByRef;
  static String userAvatar(int id) =>
      ApiConstants.buildPath(ApiConstants.userAvatar, {'id': id.toString()});

  // Audit & Activity
  static String get audit => ApiConstants.audit;
  static String get activity => ApiConstants.activity;

  // Analytics
  static String get dashboard => ApiConstants.dashboard;
  static String get analytics => ApiConstants.analytics;

  // Health
  static String get health => ApiConstants.health;
}
