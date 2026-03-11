import 'package:flutter/material.dart';

/// Application-wide constants for dimensions, breakpoints, and other values.
class AppConstants {
  // Layout breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double sidebarBreakpoint = 800;

  // Sidebar dimensions
  static const double sidebarWidth = 250;
  static const double sidebarItemHeight = 60;
  static const double sidebarTopSpacing = 100;
  static const double sidebarItemSpacing = 20;

  // Header dimensions
  static const double headerExpandedHeight = 120;
  static const double headerCollapsedHeight = 56;

  // Border radius
  static const double cardBorderRadius = 25.0;
  static const double cardBorderWidth = 3.0;

  // Grid settings
  static const int gridColumnsDesktop = 5;
  static const int gridColumnsTablet = 3;
  static const int gridColumnsMobile = 2;
  static const double gridSpacingDesktop = 24.0;
  static const double gridSpacingTablet = 20.0;
  static const double gridSpacingMobile = 16.0;

  // Padding
  static const EdgeInsets contentPaddingDesktop = 
      EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0);
  static const EdgeInsets contentPaddingTablet = 
      EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0);
  static const EdgeInsets contentPaddingMobile = 
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);

  // Font sizes
  static const double titleFontSizeDesktop = 80.0;
  static const double titleFontSizeMobile = 40.0;
  static const double headerFontSize = 24.0;
  static const double headerExpandedScaleLarge = 2.5; // For wide screens (>= 1000px content)
  static const double headerExpandedScaleSmall = 1.5; // For narrow screens (< 1000px content)
  static const double sidebarItemFontSize = 16.0;
  static const double captionFontSize = 14.0;

  // Category section spacing
  static const double categorySectionSpacing = 24.0;
  static const double categoryHeaderHeight = 56.0;
  static const double categoryHeaderBottomGap = 12.0;

  // Private constructor to prevent instantiation
  AppConstants._();
}


