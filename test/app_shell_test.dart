import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verbident/src/theme/app_colors.dart';
import 'package:verbident/src/widgets/app_shell.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
    SharedPreferences.setMockInitialValues({});
  });

  GoRouter createTestRouter({String initialLocation = '/'}) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const AppShell(
            child: Center(child: Text('Home Content')),
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const AppShell(
            showHomeButton: true,
            showSettingsButton: false,
            child: Center(child: Text('Settings Content')),
          ),
        ),
        GoRoute(
          path: '/library',
          builder: (context, state) => const AppShell(
            showHomeButton: true,
            child: Center(child: Text('Library Content')),
          ),
        ),
      ],
    );
  }

  group('AppShell Widget Tests', () {
    testWidgets('shows AppBar on all screen sizes', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: createTestRouter()),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Home Content'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows AppBar on mobile', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: createTestRouter()),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Home Content'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('AppBar has correct background color', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: createTestRouter()),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(AppColors.sidebarBackground));

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows settings gear icon by default', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: createTestRouter()),
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('does not show home icon on dashboard', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: createTestRouter()),
        ),
      );

      expect(find.byIcon(Icons.home), findsNothing);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows home icon on feature pages', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(initialLocation: '/library'),
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('hides settings icon on settings page', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(initialLocation: '/settings'),
          ),
        ),
      );

      expect(find.byIcon(Icons.settings), findsNothing);
      expect(find.byIcon(Icons.home), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('gear icon navigates to settings', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: createTestRouter()),
        ),
      );

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Settings Content'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('home icon navigates to dashboard', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(initialLocation: '/library'),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      expect(find.text('Home Content'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('no drawer or sidebar anywhere', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: createTestRouter()),
        ),
      );

      expect(find.byType(Drawer), findsNothing);
      expect(find.byIcon(Icons.menu), findsNothing);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  group('AppShell Golden Tests', () {
    testGoldens('desktop layout renders correctly', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [
          const Device(name: 'desktop', size: Size(1024, 768)),
        ])
        ..addScenario(
          widget: ProviderScope(
            child: MaterialApp.router(routerConfig: createTestRouter()),
          ),
          name: 'app_shell_desktop',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'app_shell_desktop');
    });

    testGoldens('mobile layout renders correctly', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [
          const Device(name: 'mobile', size: Size(400, 800)),
        ])
        ..addScenario(
          widget: ProviderScope(
            child: MaterialApp.router(routerConfig: createTestRouter()),
          ),
          name: 'app_shell_mobile',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'app_shell_mobile');
    });
  });
}
