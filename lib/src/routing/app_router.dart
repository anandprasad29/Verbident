import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Eagerly loaded pages (critical path)
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/library/presentation/library_page.dart';

// Deferred loading for non-critical pages (reduces initial bundle size)
import '../features/before_visit/presentation/before_visit_page.dart'
    deferred as before_visit;
import '../features/during_visit/presentation/during_visit_page.dart'
    deferred as during_visit;
import '../features/build_own/presentation/build_own_page.dart'
    deferred as build_own;
import '../features/build_own/presentation/custom_template_page.dart'
    deferred as custom_template;
import '../features/settings/presentation/settings_page.dart'
    deferred as settings;

import 'routes.dart';

part 'app_router.g.dart';

/// Page transition duration
const _transitionDuration = Duration(milliseconds: 300);

/// Creates a custom page with fade transition
CustomTransitionPage<void> _buildPageWithTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: _transitionDuration,
    reverseTransitionDuration: _transitionDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Fade transition with subtle slide from right
      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      final slideAnimation = Tween<Offset>(
        begin: const Offset(0.03, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(position: slideAnimation, child: child),
      );
    },
  );
}

/// Builds a page with deferred loading support
/// Shows a loading indicator while the deferred library loads
CustomTransitionPage<void> _buildDeferredPage({
  required BuildContext context,
  required GoRouterState state,
  required Future<void> loadLibrary,
  required Widget Function() buildPage,
}) {
  return _buildPageWithTransition(
    context: context,
    state: state,
    child: FutureBuilder(
      future: loadLibrary,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return buildPage();
        }
        // Show loading indicator while deferred library loads
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    ),
  );
}

/// GoRouter provider with keepAlive to prevent disposal during navigation.
/// AutoDispose would cause router recreation and navigation issues.
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: Routes.home,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: Routes.home,
        name: 'home',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const DashboardPage(),
        ),
      ),
      GoRoute(
        path: Routes.library,
        name: 'library',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const LibraryPage(),
        ),
      ),
      // Deferred loaded routes (reduces initial bundle size)
      GoRoute(
        path: Routes.beforeVisit,
        name: 'beforeVisit',
        pageBuilder: (context, state) => _buildDeferredPage(
          context: context,
          state: state,
          loadLibrary: before_visit.loadLibrary(),
          buildPage: () => before_visit.BeforeVisitPage(),
        ),
      ),
      GoRoute(
        path: Routes.duringVisit,
        name: 'duringVisit',
        pageBuilder: (context, state) => _buildDeferredPage(
          context: context,
          state: state,
          loadLibrary: during_visit.loadLibrary(),
          buildPage: () => during_visit.DuringVisitPage(),
        ),
      ),
      GoRoute(
        path: Routes.buildOwn,
        name: 'buildOwn',
        pageBuilder: (context, state) => _buildDeferredPage(
          context: context,
          state: state,
          loadLibrary: build_own.loadLibrary(),
          buildPage: () => build_own.BuildOwnPage(),
        ),
      ),
      // Dynamic route for custom templates
      GoRoute(
        path: '/template/:id',
        name: 'customTemplate',
        pageBuilder: (context, state) {
          final templateId = state.pathParameters['id']!;
          return _buildDeferredPage(
            context: context,
            state: state,
            loadLibrary: custom_template.loadLibrary(),
            buildPage: () =>
                custom_template.CustomTemplatePage(templateId: templateId),
          );
        },
      ),
      GoRoute(
        path: Routes.settings,
        name: 'settings',
        pageBuilder: (context, state) => _buildDeferredPage(
          context: context,
          state: state,
          loadLibrary: settings.loadLibrary(),
          buildPage: () => settings.SettingsPage(),
        ),
      ),
    ],
  );
}
