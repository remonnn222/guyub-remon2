import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_typography.dart';

/// App Button Variants
enum AppButtonVariant { primary, secondary, outlined, danger, ghost }

/// App Button Sizes
enum AppButtonSize { small, medium, large }

/// Reusable App Button Widget
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final bool isLoading;
  final bool isFullWidth;
  final bool isDisabled;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.leftIcon,
    this.rightIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isDisabled && !isLoading && onPressed != null;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: _buildButton(isEnabled),
    );
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return AppSpacing.buttonHeightSm;
      case AppButtonSize.medium:
        return AppSpacing.buttonHeightMd;
      case AppButtonSize.large:
        return AppSpacing.buttonHeightLg;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.sm);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.md);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.xl);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return AppTypography.buttonSmall;
      case AppButtonSize.medium:
        return AppTypography.buttonMedium;
      case AppButtonSize.large:
        return AppTypography.buttonLarge;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }

  Widget _buildButton(bool isEnabled) {
    switch (variant) {
      case AppButtonVariant.primary:
        return _buildElevatedButton(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          isEnabled: isEnabled,
        );
      case AppButtonVariant.secondary:
        return _buildElevatedButton(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.textOnPrimary,
          isEnabled: isEnabled,
        );
      case AppButtonVariant.danger:
        return _buildElevatedButton(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.textOnPrimary,
          isEnabled: isEnabled,
        );
      case AppButtonVariant.outlined:
        return _buildOutlinedButton(isEnabled);
      case AppButtonVariant.ghost:
        return _buildTextButton(isEnabled);
    }
  }

  Widget _buildElevatedButton({
    required Color backgroundColor,
    required Color foregroundColor,
    required bool isEnabled,
  }) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: backgroundColor.withValues(alpha: 0.5),
        disabledForegroundColor: foregroundColor.withValues(alpha: 0.7),
        elevation: 0,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
        ),
      ),
      child: _buildContent(foregroundColor),
    );
  }

  Widget _buildOutlinedButton(bool isEnabled) {
    return OutlinedButton(
      onPressed: isEnabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(
          color: isEnabled ? AppColors.primary : AppColors.border,
        ),
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
        ),
      ),
      child: _buildContent(AppColors.primary),
    );
  }

  Widget _buildTextButton(bool isEnabled) {
    return TextButton(
      onPressed: isEnabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
        ),
      ),
      child: _buildContent(AppColors.primary),
    );
  }

  Widget _buildContent(Color foregroundColor) {
    if (isLoading) {
      return SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leftIcon != null) ...[
          Icon(leftIcon, size: _getIconSize()),
          SizedBox(width: size == AppButtonSize.small ? 4 : 8),
        ],
        Text(label, style: _getTextStyle()),
        if (rightIcon != null) ...[
          SizedBox(width: size == AppButtonSize.small ? 4 : 8),
          Icon(rightIcon, size: _getIconSize()),
        ],
      ],
    );
  }
}
