/// App-wide Constants for Guyub Mobile
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Guyub';
  static const String appTagline = 'Family Tree Platform';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUser = 'user';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyLastSync = 'last_sync';

  // Database
  static const String dbName = 'guyub_local.db';
  static const int dbVersion = 1;

  // Sync
  static const int syncIntervalMinutes = 15;
  static const int maxRetryCount = 3;
  static const int retryDelaySeconds = 5;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int maxBioLength = 500;
  static const int maxDescriptionLength = 1000;

  // File Upload
  static const int maxFileSizeMB = 10;
  static const int maxAvatarSizeMB = 5;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedDocTypes = ['pdf', 'doc', 'docx'];

  // Image
  static const int avatarQuality = 85;
  static const int maxAvatarWidth = 512;
  static const int maxAvatarHeight = 512;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Animation Durations (milliseconds)
  static const int animationFast = 150;
  static const int animationNormal = 300;
  static const int animationSlow = 500;

  // Debounce Duration (milliseconds)
  static const int debounceDelay = 300;
  static const int searchDebounceDelay = 500;

  // Toast Duration (seconds)
  static const int toastShort = 2;
  static const int toastLong = 4;

  // Supported Languages
  static const String defaultLanguage = 'id';
  static const List<String> supportedLanguages = ['id', 'en'];

  // Gender Options
  static const List<Map<String, String>> genderOptions = [
    {'value': 'male', 'label': 'Laki-laki'},
    {'value': 'female', 'label': 'Perempuan'},
    {'value': 'other', 'label': 'Lainnya'},
  ];

  // Relationship Types
  static const List<Map<String, String>> relationshipTypes = [
    {'value': 'parent', 'label': 'Orang Tua'},
    {'value': 'child', 'label': 'Anak'},
    {'value': 'spouse', 'label': 'Pasangan'},
    {'value': 'sibling', 'label': 'Saudara'},
  ];

  // Marriage Status Options
  static const List<Map<String, String>> marriageStatusOptions = [
    {'value': 'married', 'label': 'Menikah'},
    {'value': 'divorced', 'label': 'Cerai'},
    {'value': 'widowed', 'label': 'Janda/Duda'},
    {'value': 'engaged', 'label': 'Bertunangan'},
  ];

  // User Status Options
  static const List<Map<String, String>> userStatusOptions = [
    {'value': 'active', 'label': 'Aktif'},
    {'value': 'inactive', 'label': 'Tidak Aktif'},
    {'value': 'suspended', 'label': 'Ditangguhkan'},
    {'value': 'pending', 'label': 'Menunggu'},
  ];

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy, HH:mm';
  static const String timeFormat = 'HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  // Error Messages (Bahasa Indonesia)
  static const String errorGeneric = 'Terjadi kesalahan. Silakan coba lagi.';
  static const String errorNetwork = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
  static const String errorTimeout = 'Waktu permintaan habis. Silakan coba lagi.';
  static const String errorUnauthorized = 'Sesi Anda telah berakhir. Silakan login kembali.';
  static const String errorForbidden = 'Anda tidak memiliki akses ke halaman ini.';
  static const String errorNotFound = 'Data tidak ditemukan.';
  static const String errorServer = 'Terjadi kesalahan pada server.';
  static const String errorValidation = 'Data tidak valid. Periksa kembali input Anda.';
  static const String errorOffline = 'Anda sedang offline. Data akan disinkronkan saat online.';

  // Success Messages
  static const String successSaved = 'Data berhasil disimpan.';
  static const String successDeleted = 'Data berhasil dihapus.';
  static const String successUpdated = 'Data berhasil diperbarui.';
  static const String successSynced = 'Data berhasil disinkronkan.';

  // Empty States
  static const String emptyFamily = 'Belum ada keluarga. Buat keluarga pertama Anda!';
  static const String emptyPersons = 'Belum ada anggota keluarga. Tambahkan anggota pertama!';
  static const String emptySearch = 'Tidak ada hasil yang cocok dengan pencarian Anda.';
  static const String emptyData = 'Tidak ada data untuk ditampilkan.';
}
