import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:verbident/src/constants/app_constants.dart';
import 'package:verbident/src/features/library/domain/library_item.dart';
import 'package:verbident/src/features/library/presentation/widgets/library_card.dart';
import 'package:verbident/src/theme/app_colors.dart';

void main() {
  // Load fonts for golden tests
  setUpAll(() async {
    await loadAppFonts();
  });

  const testItem = LibraryItem(
    id: 'test-1',
    imagePath: 'assets/images/library/dentist_chair.webp',
    caption: "This is the dentist's chair",
  );

  const shortCaptionItem = LibraryItem(
    id: 'test-2',
    imagePath: 'assets/images/library/dental_mirror.webp',
    caption: 'Mirror',
  );

  const longCaptionItem = LibraryItem(
    id: 'test-3',
    imagePath: 'assets/images/library/bright_light.webp',
    caption: 'The bright light helps the dentist see inside your mouth clearly',
  );

  group('LibraryCard Widget Tests', () {
    testWidgets('renders with blue container border', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 280,
                child: LibraryCard(item: testItem),
              ),
            ),
          ),
        ),
      );

      // Find the container with blue border color
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(LibraryCard),
              matching: find.byType(Container),
            )
            .first,
      );

      // Verify the container decoration has the correct border color
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.border?.top.color, equals(AppColors.cardBorder));
    });

    testWidgets('renders image with rounded corners', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 280,
                child: LibraryCard(item: testItem),
              ),
            ),
          ),
        ),
      );

      // Find ClipRRect for rounded corners
      final clipRRect = tester.widget<ClipRRect>(
        find
            .descendant(
              of: find.byType(LibraryCard),
              matching: find.byType(ClipRRect),
            )
            .first,
      );

      // Verify border radius is present (inner radius accounts for border width)
      expect(clipRRect.borderRadius, isNotNull);
      final borderRadius = clipRRect.borderRadius as BorderRadius;
      expect(borderRadius.topLeft.x, greaterThan(0));
    });

    testWidgets('renders caption text with correct styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 280,
                child: LibraryCard(item: testItem),
              ),
            ),
          ),
        ),
      );

      // Find the caption text
      final textFinder = find.text(testItem.caption);
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);

      // Verify text styling: Instrument Sans Bold, 14px, black, centered
      expect(textWidget.style?.fontFamily, equals('InstrumentSans'));
      expect(textWidget.style?.fontWeight, equals(FontWeight.bold));
      expect(textWidget.style?.fontSize, equals(14.0));
      expect(textWidget.style?.color, equals(AppColors.textSecondary));
      expect(textWidget.textAlign, equals(TextAlign.center));
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 280,
                child: LibraryCard(
                  item: testItem,
                  onTap: () {
                    wasTapped = true;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // Tap the card
      await tester.tap(find.byType(LibraryCard));
      await tester.pump();

      // Verify callback was triggered
      expect(wasTapped, isTrue);
    });

    testWidgets('has correct semantic label for accessibility', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 280,
                child: LibraryCard(item: testItem),
              ),
            ),
          ),
        ),
      );

      // Verify semantic label includes caption
      final semantics = tester.getSemantics(find.byType(LibraryCard));
      expect(semantics.label, contains(testItem.caption));
    });

    testWidgets('caption is positioned below the image', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 280,
                child: LibraryCard(item: testItem),
              ),
            ),
          ),
        ),
      );

      // Find Column widget that contains image and caption
      expect(
        find.descendant(
          of: find.byType(LibraryCard),
          matching: find.byType(Column),
        ),
        findsOneWidget,
      );
    });

    testWidgets('uses correct border radius from constants', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 280,
                child: LibraryCard(item: testItem),
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(LibraryCard),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(
        decoration.borderRadius,
        equals(BorderRadius.circular(AppConstants.cardBorderRadius)),
      );
    });

    testWidgets('uses correct border width from constants', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 280,
                child: LibraryCard(item: testItem),
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(LibraryCard),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(
        decoration.border?.top.width,
        equals(AppConstants.cardBorderWidth),
      );
    });

    testWidgets('image container is square (1:1 aspect ratio)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 280,
                child: LibraryCard(item: testItem),
              ),
            ),
          ),
        ),
      );

      final aspectRatio = tester.widget<AspectRatio>(
        find
            .descendant(
              of: find.byType(LibraryCard),
              matching: find.byType(AspectRatio),
            )
            .first,
      );

      expect(aspectRatio.aspectRatio, equals(1.0));
    });

    testWidgets('shows placeholder icon when image fails to load', (
      tester,
    ) async {
      const brokenItem = LibraryItem(
        id: 'broken',
        imagePath: 'assets/images/library/nonexistent.png',
        caption: 'Broken image',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 280,
                child: LibraryCard(item: brokenItem),
              ),
            ),
          ),
        ),
      );

      // Trigger image error
      await tester.pump();

      // Placeholder icon should be shown
      expect(find.byIcon(Icons.medical_services_outlined), findsOneWidget);
    });

    testWidgets('caption truncates with ellipsis for very long text', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 120, // Small width to force truncation
                height: 200,
                child: LibraryCard(item: longCaptionItem),
              ),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text(longCaptionItem.caption));
      expect(text.maxLines, equals(3));
      expect(text.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('renders without error for short caption', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 280,
                child: LibraryCard(item: shortCaptionItem),
              ),
            ),
          ),
        ),
      );

      expect(find.text(shortCaptionItem.caption), findsOneWidget);
    });

    testWidgets('uses custom borderColor when provided', (tester) async {
      const customColor = Colors.orange;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 280,
                child: LibraryCard(
                  item: testItem,
                  borderColor: customColor,
                ),
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(LibraryCard),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border?.top.color, equals(customColor));
    });

    testWidgets('speaking color overrides borderColor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 280,
                child: LibraryCard(
                  item: testItem,
                  borderColor: Colors.orange,
                  isSpeaking: true,
                ),
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(LibraryCard),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration;
      // Speaking indicator color should take precedence over borderColor
      expect(
        decoration.border?.top.color,
        equals(AppColors.speakingIndicator),
      );
    });

    testWidgets('does not trigger callback when onTap is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 280,
                child: LibraryCard(item: testItem, onTap: null),
              ),
            ),
          ),
        ),
      );

      // Should not throw when tapped with null callback
      await tester.tap(find.byType(LibraryCard));
      await tester.pump();
    });
  });

  group('LibraryCard Golden Tests', () {
    testGoldens('renders standard card correctly', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(
          devices: [const Device(name: 'card', size: Size(200, 280))],
        )
        ..addScenario(
          widget: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 200,
                  height: 280,
                  child: LibraryCard(item: testItem),
                ),
              ),
            ),
          ),
          name: 'library_card_standard',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'library_card_standard');
    });

    testGoldens('renders card with short caption', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(
          devices: [const Device(name: 'card', size: Size(200, 280))],
        )
        ..addScenario(
          widget: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 200,
                  height: 280,
                  child: LibraryCard(item: shortCaptionItem),
                ),
              ),
            ),
          ),
          name: 'library_card_short_caption',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'library_card_short_caption');
    });

    testGoldens('renders card with long caption', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(
          devices: [const Device(name: 'card', size: Size(200, 280))],
        )
        ..addScenario(
          widget: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 200,
                  height: 280,
                  child: LibraryCard(item: longCaptionItem),
                ),
              ),
            ),
          ),
          name: 'library_card_long_caption',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'library_card_long_caption');
    });

    testGoldens('renders small card correctly', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(
          devices: [const Device(name: 'small_card', size: Size(120, 180))],
        )
        ..addScenario(
          widget: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 120,
                  height: 180,
                  child: LibraryCard(item: testItem),
                ),
              ),
            ),
          ),
          name: 'library_card_small',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'library_card_small');
    });
  });
}
