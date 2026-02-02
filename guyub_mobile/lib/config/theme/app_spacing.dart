import 'package:flutter/material.dart';

/// Guyub Platform Spacing System
/// Based on 4px base unit (same as Tailwind CSS)
class AppSpacing {
  AppSpacing._();

  // Base Unit
  static const double unit = 4.0;

  // Spacing Scale
  static const double none = 0.0;        // 0
  static const double xxxs = 2.0;        // 0.5
  static const double xxs = 4.0;         // 1
  static const double xs = 8.0;          // 2
  static const double sm = 12.0;         // 3
  static const double md = 16.0;         // 4
  static const double lg = 20.0;         // 5
  static const double xl = 24.0;         // 6
  static const double xxl = 32.0;        // 8
  static const double xxxl = 40.0;       // 10
  static const double xxxxl = 48.0;      // 12
  static const double xxxxxl = 64.0;     // 16

  // Named Spacing (Semantic)
  static const double pagePadding = 16.0;
  static const double pageMargin = 16.0;
  static const double cardPadding = 16.0;
  static const double cardMargin = 12.0;
  static const double listItemPadding = 16.0;
  static const double listItemSpacing = 8.0;
  static const double sectionSpacing = 24.0;
  static const double formFieldSpacing = 16.0;
  static const double buttonPadding = 16.0;
  static const double iconSpacing = 8.0;
  static const double chipSpacing = 8.0;
  static const double dialogPadding = 24.0;
  static const double bottomSheetPadding = 16.0;
  static const double appBarPadding = 16.0;

  // Border Radius
  static const double radiusNone = 0.0;
  static const double radiusXs = 4.0;
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 9999.0;

  // Icon Sizes
  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 40.0;

  // Avatar Sizes
  static const double avatarXs = 24.0;
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 48.0;
  static const double avatarXl = 64.0;
  static const double avatarXxl = 80.0;
  static const double avatarXxxl = 96.0;

  // Button Heights
  static const double buttonHeightSm = 32.0;
  static const double buttonHeightMd = 40.0;
  static const double buttonHeightLg = 48.0;
  static const double buttonHeightXl = 56.0;

  // Input Heights
  static const double inputHeightSm = 32.0;
  static const double inputHeightMd = 40.0;
  static const double inputHeightLg = 48.0;

  // Card Elevation
  static const double elevationNone = 0.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;

  // Family Tree Node
  static const double treeNodeWidth = 120.0;
  static const double treeNodeHeight = 140.0;
  static const double treeNodeSpacing = 100.0;
  static const double treeLevelSpacing = 150.0;
  static const double treeNodeAvatarSize = 48.0;

  // App Bar Heights
  static const double appBarHeight = 56.0;
  static const double appBarExpandedHeight = 200.0;

  // Bottom Navigation
  static const double bottomNavHeight = 60.0;
  static const double bottomNavIconSize = 24.0;

  // FAB
  static const double fabSize = 56.0;
  static const double fabMiniSize = 40.0;

  // EdgeInsets Helpers
  static const EdgeInsets paddingAll0 = EdgeInsets.all(none);
  static const EdgeInsets paddingAll4 = EdgeInsets.all(xxs);
  static const EdgeInsets paddingAll8 = EdgeInsets.all(xs);
  static const EdgeInsets paddingAll12 = EdgeInsets.all(sm);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(md);
  static const EdgeInsets paddingAll20 = EdgeInsets.all(lg);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(xl);
  static const EdgeInsets paddingAll32 = EdgeInsets.all(xxl);

  static const EdgeInsets paddingHorizontal4 = EdgeInsets.symmetric(horizontal: xxs);
  static const EdgeInsets paddingHorizontal8 = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHorizontal12 = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontal16 = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontal20 = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontal24 = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets paddingVertical4 = EdgeInsets.symmetric(vertical: xxs);
  static const EdgeInsets paddingVertical8 = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVertical12 = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVertical16 = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVertical20 = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVertical24 = EdgeInsets.symmetric(vertical: xl);

  static const EdgeInsets paddingPage = EdgeInsets.all(pagePadding);
  static const EdgeInsets paddingCard = EdgeInsets.all(cardPadding);
  static const EdgeInsets paddingDialog = EdgeInsets.all(dialogPadding);

  // SizedBox Helpers
  static const SizedBox height0 = SizedBox(height: none);
  static const SizedBox height4 = SizedBox(height: xxs);
  static const SizedBox height8 = SizedBox(height: xs);
  static const SizedBox height12 = SizedBox(height: sm);
  static const SizedBox height16 = SizedBox(height: md);
  static const SizedBox height20 = SizedBox(height: lg);
  static const SizedBox height24 = SizedBox(height: xl);
  static const SizedBox height32 = SizedBox(height: xxl);
  static const SizedBox height40 = SizedBox(height: xxxl);
  static const SizedBox height48 = SizedBox(height: xxxxl);

  static const SizedBox width0 = SizedBox(width: none);
  static const SizedBox width4 = SizedBox(width: xxs);
  static const SizedBox width8 = SizedBox(width: xs);
  static const SizedBox width12 = SizedBox(width: sm);
  static const SizedBox width16 = SizedBox(width: md);
  static const SizedBox width20 = SizedBox(width: lg);
  static const SizedBox width24 = SizedBox(width: xl);
  static const SizedBox width32 = SizedBox(width: xxl);

  // Semantic SizedBox Helpers (for cleaner code)
  static const SizedBox verticalXS = SizedBox(height: xs);
  static const SizedBox verticalSM = SizedBox(height: sm);
  static const SizedBox verticalMD = SizedBox(height: md);
  static const SizedBox verticalLG = SizedBox(height: lg);
  static const SizedBox verticalXL = SizedBox(height: xl);

  static const SizedBox horizontalXS = SizedBox(width: xs);
  static const SizedBox horizontalSM = SizedBox(width: sm);
  static const SizedBox horizontalMD = SizedBox(width: md);
  static const SizedBox horizontalLG = SizedBox(width: lg);
  static const SizedBox horizontalXL = SizedBox(width: xl);

  // Semantic EdgeInsets Helpers
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  // BorderRadius Helpers
  static BorderRadius get borderRadiusXs => BorderRadius.circular(radiusXs);
  static BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadiusXxl => BorderRadius.circular(radiusXxl);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(radiusFull);

  // Responsive Breakpoints
  static const double breakpointXs = 0;
  static const double breakpointSm = 600;
  static const double breakpointMd = 960;
  static const double breakpointLg = 1280;
  static const double breakpointXl = 1920;

  /// Check if current width is considered "wide" (tablet/landscape)
  static bool isWideScreen(double width) => width >= breakpointSm;

  /// Get responsive padding based on screen width
  static EdgeInsets responsivePadding(double width) {
    if (width >= breakpointLg) return paddingAll32;
    if (width >= breakpointMd) return paddingAll24;
    if (width >= breakpointSm) return paddingAll20;
    return paddingAll16;
  }
}
