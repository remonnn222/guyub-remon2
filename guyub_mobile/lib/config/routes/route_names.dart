/// Route Names Constants
class RouteNames {
  RouteNames._();

  // Auth
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';

  // Main
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  static const String settings = '/settings';

  // Family
  static const String families = '/families';
  static const String familyDetail = '/families/:id';
  static const String familyTree = '/families/:id/tree';
  static const String familyCreate = '/families/create';
  static const String familyEdit = '/families/:id/edit';

  // Person
  static const String persons = '/persons';
  static const String personDetail = '/persons/:id';
  static const String personCreate = '/persons/create';
  static const String personEdit = '/persons/:id/edit';

  // Users (Admin)
  static const String users = '/users';
  static const String userDetail = '/users/:id';
  static const String userCreate = '/users/create';
  static const String userEdit = '/users/:id/edit';

  // Roles (Admin)
  static const String roles = '/roles';
  static const String roleDetail = '/roles/:id';

  // Events
  static const String events = '/events';
  static const String eventDetail = '/events/:id';
  static const String eventCreate = '/events/create';
  static const String eventEdit = '/events/:id/edit';

  /// Build path with parameters
  static String buildPath(String path, Map<String, String> params) {
    String result = path;
    params.forEach((key, value) {
      result = result.replaceAll(':$key', value);
    });
    return result;
  }
}
