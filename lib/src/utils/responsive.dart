import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Cached grid layout values to avoid repeated MediaQuery lookups.
/// Use [Responsive.getGridLayout] to create this efficiently.
class GridLayout {
  final int columnCount;
  final double spacing;
  final EdgeInsets padding;
  final double aspectRatio;
  final bool showHeader;
  final double headerScale;
  final double pixelRatio;

  const GridLayout({
    required this.columnCount,
    required this.spacing,
    required this.padding,
    required this.aspectRatio,
    required this.showHeader,
    required this.headerScale,
    required this.pixelRatio,
  });
}

/// Responsive breakpoints and utilities
class Responsive {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Get the actual content width.
  /// Use this for determining grid columns, not raw screen width.
  static double getContentWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Check if the content area is mobile-sized (< 600px)
  static bool isMobile(BuildContext context) {
    return getContentWidth(context) < mobileBreakpoint;
  }

  /// Check if the content area is tablet-sized (600-1199px)
  static bool isTablet(BuildContext context) {
    final contentWidth = getContentWidth(context);
    return contentWidth >= mobileBreakpoint && contentWidth < desktopBreakpoint;
  }

  /// Check if the content area is desktop-sized (>= 1200px)
  static bool isDesktop(BuildContext context) {
    return getContentWidth(context) >= desktopBreakpoint;
  }

  /// Get responsive width based on screen size
  static double getResponsiveWidth(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context) && mobile != null) {
      return mobile;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else if (isDesktop(context) && desktop != null) {
      return desktop;
    }
    return MediaQuery.of(context).size.width;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    if (isMobile(context) && mobile != null) {
      return mobile;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else if (isDesktop(context) && desktop != null) {
      return desktop;
    }
    return const EdgeInsets.all(16.0);
  }

  /// Get responsive font size based on screen size
  static double getResponsiveFontSize(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context) && mobile != null) {
      return mobile;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else if (isDesktop(context) && desktop != null) {
      return desktop;
    }
    return 16.0;
  }

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  // ============================================
  // Grid Layout Helpers
  // ============================================

  /// Get the number of grid columns based on screen width.
  /// Desktop: 5, Tablet: 3, Mobile: 2
  static int getGridColumnCount(BuildContext context) {
    if (isDesktop(context)) {
      return AppConstants.gridColumnsDesktop;
    } else if (isTablet(context)) {
      return AppConstants.gridColumnsTablet;
    } else {
      return AppConstants.gridColumnsMobile;
    }
  }

  /// Get grid spacing based on screen width.
  /// Desktop: 24, Tablet: 20, Mobile: 16
  static double getGridSpacing(BuildContext context) {
    if (isDesktop(context)) {
      return AppConstants.gridSpacingDesktop;
    } else if (isTablet(context)) {
      return AppConstants.gridSpacingTablet;
    } else {
      return AppConstants.gridSpacingMobile;
    }
  }

  /// Get content padding based on screen width.
  /// Desktop: 48h/24v, Tablet: 32h/20v, Mobile: 16h/16v
  static EdgeInsets getContentPadding(BuildContext context) {
    if (isDesktop(context)) {
      return AppConstants.contentPaddingDesktop;
    } else if (isTablet(context)) {
      return AppConstants.contentPaddingTablet;
    } else {
      return AppConstants.contentPaddingMobile;
    }
  }

  /// Get grid cell aspect ratio based on screen size.
  /// Smaller screens get a lower ratio (taller cells) to fit captions better.
  /// Desktop: 0.75, Tablet: 0.7, Mobile: 0.65
  static double getGridAspectRatio(BuildContext context) {
    if (isDesktop(context)) {
      return 0.75;
    } else if (isTablet(context)) {
      return 0.70;
    } else {
      return 0.65; // Taller cells for more caption space on mobile
    }
  }

  /// Check if we should show an embedded page header (SliverAppBar).
  /// Always false since AppShell now provides an AppBar on all screen sizes.
  static bool shouldShowPageHeader(BuildContext context) {
    return false;
  }

  /// Get the header title expanded scale based on content width.
  /// Larger scale for wide screens, smaller for narrow to prevent overflow.
  static double getHeaderExpandedScale(BuildContext context) {
    final contentWidth = getContentWidth(context);
    return contentWidth >= 1000
        ? AppConstants.headerExpandedScaleLarge
        : AppConstants.headerExpandedScaleSmall;
  }

  // ============================================
  // Performance Optimized Helpers
  // ============================================

  /// Gets all grid layout values in a single call, reducing MediaQuery lookups.
  /// Use this in build methods for optimal performance.
  ///
  /// Example:
  /// ```dart
  /// final layout = Responsive.getGridLayout(context);
  /// // Use layout.columnCount, layout.spacing, etc.
  /// ```
  static GridLayout getGridLayout(BuildContext context) {
    // Single MediaQuery call to get all needed data
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final pixelRatio = mediaQuery.devicePixelRatio;

    // Content width is the full screen width (no sidebar)
    final contentWidth = screenWidth;

    // Determine size category once
    final isDesktop = contentWidth >= desktopBreakpoint;
    final isTablet = contentWidth >= mobileBreakpoint && !isDesktop;

    // Get all values based on size category
    final columnCount = isDesktop
        ? AppConstants.gridColumnsDesktop
        : isTablet
        ? AppConstants.gridColumnsTablet
        : AppConstants.gridColumnsMobile;

    final spacing = isDesktop
        ? AppConstants.gridSpacingDesktop
        : isTablet
        ? AppConstants.gridSpacingTablet
        : AppConstants.gridSpacingMobile;

    final padding = isDesktop
        ? AppConstants.contentPaddingDesktop
        : isTablet
        ? AppConstants.contentPaddingTablet
        : AppConstants.contentPaddingMobile;

    final aspectRatio = isDesktop
        ? 0.75
        : isTablet
        ? 0.70
        : 0.65;

    const showHeader = false;
    final headerScale = contentWidth >= 1000
        ? AppConstants.headerExpandedScaleLarge
        : AppConstants.headerExpandedScaleSmall;

    return GridLayout(
      columnCount: columnCount,
      spacing: spacing,
      padding: padding,
      aspectRatio: aspectRatio,
      showHeader: showHeader,
      headerScale: headerScale,
      pixelRatio: pixelRatio,
    );
  }
}
