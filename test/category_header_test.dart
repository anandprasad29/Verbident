import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:verbident/src/features/library/presentation/widgets/category_header.dart';
import 'package:verbident/src/theme/app_colors.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  group('CategoryHeader Widget Tests', () {
    testWidgets('renders category name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryHeader(
              categoryId: 'actions-and-objects',
              categoryName: 'Actions & Objects',
            ),
          ),
        ),
      );

      expect(find.text('Actions & Objects'), findsOneWidget);
    });

    testWidgets('renders correct icon for each category', (tester) async {
      final categories = {
        'actions-and-objects': Icons.brush,
        'instructional-words': Icons.front_hand,
        'expression': Icons.sentiment_dissatisfied,
        'non-dental': Icons.chat_bubble_outline,
      };

      for (final entry in categories.entries) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryHeader(
                categoryId: entry.key,
                categoryName: 'Test',
              ),
            ),
          ),
        );

        expect(
          find.byIcon(entry.value),
          findsOneWidget,
          reason: '${entry.key} should show ${entry.value}',
        );
      }
    });

    testWidgets('renders fallback icon for unknown category', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryHeader(
              categoryId: 'unknown-category',
              categoryName: 'Unknown',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.category), findsOneWidget);
    });

    testWidgets('no box shadow when isSticky is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryHeader(
              categoryId: 'actions-and-objects',
              categoryName: 'Test',
              isSticky: false,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CategoryHeader),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNull);
    });

    testWidgets('has box shadow when isSticky is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryHeader(
              categoryId: 'actions-and-objects',
              categoryName: 'Test',
              isSticky: true,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CategoryHeader),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, equals(1));
    });

    testWidgets('uses correct category color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryHeader(
              categoryId: 'actions-and-objects',
              categoryName: 'Test',
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(
        icon.color,
        equals(AppColors.getCategoryColor('actions-and-objects')),
      );
    });

    testWidgets('long name truncates with ellipsis', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 150,
              child: CategoryHeader(
                categoryId: 'actions-and-objects',
                categoryName:
                    'A very long category name that should truncate',
              ),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.overflow, equals(TextOverflow.ellipsis));
    });
  });
}
