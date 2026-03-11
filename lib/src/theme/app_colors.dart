import 'package:flutter/material.dart';

/// App color constants based on Figma design.
/// Centralized color definitions for consistent theming.
/// Supports both light and dark mode color schemes.
class AppColors {
  // ============================================
  // LIGHT THEME COLORS
  // ============================================

  // Primary colors
  static const Color primary = Color(
    0xFF4284F3,
  ); // Quest Blue for sidebar and accents
  static const Color primaryDark = Color(0xFF4284F3); // Darker blue variant

  // Background colors
  static const Color background = Color(0xFFFFFFFF); // White
  static const Color surface = Color(0xFFFFFFFF); // White surface

  // Text colors
  static const Color textPrimary = Color(0xFF0A2D6D); // Dark blue for headers
  static const Color textTitle = Color(0xFF0A2D6D); // System Blue for main titles
  static const Color textSecondary = Color(0xFF000000); // Black for body text

  // Sidebar colors
  static const Color sidebarBackground = Color(0xFF4284F3); // Quest Blue sidebar
  static const Color sidebarItemBackground = Color(0xFFD9D9D9); // Gray buttons
  static const Color sidebarItemActive = Color(0xFFFFFFFF); // White for active
  static const Color sidebarItemText = Color(0xFF000000); // Black text

  // Card colors
  static const Color cardBorder = Color(0xFF4284F3); // Quest Blue border
  static const Color cardBackground = Color(0xFFFFFFFF); // White background

  // Neutral colors
  static const Color neutral = Color(0xFFD9D9D9); // Light gray
  static const Color divider = Color(0xFFE0E0E0); // Divider gray
  static const Color textSubtle = Color(0xFF6B7280); // Subtle text (gray-500)

  // ============================================
  // DARK THEME COLORS
  // ============================================

  // Primary colors (slightly brighter for dark mode)
  static const Color primaryDarkMode = Color(0xFF6B9AFF);
  static const Color primaryDarkModeDark = Color(0xFF4284F3);

  // Background colors
  static const Color backgroundDark = Color(0xFF121218); // Deep dark
  static const Color surfaceDark = Color(0xFF1E1E26); // Slightly lighter

  // Text colors
  static const Color textPrimaryDark = Color(
    0xFFB4C7F5,
  ); // Light blue for headers
  static const Color textTitleDark = Color(
    0xFFE8EEFF,
  ); // Almost white for main titles
  static const Color textSecondaryDark = Color(
    0xFFE0E0E0,
  ); // Light gray for body

  // Sidebar colors
  static const Color sidebarBackgroundDark = Color(0xFF1A1A24); // Dark sidebar
  static const Color sidebarItemBackgroundDark = Color(
    0xFF2A2A36,
  ); // Dark gray buttons
  static const Color sidebarItemActiveDark = Color(
    0xFF3A3A4A,
  ); // Lighter for active
  static const Color sidebarItemTextDark = Color(0xFFE0E0E0); // Light text

  // Card colors
  static const Color cardBorderDark = Color(0xFF6B9AFF); // Brighter blue border
  static const Color cardBackgroundDark = Color(
    0xFF1E1E26,
  ); // Dark card background

  // Neutral colors
  static const Color neutralDark = Color(0xFF3A3A46); // Dark gray
  static const Color dividerDark = Color(0xFF2A2A36); // Dark divider
  static const Color textSubtleDark = Color(
    0xFF9CA3AF,
  ); // Subtle text dark (gray-400)

  // ============================================
  // SEMANTIC COLORS (same for both themes)
  // ============================================

  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  // Speaking indicator color
  static const Color speakingIndicator = Color(0xFF4CAF50);
  static const Color speakingIndicatorDark = Color(0xFF66BB6A);

  // Skeleton loading colors
  static const Color skeletonBase = Color(0xFFE0E0E0);
  static const Color skeletonHighlight = Color(0xFFF5F5F5);
  static const Color skeletonBaseDark = Color(0xFF2A2A36);
  static const Color skeletonHighlightDark = Color(0xFF3A3A46);

