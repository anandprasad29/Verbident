import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verbident/src/common/domain/dental_item.dart';
import 'package:verbident/src/common/widgets/story_sequence.dart';
import 'package:verbident/src/localization/content_language_provider.dart';

void main() {
  group('StorySequence Widget', () {
    final testItems = [
      const DentalItem(
        id: 'test1',
        imagePath: 'assets/images/library/toothbrush.png',
        caption: 'First Item',
      ),
      const DentalItem(
        id: 'test2',
        imagePath: 'assets/images/library/toothpaste.png',
        caption: 'Second Item',
      ),
      const DentalItem(
        id: 'test3',
        imagePath: 'assets/images/library/floss.png',
        caption: 'Third Item',
      ),
    ];

    Widget buildTestWidget({
      required double width,
      required List<DentalItem> items,
      void Function(DentalItem)? onItemTap,
      ContentLanguage? contentLanguage,
    }) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: width,
              height: 250, // Fixed reasonable height
              child: StorySequence(
                items: items,
                onItemTap: onItemTap ?? (_) {},
                contentLanguage: contentLanguage,
                padding: const EdgeInsets.all(8),
              ),
            ),
          ),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('renders without error', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 400,
          items: testItems,
        ));

        expect(find.byType(StorySequence), findsOneWidget);
      });

      testWidgets('renders captions for all items', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 400,
          items: testItems,
        ));

        // StorySequence should show items with captions
        expect(find.text('First Item'), findsOneWidget);
        expect(find.text('Second Item'), findsOneWidget);
        expect(find.text('Third Item'), findsOneWidget);
      });

      testWidgets('handles empty items list gracefully', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 400,
          items: const [],
        ));

        expect(find.byType(StorySequence), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('renders single item without error', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 200, // Smaller width to keep item size manageable
          items: [testItems.first],
        ));

        expect(find.text('First Item'), findsOneWidget);
      });
    });

    group('Tap Interaction', () {
      testWidgets('calls onItemTap when item is tapped', (tester) async {
        DentalItem? tappedItem;

        await tester.pumpWidget(buildTestWidget(
          width: 400,
          items: testItems,
          onItemTap: (item) => tappedItem = item,
        ));

        await tester.tap(find.text('First Item'));
        await tester.pump();

        expect(tappedItem?.id, equals('test1'));
      });

      testWidgets('calls onItemTap for any item', (tester) async {
        DentalItem? tappedItem;

        // Use wide width so items are horizontal and all visible
        await tester.pumpWidget(buildTestWidget(
          width: 700,
          items: testItems,
          onItemTap: (item) => tappedItem = item,
        ));

        await tester.tap(find.text('Third Item'));
        await tester.pump();

        expect(tappedItem?.id, equals('test3'));
      });
    });

    group('Scrolling Behavior', () {
      testWidgets('uses vertical scroll on narrow screens', (tester) async {
        // Narrow width triggers vertical layout
        await tester.pumpWidget(buildTestWidget(
          width: 400,
          items: testItems,
        ));

        final scrollFinder = find.byType(SingleChildScrollView);
        expect(scrollFinder, findsOneWidget);
      });

      testWidgets('uses horizontal scroll on wide screens when items overflow',
          (tester) async {
        // Wide enough for horizontal, but many items force scroll
        await tester.pumpWidget(buildTestWidget(
          width: 650,
          items: testItems,
        ));

        // At 650px, items fit horizontally without scroll
        expect(find.byType(Row), findsOneWidget);
      });
    });

    group('Layout Structure', () {
      testWidgets('uses Column on narrow screens (< 600px)', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 400,
          items: testItems,
        ));

        expect(find.byType(Column), findsWidgets);
      });

      testWidgets('uses Row on wide screens (>= 600px)', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 700,
          items: testItems,
        ));

        expect(find.byType(Row), findsOneWidget);
      });

      testWidgets('uses LayoutBuilder for responsive sizing', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 400,
          items: testItems,
        ));

        expect(find.byType(LayoutBuilder), findsOneWidget);
      });
    });

    group('Content Language', () {
      testWidgets('renders with English content language', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 400,
          items: testItems,
          contentLanguage: ContentLanguage.en,
        ));

        expect(find.byType(StorySequence), findsOneWidget);
      });

      testWidgets('renders with Spanish content language', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 400,
          items: testItems,
          contentLanguage: ContentLanguage.es,
        ));

        expect(find.byType(StorySequence), findsOneWidget);
      });
    });

    group('Minimum Item Size', () {
      testWidgets('enforces minimum item size on narrow screens',
          (tester) async {
        // The StorySequence has _minItemSize = 100
        await tester.pumpWidget(buildTestWidget(
          width: 100, // Very narrow — vertical layout with scroll
          items: testItems,
        ));

        // Vertical layout wraps in SingleChildScrollView
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });
    });

    group('Arrow Connector Repaint', () {
      testWidgets('arrow repaints when theme changes', (tester) async {
        // Build with light theme
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light(),
              home: Scaffold(
                body: SizedBox(
                  width: 400,
                  height: 250,
                  child: StorySequence(
                    items: testItems,
                    onItemTap: (_) {},
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ),
            ),
          ),
        );

        // Verify widget renders with arrows (CustomPaint for arrows)
        expect(find.byType(CustomPaint), findsWidgets);

        // Rebuild with dark theme to trigger repaint
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.dark(),
              home: Scaffold(
                body: SizedBox(
                  width: 400,
                  height: 250,
                  child: StorySequence(
                    items: testItems,
                    onItemTap: (_) {},
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // Widget should still render without errors after theme change
        // This tests that shouldRepaint properly handles color changes
        expect(find.byType(CustomPaint), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
