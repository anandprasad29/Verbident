import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../features/build_own/presentation/build_own_providers.dart';
import '../localization/app_localizations.dart';
import '../routing/routes.dart';
import '../theme/app_colors.dart';

/// Data class for sidebar navigation items.
/// Uses a localization key instead of hardcoded label.
class SidebarItemData {
  /// Localization key for the label (resolved at runtime)
  final String labelKey;
  final String route;
  final String testKey;

  /// If true, this is a custom template item (uses label directly)
  final bool isCustomTemplate;

  const SidebarItemData({
    required this.labelKey,
    required this.route,
    required this.testKey,
    this.isCustomTemplate = false,
  });

  /// Get the localized label using the provided AppLocalizations
  String getLabel(AppLocalizations? l10n) {
    // Custom templates use labelKey directly as the name
    if (isCustomTemplate) {
      return labelKey;
    }

    switch (labelKey) {
      case 'navBeforeVisit':
        return l10n?.navBeforeVisit ?? 'Before the visit';
      case 'navDuringVisit':
        return l10n?.navDuringVisit ?? 'During the visit';
      case 'navBuildOwn':
        return l10n?.navBuildOwn ?? 'Build your own';
      case 'navLibrary':
        return l10n?.navLibrary ?? 'Library';
      case 'navSettings':
        return l10n?.navSettings ?? 'Settings';
      default:
        return labelKey;
    }
  }
}

/// Configuration for sidebar navigation items.
class SidebarConfig {
  /// Static items that appear at the top (before custom templates)
  static const List<SidebarItemData> topItems = [
    SidebarItemData(
      labelKey: 'navBeforeVisit',
      route: Routes.beforeVisit,
      testKey: 'sidebar_item_before_visit',
    ),
    SidebarItemData(
      labelKey: 'navDuringVisit',
      route: Routes.duringVisit,
      testKey: 'sidebar_item_during_visit',
    ),
  ];

  /// Static items that appear at the bottom (after custom templates)
  static const List<SidebarItemData> bottomItems = [
    SidebarItemData(
      labelKey: 'navBuildOwn',
      route: Routes.buildOwn,
      testKey: 'sidebar_item_build_own',
    ),
    SidebarItemData(
      labelKey: 'navLibrary',
      route: Routes.library,
      testKey: 'sidebar_item_library',
    ),
    SidebarItemData(
      labelKey: 'navSettings',
      route: Routes.settings,
      testKey: 'sidebar_item_settings',
    ),
  ];

  /// Legacy getter for backward compatibility with tests
  static List<SidebarItemData> get items => [...topItems, ...bottomItems];

  // Private constructor
  SidebarConfig._();
}

/// Shared sidebar widget used across pages for navigation.
/// Contains navigation buttons for all main sections of the app.
/// Supports both light and dark themes.
/// Dynamically renders custom templates between static sections.
class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get localization
    final l10n = AppLocalizations.of(context);

    // Watch only what's needed for the sidebar display (selective watching)
    // This avoids rebuilding when unrelated template properties change
    final customTemplates = ref.watch(
      customTemplatesNotifierProvider.select(
        (templates) => templates.map((t) => (id: t.id, name: t.name)).toList(),
      ),
    );
    final isLoading = ref.watch(templatesLoadingProvider);
    final error = ref.watch(templatesErrorProvider);

    // Get current route to highlight active item
    // Safely access route state (may not exist in tests)
    String currentRoute = '';
    try {
      currentRoute = GoRouterState.of(context).uri.path;
    } catch (_) {
      // GoRouter not available (e.g., in tests), leave route empty
    }

    // Build dynamic sidebar items from custom templates
    // (customTemplates is now a list of records with just id and name)
    final customTemplateItems = customTemplates
        .map(
          (template) => SidebarItemData(
            labelKey: template.name,
            route: Routes.customTemplatePath(template.id),
            testKey: 'sidebar_item_template_${template.id}',
            isCustomTemplate: true,
          ),
        )
        .toList();

    return Container(
      color: context.appSidebarBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppConstants.sidebarTopSpacing),
          // Scrollable area for nav items (supports many custom templates)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top static items (Before Visit, During Visit)
                  ...SidebarConfig.topItems.map(
                    (item) =>
                        _buildSidebarItem(context, item, l10n, currentRoute),
                  ),
                  // Loading indicator for custom templates
                  if (isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              context.appSidebarItemText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Error indicator
                  if (error != null && !isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                  // Dynamic custom template items
                  if (!isLoading)
                    ...customTemplateItems.map(
                      (item) =>
                          _buildSidebarItem(context, item, l10n, currentRoute),
                    ),
                  // Bottom static items (Build Your Own, Library)
                  ...SidebarConfig.bottomItems.map(
                    (item) =>
                        _buildSidebarItem(context, item, l10n, currentRoute),
                  ),
                ],
              ),
            ),
          ),
          // Bottom padding
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context,
    SidebarItemData item,
    AppLocalizations? l10n,
    String currentRoute,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.sidebarItemSpacing),
      child: SidebarItem(
        key: Key(item.testKey),
        label: item.getLabel(l10n),
        isActive: currentRoute == item.route,
        isCustomTemplate: item.isCustomTemplate,
        onTap: () {
          // Close drawer if open (mobile)
          if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
            Navigator.of(context).pop();
          }
          context.go(item.route);
        },
      ),
    );
  }
}

/// Individual sidebar navigation item.
/// Supports both light and dark themes.
class SidebarItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isCustomTemplate;

  const SidebarItem({
    super.key,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.isCustomTemplate = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppConstants.sidebarItemHeight,
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isActive
              ? context.appSidebarItemActive
              : context.appSidebarItemBackground,
          border:
              isActive ? Border.all(color: context.appPrimary, width: 2) : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Custom template indicator icon (star)
              if (isCustomTemplate) ...[
                Icon(
                  Icons.star,
                  size: 16,
                  color: isActive
                      ? context.appPrimary
                      : (isDark
                          ? AppColors.sidebarItemTextDark
                          : AppColors.sidebarItemText),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'KumarOne',
                    fontSize: AppConstants.sidebarItemFontSize,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? context.appPrimary
                        : (isDark
                            ? AppColors.sidebarItemTextDark
                            : AppColors.sidebarItemText),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