  // ============================================
  // CATEGORY COLORS
  // ============================================

  // Actions & Objects — green/teal
  static const Color categoryActions = Color(0xFF26A69A);
  static const Color categoryActionsDark = Color(0xFF4DB6AC);

  // Instructional Words — blue/purple
  static const Color categoryInstructional = Color(0xFF5C6BC0);
  static const Color categoryInstructionalDark = Color(0xFF7986CB);

  // Expression — orange/warm
  static const Color categoryExpression = Color(0xFFFF7043);
  static const Color categoryExpressionDark = Color(0xFFFF8A65);

  // Non-Dental — pink/neutral
  static const Color categoryNonDental = Color(0xFFEC407A);
  static const Color categoryNonDentalDark = Color(0xFFF06292);

  /// Get category color by category ID.
  static Color getCategoryColor(String categoryId, {bool isDark = false}) {
    switch (categoryId) {
      case 'actions-and-objects':
        return isDark ? categoryActionsDark : categoryActions;
      case 'instructional-words':
        return isDark ? categoryInstructionalDark : categoryInstructional;
      case 'expression':
        return isDark ? categoryExpressionDark : categoryExpression;
      case 'non-dental':
        return isDark ? categoryNonDentalDark : categoryNonDental;
      default:
        return isDark ? primaryDarkMode : primary;
    }
  }

  /// Get category icon by category ID.
  static IconData getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'actions-and-objects':
        return Icons.brush;
      case 'instructional-words':
        return Icons.front_hand;
      case 'expression':
        return Icons.sentiment_dissatisfied;
      case 'non-dental':
        return Icons.chat_bubble_outline;
      default:
        return Icons.category;
    }
  }

  // Private constructor to prevent instantiation
  AppColors._();
}

/// Extension to get theme-aware colors
extension AppColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get appBackground =>
      isDarkMode ? AppColors.backgroundDark : AppColors.background;
  Color get appSurface =>
      isDarkMode ? AppColors.surfaceDark : AppColors.surface;
  Color get appPrimary =>
      isDarkMode ? AppColors.primaryDarkMode : AppColors.primary;
  Color get appTextPrimary =>
      isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary;
  Color get appTextTitle =>
      isDarkMode ? AppColors.textTitleDark : AppColors.textTitle;
  Color get appTextSecondary =>
      isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary;
  Color get appSidebarBackground => isDarkMode
      ? AppColors.sidebarBackgroundDark
      : AppColors.sidebarBackground;
  Color get appSidebarItemBackground => isDarkMode
      ? AppColors.sidebarItemBackgroundDark
      : AppColors.sidebarItemBackground;
  Color get appSidebarItemActive => isDarkMode
      ? AppColors.sidebarItemActiveDark
      : AppColors.sidebarItemActive;
  Color get appSidebarItemText =>
      isDarkMode ? AppColors.sidebarItemTextDark : AppColors.sidebarItemText;
  Color get appCardBorder =>
      isDarkMode ? AppColors.cardBorderDark : AppColors.cardBorder;
  Color get appCardBackground =>
      isDarkMode ? AppColors.cardBackgroundDark : AppColors.cardBackground;
  Color get appNeutral =>
      isDarkMode ? AppColors.neutralDark : AppColors.neutral;
  Color get appDivider =>
      isDarkMode ? AppColors.dividerDark : AppColors.divider;
  Color get appTextSubtle =>
      isDarkMode ? AppColors.textSubtleDark : AppColors.textSubtle;
  Color get appSkeletonBase =>
      isDarkMode ? AppColors.skeletonBaseDark : AppColors.skeletonBase;
  Color get appSkeletonHighlight => isDarkMode
      ? AppColors.skeletonHighlightDark
      : AppColors.skeletonHighlight;
  Color get appSpeakingIndicator => isDarkMode
      ? AppColors.speakingIndicatorDark
      : AppColors.speakingIndicator;
  Color get appError => AppColors.error;
  Color get appSuccess => AppColors.success;
}
