import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verbident/src/common/domain/dental_item.dart';
import 'package:verbident/src/features/build_own/data/template_storage_service.dart';
import 'package:verbident/src/features/build_own/domain/custom_template.dart';
import 'package:verbident/src/features/build_own/presentation/build_own_providers.dart';
import 'package:verbident/src/features/build_own/presentation/widgets/selectable_library_card.dart';
import 'package:verbident/src/common/data/dental_items.dart';

void main() {
  group('CustomTemplate', () {
    test('creates instance with required fields', () {
      final template = CustomTemplate(
        id: '1',
        name: 'Test Template',
        selectedItemIds: ['item1', 'item2'],
        createdAt: DateTime(2024, 1, 1),
      );

      expect(template.id, '1');
      expect(template.name, 'Test Template');
      expect(template.selectedItemIds, ['item1', 'item2']);
      expect(template.createdAt, DateTime(2024, 1, 1));
    });

    test('copyWith creates new instance with updated fields', () {
      final template = CustomTemplate(
        id: '1',
        name: 'Original',
        selectedItemIds: ['item1'],
        createdAt: DateTime(2024, 1, 1),
      );

      final updated = template.copyWith(name: 'Updated');

      expect(updated.id, '1');
      expect(updated.name, 'Updated');
      expect(updated.selectedItemIds, ['item1']);
    });

    test('toJson and fromJson round-trip', () {
      final original = CustomTemplate(
        id: '1',
        name: 'Test',
        selectedItemIds: ['a', 'b', 'c'],
        createdAt: DateTime(2024, 6, 15, 10, 30),
      );

      final json = original.toJson();
      final restored = CustomTemplate.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.selectedItemIds, original.selectedItemIds);
      expect(restored.createdAt, original.createdAt);
    });

    test('equality works correctly', () {
      final t1 = CustomTemplate(
        id: '1',
        name: 'Test',
        selectedItemIds: ['a', 'b'],
        createdAt: DateTime(2024, 1, 1),
      );

      final t2 = CustomTemplate(
        id: '1',
        name: 'Test',
        selectedItemIds: ['a', 'b'],
        createdAt: DateTime(2024, 1, 1),
      );

      final t3 = CustomTemplate(
        id: '2',
        name: 'Test',
        selectedItemIds: ['a', 'b'],
        createdAt: DateTime(2024, 1, 1),
      );

      expect(t1, t2);
      expect(t1, isNot(t3));
    });
  });

  group('Build Own Providers', () {
    test('maxTemplateCount is 10', () {
      expect(maxTemplateCount, 10);
    });

    test('canCreateTemplateProvider returns false when name is empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(buildOwnTemplateNameProvider.notifier).state = '';
      container.read(buildOwnSelectedIdsProvider.notifier).state = {'item1'};

      expect(container.read(canCreateTemplateProvider), false);
    });

    test('canCreateTemplateProvider returns false when no items selected', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(buildOwnTemplateNameProvider.notifier).state = 'Test';
      container.read(buildOwnSelectedIdsProvider.notifier).state = {};

      expect(container.read(canCreateTemplateProvider), false);
    });

    test('canCreateTemplateProvider returns true when valid', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(buildOwnTemplateNameProvider.notifier).state = 'Test';
      container.read(buildOwnSelectedIdsProvider.notifier).state = {'item1'};

      expect(container.read(canCreateTemplateProvider), true);
    });

    test('buildOwnSelectionCountProvider returns correct count', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(buildOwnSelectedIdsProvider.notifier).state = {
        'a',
        'b',
        'c'
      };

      expect(container.read(buildOwnSelectionCountProvider), 3);
    });

    test('getItemsFromIds returns empty list for unknown ids', () {
      final items = getItemsFromIds(['unknown1', 'unknown2']);
      expect(items, isEmpty);
    });

    test('getItemsFromIds returns items in correct order', () {
      // Using known library item IDs
      final items = getItemsFromIds(['dental-mirror', 'dental-drill']);
      expect(items.length, 2);
      expect(items[0].id, 'dental-mirror');
      expect(items[1].id, 'dental-drill');
    });
  });

  group('SelectableLibraryCard', () {
    final testItem = DentalItem(
      id: 'test-item',
      imagePath: 'assets/images/library/dentist_chair.png',
      caption: 'Test Item',
    );

    Widget buildCard(
        {required bool isSelected,
        VoidCallback? onTap,
        String caption = 'Test'}) {
      return MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 150,
              height: 180,
              child: SelectableLibraryCard(
                item: testItem,
                caption: caption,
                isSelected: isSelected,
                onTap: onTap ?? () {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders caption text', (tester) async {
      await tester
          .pumpWidget(buildCard(isSelected: false, caption: 'Test Caption'));
      expect(find.text('Test Caption'), findsOneWidget);
    });

    testWidgets('shows check icon when selected', (tester) async {
      await tester.pumpWidget(buildCard(isSelected: true));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows add icon when not selected', (tester) async {
      await tester.pumpWidget(buildCard(isSelected: false));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester
          .pumpWidget(buildCard(isSelected: false, onTap: () => tapped = true));
      await tester.tap(find.byType(SelectableLibraryCard));
      await tester.pumpAndSettle();
      expect(tapped, true);
    });

    testWidgets('has correct accessibility label', (tester) async {
      await tester
          .pumpWidget(buildCard(isSelected: true, caption: 'Dental Chair'));
      final semantics = tester.getSemantics(find.byType(SelectableLibraryCard));
      expect(semantics.label, contains('Dental Chair'));
      expect(semantics.label, contains('selected'));
    });
  });

  group('DraggableLibraryCard', () {
    final testItem = DentalItem(
      id: 'test-item',
      imagePath: 'assets/images/library/dentist_chair.png',
      caption: 'Test Item',
    );

    testWidgets('displays order number', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: SizedBox(
              width: 150,
              height: 180,
              child: DraggableLibraryCard(
                item: testItem,
                caption: 'Test',
                onRemove: () {},
                index: 2,
              ),
            ),
          ),
        ),
      );

      // Index is 0-based, display is 1-based
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows drag indicator icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: SizedBox(
              width: 150,
              height: 180,
              child: DraggableLibraryCard(
                item: testItem,
                caption: 'Test',
                onRemove: () {},
                index: 0,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.drag_indicator), findsOneWidget);
    });

    testWidgets('shows remove button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: SizedBox(
              width: 150,
              height: 180,
              child: DraggableLibraryCard(
                item: testItem,
                caption: 'Test',
                onRemove: () {},
                index: 0,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('calls onRemove when remove button tapped', (tester) async {
      bool removed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: SizedBox(
              width: 150,
              height: 180,
              child: DraggableLibraryCard(
                item: testItem,
                caption: 'Test',
                onRemove: () => removed = true,
                index: 0,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(removed, true);
    });
  });

  group('RemovableLibraryCard', () {
    final testItem = DentalItem(
      id: 'test-item',
      imagePath: 'assets/images/library/dentist_chair.png',
      caption: 'Test Item',
    );

    Widget buildCard({required bool showRemoveOverlay}) {
      return MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 150,
              height: 180,
              child: RemovableLibraryCard(
                item: testItem,
                caption: 'Test',
                showRemoveOverlay: showRemoveOverlay,
                onTap: () {},
                onRemove: () {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('shows close icon when showRemoveOverlay is true',
        (tester) async {
      await tester.pumpWidget(buildCard(showRemoveOverlay: true));
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('hides close icon when showRemoveOverlay is false',
        (tester) async {
      await tester.pumpWidget(buildCard(showRemoveOverlay: false));
      expect(find.byIcon(Icons.close), findsNothing);
    });
  });

  group('ReorderableWrap', () {
    testWidgets('renders all children', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableWrap(
              spacing: 8,
              runSpacing: 8,
              onReorder: (oldIndex, newIndex) {},
              children: [
                SizedBox(
                    key: const ValueKey('1'),
                    width: 50,
                    height: 50,
                    child: const Text('A')),
                SizedBox(
                    key: const ValueKey('2'),
                    width: 50,
                    height: 50,
                    child: const Text('B')),
                SizedBox(
                    key: const ValueKey('3'),
                    width: 50,
                    height: 50,
                    child: const Text('C')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });
  });

  group('TemplateStorageService', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('loadTemplates returns empty list when no data', () {
      final service = TemplateStorageService(prefs);
      final templates = service.loadTemplates();
      expect(templates, isEmpty);
    });

    test('saveTemplates and loadTemplates round-trip', () async {
      final service = TemplateStorageService(prefs);
      final templates = [
        CustomTemplate(
          id: '1',
          name: 'Template 1',
          selectedItemIds: ['a', 'b'],
          createdAt: DateTime(2024, 1, 1),
        ),
        CustomTemplate(
          id: '2',
          name: 'Template 2',
          selectedItemIds: ['c'],
          createdAt: DateTime(2024, 1, 2),
        ),
      ];

      await service.saveTemplates(templates);
      final loaded = service.loadTemplates();

      expect(loaded.length, 2);
      expect(loaded[0].id, '1');
      expect(loaded[0].name, 'Template 1');
      expect(loaded[1].id, '2');
      expect(loaded[1].name, 'Template 2');
    });

    test('addTemplate adds to existing list', () async {
      final service = TemplateStorageService(prefs);
      final template1 = CustomTemplate(
        id: '1',
        name: 'Template 1',
        selectedItemIds: ['a'],
        createdAt: DateTime(2024, 1, 1),
      );
      final template2 = CustomTemplate(
        id: '2',
        name: 'Template 2',
        selectedItemIds: ['b'],
        createdAt: DateTime(2024, 1, 2),
      );

      await service.addTemplate(template1);
      await service.addTemplate(template2);
      final loaded = service.loadTemplates();

      expect(loaded.length, 2);
    });

    test('updateTemplate modifies existing template', () async {
      final service = TemplateStorageService(prefs);
      final template = CustomTemplate(
        id: '1',
        name: 'Original',
        selectedItemIds: ['a'],
        createdAt: DateTime(2024, 1, 1),
      );

      await service.addTemplate(template);
      await service.updateTemplate(template.copyWith(name: 'Updated'));
      final loaded = service.loadTemplates();

      expect(loaded.length, 1);
      expect(loaded[0].name, 'Updated');
    });

    test('deleteTemplate removes template', () async {
      final service = TemplateStorageService(prefs);
      final template = CustomTemplate(
        id: '1',
        name: 'Template',
        selectedItemIds: ['a'],
        createdAt: DateTime(2024, 1, 1),
      );

      await service.addTemplate(template);
      await service.deleteTemplate('1');
      final loaded = service.loadTemplates();

      expect(loaded, isEmpty);
    });

    test('loadTemplates handles corrupted JSON gracefully', () async {
      // Set invalid JSON in storage
      await prefs.setString('custom_templates', 'invalid json');
      final service = TemplateStorageService(prefs);

      // The implementation catches exceptions and returns empty list
      // This is graceful error handling
      final templates = service.loadTemplates();
      expect(templates, isEmpty);
    });
  });

  group('Template Limit and Duplicate Validation', () {
    test('templatesLoadingProvider starts as true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(templatesLoadingProvider), true);
    });

    test('templatesErrorProvider starts as null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(templatesErrorProvider), null);
    });

    test('maxTemplateCount constant is 10', () {
      expect(maxTemplateCount, 10);
    });

    test('buildOwnSelectedIdsProvider starts empty which means not at limit',
        () {
      // Test that we start with no selections
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final selectedIds = container.read(buildOwnSelectedIdsProvider);
      expect(selectedIds, isEmpty);
      expect(selectedIds.length < maxTemplateCount, true);
    });
  });

  group('Edit Mode Providers', () {
    test('templateEditModeProvider starts as false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(templateEditModeProvider), false);
    });

    test('editTemplateNameProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(editTemplateNameProvider.notifier).state = 'New Name';
      expect(container.read(editTemplateNameProvider), 'New Name');
    });

    test('editTemplateSelectedIdsProvider can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(editTemplateSelectedIdsProvider.notifier).state = [
        'a',
        'b'
      ];
      expect(container.read(editTemplateSelectedIdsProvider), ['a', 'b']);
    });

    test('edit validation - name empty means invalid', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(editTemplateNameProvider.notifier).state = '';
      container.read(editTemplateSelectedIdsProvider.notifier).state = ['a'];

      // Check that empty name is detected
      expect(container.read(editTemplateNameProvider).trim().isEmpty, true);
    });

    test('edit validation - no items means invalid', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(editTemplateNameProvider.notifier).state = 'Name';
      container.read(editTemplateSelectedIdsProvider.notifier).state = [];

      // Check that empty selection is detected
      expect(container.read(editTemplateSelectedIdsProvider).isEmpty, true);
    });

    test('edit validation - name and items valid', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(editTemplateNameProvider.notifier).state = 'Name';
      container.read(editTemplateSelectedIdsProvider.notifier).state = ['a'];

      // Check that valid state is detected
      final name = container.read(editTemplateNameProvider);
      final items = container.read(editTemplateSelectedIdsProvider);
      expect(name.trim().isNotEmpty && items.isNotEmpty, true);
    });
  });

  group('Search Providers', () {
    test('buildOwnSearchInputProvider starts empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(buildOwnSearchInputProvider), '');
    });

    test('editTemplateSearchInputProvider starts empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(editTemplateSearchInputProvider), '');
    });

    test('filteredBuildOwnItemsProvider returns all items when no search', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final items = container.read(filteredBuildOwnItemsProvider);
      expect(items.length, DentalItems.all.length);
    });

    test('filteredEditTemplateItemsProvider returns all items when no search',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final items = container.read(filteredEditTemplateItemsProvider);
      expect(items.length, DentalItems.all.length);
    });

    test('filteredBuildOwnItemsProvider filters items by search query', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Set search query
      container.read(buildOwnSearchQueryProvider.notifier).state = 'chair';
      final items = container.read(filteredBuildOwnItemsProvider);

      // Should filter to items matching "chair"
      expect(
          items.every((item) =>
              item.caption.toLowerCase().contains('chair') ||
              item.id.toLowerCase().contains('chair')),
          true);
    });
  });

  group('Selection State', () {
    test('buildOwnSelectedIdsProvider starts empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(buildOwnSelectedIdsProvider), isEmpty);
    });

    test('buildOwnTemplateNameProvider starts empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(buildOwnTemplateNameProvider), '');
    });

    test('toggle selection adds and removes items', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(buildOwnSelectedIdsProvider.notifier);

      // Add item
      notifier.state = {...notifier.state, 'item1'};
      expect(container.read(buildOwnSelectedIdsProvider), contains('item1'));

      // Remove item
      notifier.state = notifier.state.where((id) => id != 'item1').toSet();
      expect(container.read(buildOwnSelectedIdsProvider),
          isNot(contains('item1')));
    });
  });

  group('Utility Functions', () {
    test('getItemsFromIds returns items in order', () {
      // Use actual IDs from DentalItems.all
      final ids = ['dental-mirror', 'dental-drill', 'suction'];
      final items = getItemsFromIds(ids);

      expect(items.length, 3);
      expect(items[0].id, 'dental-mirror');
      expect(items[1].id, 'dental-drill');
      expect(items[2].id, 'suction');
    });

    test('getItemsFromIds skips unknown ids', () {
      final ids = ['dental-mirror', 'unknown-item', 'suction'];
      final items = getItemsFromIds(ids);

      expect(items.length, 2);
      expect(items.any((item) => item.id == 'unknown-item'), false);
    });

    test('getItemsFromIds returns empty for empty input', () {
      final items = getItemsFromIds([]);
      expect(items, isEmpty);
    });

    test('getItemsFromIds returns all library items when all IDs are valid',
        () {
      // Get all IDs from LibraryData
      final allIds = DentalItems.all.map((item) => item.id).toList();
      final items = getItemsFromIds(allIds);

      expect(items.length, DentalItems.all.length);
    });
  });

  group('Custom Template JSON serialization', () {
    test('handles empty selectedItemIds', () {
      final template = CustomTemplate(
        id: '1',
        name: 'Empty',
        selectedItemIds: [],
        createdAt: DateTime(2024, 1, 1),
      );

      final json = template.toJson();
      final restored = CustomTemplate.fromJson(json);

      expect(restored.selectedItemIds, isEmpty);
    });

    test('handles special characters in name', () {
      final template = CustomTemplate(
        id: '1',
        name: 'Template with "quotes" & <special>',
        selectedItemIds: ['a'],
        createdAt: DateTime(2024, 1, 1),
      );

      final json = template.toJson();
      final jsonString = jsonEncode(json);
      final restoredJson = jsonDecode(jsonString);
      final restored = CustomTemplate.fromJson(restoredJson);

      expect(restored.name, 'Template with "quotes" & <special>');
    });

    test('preserves order of selectedItemIds', () {
      final template = CustomTemplate(
        id: '1',
        name: 'Test',
        selectedItemIds: ['z', 'a', 'm', 'b'],
        createdAt: DateTime(2024, 1, 1),
      );

      final json = template.toJson();
      final restored = CustomTemplate.fromJson(json);

      expect(restored.selectedItemIds, ['z', 'a', 'm', 'b']);
    });
  });
}
