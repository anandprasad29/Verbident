import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verbident/src/common/data/dental_items.dart';
import 'package:verbident/src/common/domain/dental_item.dart';
import 'package:verbident/src/features/library/presentation/library_page.dart';
import 'package:verbident/src/features/library/presentation/library_search_provider.dart';
import 'package:verbident/src/features/library/presentation/widgets/category_header.dart';
import 'package:verbident/src/features/library/presentation/widgets/library_card.dart';
import 'package:verbident/src/localization/content_language_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the TTS platform channel
  const MethodChannel ttsChannel = MethodChannel('flutter_tts');

  setUpAll(() async {
    await loadAppFonts();
    // Initialize SharedPreferences mock for tests
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

  /// Creates a test router with LibraryPage as the initial route
  GoRouter createTestRouter() {
    return GoRouter(
      initialLocation: '/library',
      routes: [
        GoRoute(
          path: '/library',
          name: 'library',
          builder: (context, state) => const LibraryPage(),
        ),
      ],
    );
  }

  group('LibraryPage Widget Tests', () {
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

      // Reset view
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders 5 columns on desktop (>=1200px)', (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      // Find the SliverGrids (one per category)
      final gridFinder = find.byType(SliverGrid);
      expect(gridFinder, findsWidgets);

      // Verify first grid has 5 columns by checking the delegate
      final grid = tester.widget<SliverGrid>(gridFinder.first);
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(5));

      // Reset view
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders 3 columns on tablet (600-1199px)', (tester) async {
      tester.view.physicalSize = const Size(900, 700);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      // Find the SliverGrids (one per category)
      final gridFinder = find.byType(SliverGrid);
      expect(gridFinder, findsWidgets);

      // Verify first grid has 3 columns
      final grid = tester.widget<SliverGrid>(gridFinder.first);
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(3));

      // Reset view
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders 2 columns on mobile (<600px)', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      // Find the SliverGrids (one per category)
      final gridFinder = find.byType(SliverGrid);
      expect(gridFinder, findsWidgets);

      // Verify first grid has 2 columns
      final grid = tester.widget<SliverGrid>(gridFinder.first);
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(2));

      // Reset view
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays LibraryCard items in grid', (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      // Verify LibraryCard widgets are rendered
      expect(find.byType(LibraryCard), findsWidgets);

      // Reset view
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows home and settings icons in AppShell AppBar', (tester) async {
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
      expect(find.byIcon(Icons.settings), findsOneWidget);

      // Reset view
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('AppBar remains visible after scroll (no collapsible header)', (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      // No SliverAppBar — the collapsible header has been replaced by AppShell's AppBar
      expect(find.byType(SliverAppBar), findsNothing);

      // Scroll down
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      // AppShell AppBar remains visible after scroll
      expect(find.byType(AppBar), findsOneWidget);

      // Reset view
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

      // Verify CustomScrollView is present
      expect(find.byType(CustomScrollView), findsOneWidget);

      // Reset view
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays sample dental content', (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      // Verify at least some dental-related captions are present
      expect(
        find.textContaining('Toothbrush'),
        findsWidgets,
      );

      // Reset view
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows AppBar with home and settings icons on desktop', (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      // AppBar should be visible with navigation icons
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders CategoryHeader widgets for each category',
        (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      // CategoryHeader widgets should be rendered (one per visible category)
      expect(find.byType(CategoryHeader), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders SliverMainAxisGroup for category sections',
        (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      // SliverMainAxisGroup should be rendered (one per category)
      expect(find.byType(SliverMainAxisGroup), findsWidgets);

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

    testWidgets('grid has correct spacing on desktop', (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      final grid = tester.widget<SliverGrid>(find.byType(SliverGrid).first);
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      expect(delegate.mainAxisSpacing, equals(24.0)); // Desktop spacing
      expect(delegate.crossAxisSpacing, equals(24.0));

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('grid has correct spacing on mobile', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      final grid = tester.widget<SliverGrid>(find.byType(SliverGrid).first);
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      expect(delegate.mainAxisSpacing, equals(16.0)); // Mobile spacing
      expect(delegate.crossAxisSpacing, equals(16.0));

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders all 24 sample items', (tester) async {
      tester.view.physicalSize =
          const Size(1450, 4000); // Tall to show all items
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      // Scroll to load all items
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -2000));
      await tester.pumpAndSettle();

      // Should have 24 LibraryCard widgets
      expect(find.byType(LibraryCard), findsNWidgets(24));

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  group('LibraryPage Golden Tests', () {
    testGoldens('desktop layout renders correctly', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [
          const Device(name: 'desktop', size: Size(1450, 900)),
        ])
        ..addScenario(
          widget: ProviderScope(
            child: MaterialApp.router(
              routerConfig: createTestRouter(),
            ),
          ),
          name: 'library_page_desktop',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'library_page_desktop');
    });

    testGoldens('tablet layout renders correctly', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [
          const Device(name: 'tablet', size: Size(900, 700)),
        ])
        ..addScenario(
          widget: ProviderScope(
            child: MaterialApp.router(
              routerConfig: createTestRouter(),
            ),
          ),
          name: 'library_page_tablet',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'library_page_tablet');
    });

    testGoldens('mobile layout renders correctly', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [
          const Device(name: 'mobile', size: Size(400, 800)),
        ])
        ..addScenario(
          widget: ProviderScope(
            child: MaterialApp.router(
              routerConfig: createTestRouter(),
            ),
          ),
          name: 'library_page_mobile',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'library_page_mobile');
    });

    testGoldens('scrolled content layout', (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      // Scroll down (no collapsible header — AppShell AppBar stays fixed)
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, 'library_page_scrolled');

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  group('LibraryPage Search Widget Tests', () {
    testWidgets('renders search bar', (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      // Find the search TextField
      expect(find.byType(TextField), findsOneWidget);

      // Find the search icon
      expect(find.byIcon(Icons.search), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('search bar has placeholder text', (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      // Find the placeholder text
      expect(find.text('Search by caption...'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('typing in search bar shows clear button', (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      // Initially no clear button
      expect(find.byIcon(Icons.clear), findsNothing);

      // Enter search text
      await tester.enterText(find.byType(TextField), 'mirror');
      await tester.pump();

      // Clear button should appear
      expect(find.byIcon(Icons.clear), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('clear button clears search', (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );

      // Enter search text
      await tester.enterText(find.byType(TextField), 'mirror');
      await tester.pump();

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // TextField should be empty
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);

      // Clear button should be gone
      expect(find.byIcon(Icons.clear), findsNothing);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Note: Search filtering is tested via unit tests for the provider logic.
    // Widget integration tests for filtering with debounce are covered by:
    // - "search works on mobile layout" test
    // - "shows no results message when search has no matches" test
    // - Provider unit tests for case-insensitivity and filtering

    testWidgets('shows no results message when search has no matches',
        (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search text that won't match anything
      await tester.enterText(find.byType(TextField), 'xyznonexistent');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should show no results message
      expect(find.text('No results found'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);

      // No LibraryCards should be visible
      expect(find.byType(LibraryCard), findsNothing);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows result count when searching', (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Result count should not be visible initially
      expect(find.textContaining('items'), findsNothing);

      // Enter search text that matches multiple items
      await tester.enterText(find.byType(TextField), 'mirror');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Result count should be visible
      expect(find.textContaining('items'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Note: Result count pluralization is handled by Flutter's l10n system.
    // The presence of result count is verified in "shows result count when searching" test.
    // Singular/plural behavior is tested implicitly via the golden tests.

    testWidgets('search works on mobile layout', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Search bar should be visible on mobile
      expect(find.byType(TextField), findsOneWidget);

      // Enter search text
      await tester.enterText(find.byType(TextField), 'mirror');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should filter to 1 item
      expect(find.byType(LibraryCard), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  group('LibraryPage Search Golden Tests', () {
    testGoldens('search bar with matching results', (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'mirror');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, 'library_page_search_with_results');

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testGoldens('search bar with no results', (tester) async {
      tester.view.physicalSize = const Size(1450, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search text that won't match
      await tester.enterText(find.byType(TextField), 'xyznonexistent');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, 'library_page_search_no_results');

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testGoldens('search on mobile layout', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: createTestRouter(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'mirror');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, 'library_page_search_mobile');

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  group('Search Provider Unit Tests', () {
    test('librarySearchQueryProvider starts with empty string', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final query = container.read(librarySearchQueryProvider);
      expect(query, isEmpty);
    });

    test('librarySearchInputProvider starts with empty string', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final input = container.read(librarySearchInputProvider);
      expect(input, isEmpty);
    });

    test('filteredLibraryItemsProvider returns all items when query is empty',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final items = container.read(filteredLibraryItemsProvider);
      expect(items.length, equals(DentalItems.all.length));
    });

    test('filteredLibraryItemsProvider filters items by caption', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Set search query
      container.read(librarySearchQueryProvider.notifier).state = 'mirror';

      final items = container.read(filteredLibraryItemsProvider);
      expect(items.length, equals(1));
      expect(items.first.id, equals('dental-mirror'));
    });

    test('filteredLibraryItemsProvider is case-insensitive', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Set uppercase search query
      container.read(librarySearchQueryProvider.notifier).state = 'MIRROR';

      final items = container.read(filteredLibraryItemsProvider);
      expect(items.length, equals(1));
      expect(items.first.id, equals('dental-mirror'));
    });

    test('filteredLibraryItemsProvider returns empty list for no matches', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(librarySearchQueryProvider.notifier).state =
          'xyznonexistent';

      final items = container.read(filteredLibraryItemsProvider);
      expect(items, isEmpty);
    });

    test('filteredLibraryItemsProvider filters by translated caption', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Set language to Spanish
      container.read(contentLanguageNotifierProvider.notifier).setLanguage(
            ContentLanguage.es,
          );

      // Search for Spanish word "espejo" (mirror)
      container.read(librarySearchQueryProvider.notifier).state = 'espejo';

      final items = container.read(filteredLibraryItemsProvider);
      expect(items.length, equals(1));
      expect(items.first.id, equals('dental-mirror'));
    });

    test('groupedLibraryItemsProvider returns all categories when query is empty',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final grouped = container.read(groupedLibraryItemsProvider);
      expect(grouped.keys, hasLength(DentalItems.categories.length));
      for (final categoryId in DentalItems.categories) {
        expect(grouped.containsKey(categoryId), isTrue);
        expect(grouped[categoryId], isNotEmpty);
      }
    });

    test('groupedLibraryItemsProvider preserves category order', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final grouped = container.read(groupedLibraryItemsProvider);
      expect(grouped.keys.toList(), equals(DentalItems.categories));
    });

    test('groupedLibraryItemsProvider excludes empty categories on search', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Search for something that exists in only one category
      container.read(librarySearchQueryProvider.notifier).state = 'mirror';

      final grouped = container.read(groupedLibraryItemsProvider);
      // Should only contain categories with matching items
      expect(grouped.keys.length, lessThan(DentalItems.categories.length));
      for (final items in grouped.values) {
        expect(items, isNotEmpty);
      }
    });

    test('groupedLibraryItemsProvider returns empty map for no matches', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(librarySearchQueryProvider.notifier).state =
          'xyznonexistent';

      final grouped = container.read(groupedLibraryItemsProvider);
      expect(grouped, isEmpty);
    });

    test('groupedLibraryItemsProvider total matches filteredLibraryItemsProvider',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(librarySearchQueryProvider.notifier).state = 'tooth';

      final grouped = container.read(groupedLibraryItemsProvider);
      final filtered = container.read(filteredLibraryItemsProvider);

      final groupedTotal =
          grouped.values.fold<int>(0, (sum, list) => sum + list.length);
      expect(groupedTotal, equals(filtered.length));
    });

    test('LibrarySearchNotifier clearSearch clears both providers', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Set initial values
      container.read(librarySearchInputProvider.notifier).state = 'test';
      container.read(librarySearchQueryProvider.notifier).state = 'test';

      // Clear search
      container.read(librarySearchNotifierProvider.notifier).clearSearch();

      expect(container.read(librarySearchInputProvider), isEmpty);
      expect(container.read(librarySearchQueryProvider), isEmpty);
    });
  });
}
