import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/data/dental_items.dart';
import '../../../common/domain/dental_item.dart';
import '../../../common/services/analytics_service.dart';
import '../../../localization/content_language_provider.dart';
import '../../../localization/content_translations.dart';

/// Provider for the raw (immediate) search query input.
/// This updates instantly as the user types.
final librarySearchInputProvider = StateProvider<String>((ref) => '');

/// Provider for the debounced search query.
/// This only updates after the user stops typing for 300ms.
/// Using this for filtering prevents excessive rebuilds during fast typing.
final librarySearchQueryProvider = StateProvider<String>((ref) => '');

/// Notifier that handles debouncing of search input.
/// Call [updateSearch] when the user types, and it will debounce
/// the update to [librarySearchQueryProvider].
class LibrarySearchNotifier extends StateNotifier<String> {
  final Ref _ref;
  Timer? _debounceTimer;

  static const _debounceDuration = Duration(milliseconds: 300);

  LibrarySearchNotifier(this._ref) : super('');

  /// Updates the search query with debouncing.
  /// The actual filter will only trigger after [_debounceDuration] of inactivity.
  void updateSearch(String query) {
    // Update the input provider immediately (for UI responsiveness)
    _ref.read(librarySearchInputProvider.notifier).state = query;

    // Cancel any pending debounce
    _debounceTimer?.cancel();

    // Set up new debounce timer
    _debounceTimer = Timer(_debounceDuration, () {
      // Update the debounced query provider (triggers filtering)
      _ref.read(librarySearchQueryProvider.notifier).state = query;

      // Log search analytics (only for non-empty queries)
      if (query.isNotEmpty) {
        final grouped = _ref.read(groupedLibraryItemsProvider);
        final totalCount =
            grouped.values.fold<int>(0, (sum, list) => sum + list.length);
        _ref.read(analyticsServiceProvider).logLibrarySearch(
          query.length,
          totalCount,
        );
      }
    });
  }

  /// Clears the search query immediately (no debounce needed for clear).
  void clearSearch() {
    _debounceTimer?.cancel();
    _ref.read(librarySearchInputProvider.notifier).state = '';
    _ref.read(librarySearchQueryProvider.notifier).state = '';
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Provider for the search notifier that handles debouncing.
final librarySearchNotifierProvider =
    StateNotifierProvider<LibrarySearchNotifier, String>((ref) {
  return LibrarySearchNotifier(ref);
});

/// Computed provider that returns filtered library items based on search query.
/// Kept for backward compatibility with other features.
final filteredLibraryItemsProvider = Provider<List<DentalItem>>((ref) {
  final query = ref.watch(librarySearchQueryProvider);
  final language = ref.watch(contentLanguageNotifierProvider);

  if (query.isEmpty) {
    return DentalItems.all;
  }

  final lowerQuery = query.toLowerCase();
  return DentalItems.all.where((item) {
    final caption = ContentTranslations.getCaption(item.id, language);
    return caption.toLowerCase().contains(lowerQuery);
  }).toList();
});

/// Computed provider that returns items grouped by category, with search filter applied.
/// Categories with 0 matching items are excluded from the map.
/// Category order follows [DentalItems.categories].
final groupedLibraryItemsProvider =
    Provider<Map<String, List<DentalItem>>>((ref) {
  final query = ref.watch(librarySearchQueryProvider);
  final language = ref.watch(contentLanguageNotifierProvider);
  final lowerQuery = query.toLowerCase();

  final grouped = <String, List<DentalItem>>{};

  for (final categoryId in DentalItems.categories) {
    final categoryItems = DentalItems.getByCategory(categoryId);

    final filtered = query.isEmpty
        ? categoryItems
        : categoryItems.where((item) {
            final caption = ContentTranslations.getCaption(item.id, language);
            return caption.toLowerCase().contains(lowerQuery);
          }).toList();

    if (filtered.isNotEmpty) {
      grouped[categoryId] = filtered;
    }
  }

  return grouped;
});
