import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routing/routes.dart';
import '../theme/app_colors.dart';
import 'language_selector.dart';

/// Shared application shell that provides consistent layout across pages.
/// Provides an AppBar with optional home icon, title, language selector, and settings gear.
class AppShell extends StatelessWidget {
  /// The main content of the page
  final Widget child;

  /// Optional app bar title
  final String? title;

  /// Whether to show the home button in the leading position (defaults to false)
  /// Set to true for all pages except the dashboard.
  final bool showHomeButton;

  /// Whether to show the settings gear icon in actions (defaults to true)
  /// Set to false on the settings page itself.
  final bool showSettingsButton;

  /// Whether to show the language selector (defaults to true)
  final bool showLanguageSelector;

  const AppShell({
    super.key,
    required this.child,
    this.title,
    this.showHomeButton = false,
    this.showSettingsButton = true,
    this.showLanguageSelector = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        backgroundColor: context.appSidebarBackground,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        leading: showHomeButton
            ? IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => context.go(Routes.home),
              )
            : null,
        title: title != null
            ? Text(
                title!,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'InstrumentSans',
                ),
              )
            : null,
        actions: [
          if (showLanguageSelector)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: LanguageSelector(compact: true),
            ),
          if (showSettingsButton)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.go(Routes.settings),
            ),
        ],
      ),
      body: child,
    );
  }
}
