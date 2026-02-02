/// Input Sanitizer
/// Provides methods to sanitize and validate user input
class InputSanitizer {
  InputSanitizer._();

  /// Remove leading/trailing whitespace and normalize internal spaces
  static String sanitizeText(String? input) {
    if (input == null || input.isEmpty) return '';
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Sanitize email - lowercase and trim
  static String sanitizeEmail(String? input) {
    if (input == null || input.isEmpty) return '';
    return input.trim().toLowerCase();
  }

  /// Sanitize phone number - remove non-digit characters except +
  static String sanitizePhone(String? input) {
    if (input == null || input.isEmpty) return '';
    return input.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// Sanitize username - lowercase, trim, remove special chars
  static String sanitizeUsername(String? input) {
    if (input == null || input.isEmpty) return '';
    return input.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '');
  }

  /// Sanitize code/identifier - uppercase, trim, alphanumeric only
  static String sanitizeCode(String? input) {
    if (input == null || input.isEmpty) return '';
    return input.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  }

  /// Remove potentially dangerous HTML/script characters
  static String sanitizeHtml(String? input) {
    if (input == null || input.isEmpty) return '';
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  /// Sanitize for SQL (basic - prefer parameterized queries)
  static String sanitizeSql(String? input) {
    if (input == null || input.isEmpty) return '';
    return input.replaceAll("'", "''").replaceAll(';', '');
  }

  /// Truncate string to max length
  static String truncate(String? input, int maxLength) {
    if (input == null || input.isEmpty) return '';
    if (input.length <= maxLength) return input;
    return '${input.substring(0, maxLength - 3)}...';
  }

  /// Sanitize filename - remove path separators and special chars
  static String sanitizeFilename(String? input) {
    if (input == null || input.isEmpty) return '';
    return input
        .replaceAll(RegExp(r'[/\\:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\.{2,}'), '.')
        .trim();
  }

  /// Validate and sanitize URL
  static String? sanitizeUrl(String? input) {
    if (input == null || input.isEmpty) return null;
    final trimmed = input.trim();

    // Basic URL validation
    final urlPattern = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
      caseSensitive: false,
    );

    if (!urlPattern.hasMatch(trimmed)) return null;
    return trimmed;
  }
}

/// Input Validators
/// Provides validation methods for form fields
class InputValidators {
  InputValidators._();

  /// Validate required field
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field ini'} wajib diisi';
    }
    return null;
  }

  /// Validate email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) return null; // Let required handle this

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int min, [String? fieldName]) {
    if (value == null || value.isEmpty) return null;
    if (value.length < min) {
      return '${fieldName ?? 'Field ini'} minimal $min karakter';
    }
    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int max, [String? fieldName]) {
    if (value == null || value.isEmpty) return null;
    if (value.length > max) {
      return '${fieldName ?? 'Field ini'} maksimal $max karakter';
    }
    return null;
  }

  /// Validate password strength
  static String? password(String? value) {
    if (value == null || value.isEmpty) return null;

    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password harus mengandung huruf kecil';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password harus mengandung huruf besar';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password harus mengandung angka';
    }

    return null;
  }

  /// Validate password confirmation
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) return null;
    if (value != password) {
      return 'Konfirmasi password tidak cocok';
    }
    return null;
  }

  /// Validate phone number
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;

    final phoneRegex = RegExp(r'^(\+62|62|0)[0-9]{9,12}$');
    final sanitized = InputSanitizer.sanitizePhone(value);

    if (!phoneRegex.hasMatch(sanitized)) {
      return 'Format nomor telepon tidak valid';
    }
    return null;
  }

  /// Validate numeric input
  static String? numeric(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) return null;
    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'Field ini'} harus berupa angka';
    }
    return null;
  }

  /// Validate positive number
  static String? positiveNumber(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) return null;
    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return '${fieldName ?? 'Field ini'} harus berupa angka positif';
    }
    return null;
  }

  /// Validate date
  static String? date(String? value, [String? format]) {
    if (value == null || value.isEmpty) return null;
    try {
      DateTime.parse(value);
      return null;
    } catch (_) {
      return 'Format tanggal tidak valid';
    }
  }

  /// Validate URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) return null;
    if (InputSanitizer.sanitizeUrl(value) == null) {
      return 'Format URL tidak valid';
    }
    return null;
  }

  /// Validate invite code
  static String? inviteCode(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.trim().length < 6) {
      return 'Kode undangan minimal 6 karakter';
    }
    if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(value.trim())) {
      return 'Kode undangan hanya boleh huruf dan angka';
    }
    return null;
  }

  /// Combine multiple validators
  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
}
