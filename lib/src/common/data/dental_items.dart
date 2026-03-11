// GENERATED CODE - DO NOT EDIT BY HAND
// Generated from assets/dental_items.yaml
// To regenerate, run: dart run tool/generate_dental_items.dart

import '../domain/dental_item.dart';

/// Central repository of all dental items used across the app.
/// This is the single source of truth for dental content.
/// All features (Library, Before Visit, Build Your Own, etc.) reference these items.
///
/// To add or modify items, edit assets/dental_items.yaml and regenerate this file.
class DentalItems {
  /// All dental items available in the app.
  /// Images are stored in `assets/images/library/`.
  static const List<DentalItem> all = [
    DentalItem(
      id: 'toothbrush',
      imagePath: 'assets/images/library/toothbrush.webp',
      caption: 'Toothbrush',
      category: 'actions-and-objects',
    ),
    DentalItem(
      id: 'floss',
      imagePath: 'assets/images/library/floss.webp',
      caption: 'Floss',
      category: 'actions-and-objects',
    ),
    DentalItem(
      id: 'water',
      imagePath: 'assets/images/library/water.webp',
      caption: 'Water',
      category: 'actions-and-objects',
    ),
    DentalItem(
      id: 'toothpaste',
      imagePath: 'assets/images/library/toothpaste.webp',
      caption: 'Toothpaste',
      category: 'actions-and-objects',
    ),
    DentalItem(
      id: 'tooth',
      imagePath: 'assets/images/library/tooth.webp',
      caption: 'Tooth',
      category: 'actions-and-objects',
    ),
    DentalItem(
      id: 'tongue',
      imagePath: 'assets/images/library/tongue.webp',
      caption: 'Tongue',
      category: 'actions-and-objects',
    ),
    DentalItem(
      id: 'dental-mirror',
      imagePath: 'assets/images/library/dental_mirror.webp',
      caption: 'This is a mirror',
      category: 'actions-and-objects',
    ),
    DentalItem(
      id: 'dental-drill',
      imagePath: 'assets/images/library/dental_drill.webp',
      caption: 'This is the Drill',
      category: 'actions-and-objects',
    ),
    DentalItem(
      id: 'spit-out',
      imagePath: 'assets/images/library/spit_out.webp',
      caption: 'Spit out',
      category: 'instructional-words',
    ),
    DentalItem(
      id: 'do-not-swallow',
      imagePath: 'assets/images/library/do_not_swallow.webp',
      caption: 'Do not swallow',
      category: 'instructional-words',
    ),
    DentalItem(
      id: 'hands-on-the-side',
      imagePath: 'assets/images/library/hands_on_the_side.webp',
      caption: 'Hands on the side',
      category: 'instructional-words',
    ),
    DentalItem(
      id: 'bite-down',
      imagePath: 'assets/images/library/bite_down.webp',
      caption: 'Bite down',
      category: 'instructional-words',
    ),
    DentalItem(
      id: 'open-mouth',
      imagePath: 'assets/images/library/open_mouth.webp',
      caption: 'Open your mouth',
      category: 'instructional-words',
    ),
    DentalItem(
      id: 'close-your-mouth',
      imagePath: 'assets/images/library/close_your_mouth.webp',
      caption: 'Close your mouth',
      category: 'instructional-words',
    ),
    DentalItem(
      id: 'suction',
      imagePath: 'assets/images/library/suction.webp',
      caption: 'This is a suction',
      category: 'instructional-words',
    ),
    DentalItem(
      id: 'hurt',
      imagePath: 'assets/images/library/hurt.webp',
      caption: 'Hurt',
      category: 'expression',
    ),
    DentalItem(
      id: 'mad',
      imagePath: 'assets/images/library/mad.webp',
      caption: 'Mad',
      category: 'expression',
    ),
    DentalItem(
      id: 'tired',
      imagePath: 'assets/images/library/tired.webp',
      caption: 'Tired',
      category: 'expression',
    ),
    DentalItem(
      id: 'stop',
      imagePath: 'assets/images/library/stop.webp',
      caption: 'Stop',
      category: 'non-dental',
    ),
    DentalItem(
      id: 'all-done',
      imagePath: 'assets/images/library/all_done.webp',
      caption: 'All done',
      category: 'non-dental',
    ),
    DentalItem(
      id: 'break',
      imagePath: 'assets/images/library/break.webp',
      caption: 'Break',
      category: 'non-dental',
    ),
    DentalItem(
      id: 'yes',
      imagePath: 'assets/images/library/yes.webp',
      caption: 'Yes',
      category: 'non-dental',
    ),
    DentalItem(
      id: 'no',
      imagePath: 'assets/images/library/no.webp',
      caption: 'No',
      category: 'non-dental',
    ),
    DentalItem(
      id: 'i-dont-like-that',
      imagePath: 'assets/images/library/i_dont_like_that.webp',
      caption: "I don't like that",
      category: 'non-dental',
    ),
  ];

  /// Ordered list of category IDs for display.
  static const List<String> categories = [
    'actions-and-objects',
    'instructional-words',
    'expression',
    'non-dental',
  ];

  /// IDs for the "During Visit" items grid.
  /// These items are shown as a flat image grid.
  static const List<String> duringVisitIds = [
    'dental-mirror',
    'dental-drill',
    'suction',
    'open-mouth',
    'stop',
  ];

  /// Lookup map for fast ID-based access.
  static final Map<String, DentalItem> _itemMap = {
    for (var item in all) item.id: item,
  };

  /// Get items by their IDs (preserves order).
  /// Returns only items that exist in the catalog.
  static List<DentalItem> getByIds(List<String> ids) {
    return ids
        .where((id) => _itemMap.containsKey(id))
        .map((id) => _itemMap[id]!)
        .toList();
  }

  /// Get a single item by ID.
  /// Returns null if not found.
  static DentalItem? getById(String id) => _itemMap[id];

  /// Get items filtered by category.
  static List<DentalItem> getByCategory(String category) {
    return all.where((item) => item.category == category).toList();
  }

  /// Get items for the During Visit items grid.
  static List<DentalItem> get duringVisitItems =>
      getByIds(duringVisitIds);

  // Private constructor to prevent instantiation
  DentalItems._();
}

