import 'package:flutter_test/flutter_test.dart';
import 'package:verbident/src/common/data/dental_items.dart';
import 'package:verbident/src/features/library/domain/library_item.dart';

void main() {
  group('LibraryItem', () {
    test('creates instance with required parameters', () {
      const item = LibraryItem(
        id: 'test-1',
        imagePath: 'assets/test.png',
        caption: 'Test Caption',
      );

      expect(item.id, equals('test-1'));
      expect(item.imagePath, equals('assets/test.png'));
      expect(item.caption, equals('Test Caption'));
    });

    test('can create const instances', () {
      const item1 = LibraryItem(
        id: '1',
        imagePath: 'path1',
        caption: 'caption1',
      );
      const item2 = LibraryItem(
        id: '1',
        imagePath: 'path1',
        caption: 'caption1',
      );

      // Const instances with same values should be identical
      expect(identical(item1, item2), isTrue);
    });

    test('supports different id formats', () {
      const numericId = LibraryItem(
        id: '123',
        imagePath: 'path',
        caption: 'caption',
      );
      const uuidId = LibraryItem(
        id: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        imagePath: 'path',
        caption: 'caption',
      );

      expect(numericId.id, equals('123'));
      expect(uuidId.id, equals('a1b2c3d4-e5f6-7890-abcd-ef1234567890'));
    });

    test('supports various image path formats', () {
      const assetPath = LibraryItem(
        id: '1',
        imagePath: 'assets/images/library/test.png',
        caption: 'caption',
      );
      const relativePath = LibraryItem(
        id: '2',
        imagePath: '../images/test.jpg',
        caption: 'caption',
      );

      expect(assetPath.imagePath, contains('assets'));
      expect(relativePath.imagePath, contains('..'));
    });

    test('caption can contain special characters', () {
      const item = LibraryItem(
        id: '1',
        imagePath: 'path',
        caption: "This is the dentist's chair & it's comfortable!",
      );

      expect(item.caption, contains("'"));
      expect(item.caption, contains('&'));
    });

    test('caption can be multi-word', () {
      const item = LibraryItem(
        id: '1',
        imagePath: 'path',
        caption: 'The bright light helps the dentist see your teeth',
      );

      expect(item.caption.split(' ').length, greaterThan(5));
    });
  });

  group('LibraryData', () {
    test('sampleItems is not empty', () {
      expect(DentalItems.all, isNotEmpty);
    });

    test('sampleItems contains 24 items', () {
      expect(DentalItems.all.length, equals(24));
    });

    test('all items have unique ids', () {
      final ids = DentalItems.all.map((item) => item.id).toList();
      final uniqueIds = ids.toSet();
      expect(uniqueIds.length, equals(ids.length));
    });

    test('all items have non-empty captions', () {
      for (final item in DentalItems.all) {
        expect(item.caption, isNotEmpty);
      }
    });

    test('all items have valid image paths', () {
      for (final item in DentalItems.all) {
        expect(item.imagePath, startsWith('assets/images/library/'));
        expect(item.imagePath, endsWith('.webp'));
      }
    });

    test('all items have non-empty string captions', () {
      for (final item in DentalItems.all) {
        expect(
          item.caption.isNotEmpty,
          isTrue,
          reason: 'Caption for "${item.id}" should not be empty',
        );
      }
    });

    test('sample items include expected dental items', () {
      final captions = DentalItems.all.map((i) => i.caption).toList();

      // Check for some expected items
      expect(
        captions.any((c) => c.toLowerCase().contains('mirror')),
        isTrue,
        reason: 'Should have mirror item',
      );
      expect(
        captions.any((c) => c.toLowerCase().contains('drill')),
        isTrue,
        reason: 'Should have drill item',
      );
      expect(
        captions.any((c) => c.toLowerCase().contains('suction')),
        isTrue,
        reason: 'Should have suction item',
      );
    });

    test('all image file names are unique', () {
      final paths = DentalItems.all
          .map((item) => item.imagePath)
          .toList();
      final uniquePaths = paths.toSet();
      expect(uniquePaths.length, equals(paths.length));
    });

    test('items have meaningful ids', () {
      // Verify items are grouped by category (first category is actions-and-objects)
      final expectedFirstIds = [
        'toothbrush',
        'floss',
        'water',
        'toothpaste',
        'tooth',
      ];

      for (int i = 0; i < expectedFirstIds.length; i++) {
        expect(DentalItems.all[i].id, equals(expectedFirstIds[i]));
      }

      // Verify all IDs use kebab-case format
      for (final item in DentalItems.all) {
        expect(
          item.id,
          matches(RegExp(r'^[a-z][a-z0-9-]*$')),
          reason: 'ID "${item.id}" should be kebab-case',
        );
      }
    });

    test('duringVisitItems has correct items', () {
      final items = DentalItems.duringVisitItems;
      expect(items.length, equals(5));

      final ids = items.map((i) => i.id).toList();
      expect(ids, [
        'dental-mirror',
        'dental-drill',
        'suction',
        'open-mouth',
        'stop',
      ]);
    });

    test('sampleItems is a fixed list', () {
      // Should be the same instance each time
      final list1 = DentalItems.all;
      final list2 = DentalItems.all;
      expect(identical(list1, list2), isTrue);
    });
  });

  group('DentalItem Category', () {
    test('all items have a non-empty category', () {
      for (final item in DentalItems.all) {
        expect(
          item.category.isNotEmpty,
          isTrue,
          reason: 'Item "${item.id}" should have a category',
        );
      }
    });

    test('category is included in equality', () {
      const item1 = LibraryItem(
        id: 'test',
        imagePath: 'path',
        caption: 'caption',
        category: 'cat-a',
      );
      const item2 = LibraryItem(
        id: 'test',
        imagePath: 'path',
        caption: 'caption',
        category: 'cat-b',
      );

      expect(item1 == item2, isFalse);
    });
  });

  group('DentalItems.categories', () {
    test('contains all four category IDs', () {
      expect(DentalItems.categories, hasLength(4));
      expect(DentalItems.categories, contains('actions-and-objects'));
      expect(DentalItems.categories, contains('instructional-words'));
      expect(DentalItems.categories, contains('expression'));
      expect(DentalItems.categories, contains('non-dental'));
    });

    test('every item belongs to a known category', () {
      for (final item in DentalItems.all) {
        expect(
          DentalItems.categories.contains(item.category),
          isTrue,
          reason: 'Item "${item.id}" has unknown category "${item.category}"',
        );
      }
    });
  });

  group('DentalItems.getByCategory', () {
    test('returns correct items for each category', () {
      for (final categoryId in DentalItems.categories) {
        final items = DentalItems.getByCategory(categoryId);
        expect(items, isNotEmpty, reason: '$categoryId should have items');
        for (final item in items) {
          expect(item.category, equals(categoryId));
        }
      }
    });

    test('all items are accounted for across categories', () {
      int total = 0;
      for (final categoryId in DentalItems.categories) {
        total += DentalItems.getByCategory(categoryId).length;
      }
      expect(total, equals(DentalItems.all.length));
    });

    test('returns empty list for unknown category', () {
      expect(DentalItems.getByCategory('nonexistent'), isEmpty);
    });
  });
}
