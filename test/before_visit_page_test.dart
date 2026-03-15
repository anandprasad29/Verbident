import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verbident/src/common/widgets/story_sequence.dart';
import 'package:verbident/src/features/before_visit/presentation/before_visit_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the TTS platform channel
  const MethodChannel ttsChannel = MethodChannel('flutter_tts');

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'speak':
        case 'stop':
        case 'setLanguage':
        case 'setSpeechRate':
        case 'setVolume':
        case 'setPitch':
        case 'awaitSpeakCompletion':
          return 1;
        case 'getLanguages':
          return ['en-US', 'es-ES'];
        case 'getVoices':
          return [];
        case 'isLanguageAvailable':
          return 1;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, null);
  });

  /// Creates a test router with BeforeVisitPage as the initial route
  GoRouter createTestRouter() {
    return GoRouter(
      initialLocation: '/before-visit',
      routes: [
        GoRoute(
          path: '/before-visit',
          name: 'beforeVisit',
          builder: (context, state) => const BeforeVisitPage(),
        ),
      ],
    );
  }

  group('BeforeVisitPage Widget Tests', () {
    testWidgets('renders AppBar from AppShell (no SliverAppBar)', (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      // SliverAppBar is no longer used — showHeader is always false
      expect(find.byType(SliverAppBar), findsNothing);
      expect(find.byType(FlexibleSpaceBar), findsNothing);

      // AppShell provides a regular AppBar instead
      expect(find.byType(AppBar), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders StorySequence widget', (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      expect(find.byType(StorySequence), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('does not render tools grid', (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      // Tools grid has been removed
      expect(find.byType(SliverGrid), findsNothing);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows home icon in AppShell AppBar', (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      // SliverAppBar is no longer used — AppShell provides a simple AppBar
      expect(find.byType(SliverAppBar), findsNothing);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays dental content captions', (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      expect(find.textContaining('dentist'), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows home icon on mobile (no hamburger menu)', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      // Sidebar was removed — no hamburger menu; AppShell shows home icon instead
      expect(find.byIcon(Icons.menu), findsNothing);
      expect(find.byIcon(Icons.home), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('uses CustomScrollView for scrolling', (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      expect(find.byType(CustomScrollView), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
