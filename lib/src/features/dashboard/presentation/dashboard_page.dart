import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_constants.dart';
import '../../../localization/app_localizations.dart';
import '../../../routing/routes.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_shell.dart';
import '../../build_own/presentation/build_own_providers.dart';
import 'dashboard_tile.dart';

/// Main dashboard hub page displaying feature tiles and custom templates.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  int _getColumnCount(double width) {
    if (width >= AppConstants.tabletBreakpoint) return 4;
    if (width >= AppConstants.mobileBreakpoint) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final columnCount = _getColumnCount(screenWidth);
    final customTemplates = ref.watch(customTemplatesNotifierProvider);

    return AppShell(
      showLanguageSelector: true,
      child: Container(
        key: const Key('dashboard_content'),
        color: context.appBackground,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // VERBIDENT title (smaller than before)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'VERBIDENT',
                    style: TextStyle(
                      fontFamily: 'InstrumentSans',
                      fontSize: _calculateFontSize(screenWidth),
                      fontWeight: FontWeight.bold,
                      color: context.appTextTitle,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Welcome text
              Text(
                l10n?.dashboardWelcome ?? 'What would you like to do?',
                style: TextStyle(
                  fontFamily: 'InstrumentSans',
                  fontSize: 18,
                  color: context.appTextSecondary,
                ),
              ),
              const SizedBox(height: 24),
              // Feature tiles grid
              GridView.count(
                crossAxisCount: columnCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  DashboardTile(
                    key: const Key('tile_before_visit'),
                    icon: Icons.auto_stories,
                    label: l10n?.dashboardBeforeVisit ?? 'Before the Visit',
                    color: AppColors.categoryActions,
                    onTap: () => context.go(Routes.beforeVisit),
                  ),
                  DashboardTile(
                    key: const Key('tile_during_visit'),
                    icon: Icons.medical_services,
                    label: l10n?.dashboardDuringVisit ?? 'During the Visit',
                    color: AppColors.categoryInstructional,
                    onTap: () => context.go(Routes.duringVisit),
                  ),
                  DashboardTile(
                    key: const Key('tile_library'),
                    icon: Icons.collections_bookmark,
                    label: l10n?.dashboardLibrary ?? 'Library',
                    color: AppColors.categoryExpression,
                    onTap: () => context.go(Routes.library),
                  ),
                  DashboardTile(
                    key: const Key('tile_build_own'),
                    icon: Icons.brush,
                    label: l10n?.dashboardBuildOwn ?? 'Build Your Own',
                    color: AppColors.categoryNonDental,
                    onTap: () => context.go(Routes.buildOwn),
                  ),
                ],
              ),
              // My Templates section (only when templates exist)
              if (customTemplates.isNotEmpty) ...[
                const SizedBox(height: 32),
                Row(
                  children: [
                    Text(
                      l10n?.dashboardMyTemplates ?? 'My Templates',
                      style: TextStyle(
                        fontFamily: 'InstrumentSans',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.appTextPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Divider(color: context.appDivider)),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: columnCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    // Template cards
                    ...customTemplates.map((template) => DashboardTile(
                          key: Key('template_${template.id}'),
                          icon: Icons.star,
                          label: template.name,
                          color: context.appPrimary,
                          onTap: () =>
                              context.go(Routes.customTemplatePath(template.id)),
                        )),
                    // Create New card
                    DashboardTile(
                      key: const Key('tile_create_new'),
                      icon: Icons.add,
                      label: l10n?.dashboardCreateNew ?? 'Create New',
                      color: context.appNeutral,
                      onTap: () => context.go(Routes.buildOwn),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Calculate font size at ~60% of the original sizing.
  double _calculateFontSize(double screenWidth) {
    const charCount = 9;
    const charWidthRatio = 0.7;
    final targetWidth = screenWidth * 0.42; // 60% of 0.7
    final calculatedSize = targetWidth / (charCount * charWidthRatio);
    return calculatedSize.clamp(
      AppConstants.titleFontSizeMobile * 0.6,
      AppConstants.titleFontSizeDesktop * 0.6,
    );
  }
}
