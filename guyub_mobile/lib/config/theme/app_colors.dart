import 'package:flutter/material.dart';

/// Guyub Platform Color System
/// Based on Emerald/Green theme matching the web application
class AppColors {
  AppColors._();

  // Primary Colors (Emerald)
  static const Color primary = Color(0xFF059669);      // emerald-600
  static const Color primaryLight = Color(0xFF10B981); // emerald-500
  static const Color primaryDark = Color(0xFF047857);  // emerald-700
  static const Color primaryBackground = Color(0xFFD1FAE5); // emerald-100

  // Secondary Colors
  static const Color secondary = Color(0xFF6B7280);    // gray-500
  static const Color secondaryLight = Color(0xFF9CA3AF); // gray-400
  static const Color secondaryDark = Color(0xFF4B5563); // gray-600

  // Semantic Colors
  static const Color success = Color(0xFF22C55E);      // green-500
  static const Color warning = Color(0xFFF59E0B);      // amber-500
  static const Color error = Color(0xFFEF4444);        // red-500
  static const Color danger = Color(0xFFEF4444);       // red-500 (alias)
  static const Color info = Color(0xFF3B82F6);         // blue-500

  // Family Tree Node Colors
  static const Color maleNode = Color(0xFF3B82F6);     // blue-500
  static const Color maleNodeLight = Color(0xFFDBEAFE); // blue-100
  static const Color femaleNode = Color(0xFFEC4899);   // pink-500
  static const Color femaleNodeLight = Color(0xFFFCE7F3); // pink-100
  static const Color otherNode = Color(0xFF8B5CF6);    // purple-500
  static const Color otherNodeLight = Color(0xFFEDE9FE); // purple-100

  // Relationship Edge Colors
  static const Color parentChildEdge = Color(0xFF6B7280); // gray-500
  static const Color spouseEdge = Color(0xFFEC4899);      // pink-500

  // Background Colors
  static const Color background = Color(0xFFF9FAFB);   // gray-50
  static const Color surface = Color(0xFFFFFFFF);      // white
  static const Color surfaceVariant = Color(0xFFF3F4F6); // gray-100
  static const Color scaffold = Color(0xFFF9FAFB);     // gray-50

  // Border Colors
  static const Color border = Color(0xFFE5E7EB);       // gray-200
  static const Color borderLight = Color(0xFFF3F4F6);  // gray-100
  static const Color borderDark = Color(0xFFD1D5DB);   // gray-300
  static const Color divider = Color(0xFFE5E7EB);      // gray-200

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);  // gray-900
  static const Color textSecondary = Color(0xFF6B7280); // gray-500
  static const Color textTertiary = Color(0xFF9CA3AF); // gray-400
  static const Color textOnPrimary = Color(0xFFFFFFFF); // white
  static const Color textDisabled = Color(0xFF9CA3AF); // gray-400
  static const Color textLink = Color(0xFF059669);     // emerald-600

  // Icon Colors
  static const Color iconPrimary = Color(0xFF6B7280);  // gray-500
  static const Color iconSecondary = Color(0xFF9CA3AF); // gray-400
  static const Color iconOnPrimary = Color(0xFFFFFFFF); // white

  // Status Colors
  static const Color statusActive = Color(0xFF22C55E);   // green-500
  static const Color statusInactive = Color(0xFF9CA3AF); // gray-400
  static const Color statusPending = Color(0xFFF59E0B);  // amber-500
  static const Color statusSuspended = Color(0xFFEF4444); // red-500

  // Overlay Colors
  static const Color overlay = Color(0x80000000);      // black 50%
  static const Color overlayLight = Color(0x1A000000); // black 10%

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);       // black 10%
  static const Color shadowDark = Color(0x33000000);   // black 20%

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF111827);  // gray-900
  static const Color darkSurface = Color(0xFF1F2937);     // gray-800
  static const Color darkSurfaceVariant = Color(0xFF374151); // gray-700
  static const Color darkBorder = Color(0xFF374151);      // gray-700
  static const Color darkTextPrimary = Color(0xFFF9FAFB); // gray-50
  static const Color darkTextSecondary = Color(0xFF9CA3AF); // gray-400

  // Material Color Swatch for Primary
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF059669,
    <int, Color>{
      50: Color(0xFFECFDF5),
      100: Color(0xFFD1FAE5),
      200: Color(0xFFA7F3D0),
      300: Color(0xFF6EE7B7),
      400: Color(0xFF34D399),
      500: Color(0xFF10B981),
      600: Color(0xFF059669),
      700: Color(0xFF047857),
      800: Color(0xFF065F46),
      900: Color(0xFF064E3B),
    },
  );

  /// Get gender-based node color
  static Color getGenderColor(String? gender) {
    switch (gender?.toLowerCase()) {
      case 'male':
      case 'laki-laki':
        return maleNode;
      case 'female':
      case 'perempuan':
        return femaleNode;
      default:
        return otherNode;
    }
  }

  /// Get gender-based node background color
  static Color getGenderBackgroundColor(String? gender) {
    switch (gender?.toLowerCase()) {
      case 'male':
      case 'laki-laki':
        return maleNodeLight;
      case 'female':
      case 'perempuan':
        return femaleNodeLight;
      default:
        return otherNodeLight;
    }
  }

  /// Get status color
  static Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
      case 'aktif':
        return statusActive;
      case 'inactive':
      case 'tidak aktif':
        return statusInactive;
      case 'pending':
      case 'menunggu':
        return statusPending;
      case 'suspended':
      case 'ditangguhkan':
        return statusSuspended;
      default:
        return secondary;
    }
  }
}
