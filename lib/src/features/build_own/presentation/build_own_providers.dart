import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../common/data/dental_items.dart';
import '../../../common/domain/dental_item.dart';
import '../../../localization/content_language_provider.dart';
import '../../../localization/content_translations.dart';
import '../data/template_storage_service.dart';
import '../domain/custom_template.dart';

part 'build_own_providers.g.dart';

// ============================================================================
// Constants
// ============================================================================

/// Maximum number of custom templates allowed
const int maxTemplateCount = 10;

// ============================================================================
// Custom Templates State (Persisted)
// ============================================================================

/// Loading state for templates initialization
final templatesLoadingProvider = StateProvider<bool>((ref) => true);

/// Error state for template operations
final templatesErrorProvider = StateProvider<String?>((ref) => null);

/// State notifier for managing the list of custom templates.
/// Persists to local storage via TemplateStorageService.
@Riverpod(keepAlive: true)
class CustomTemplatesNotifier extends _$CustomTemplatesNotifier {
  TemplateStorageService? _storageService;

  @override
  List<CustomTemplate> build() {
    // Initialize async - will update state when ready
    // Use Future.microtask to ensure ref is valid and catch any errors
    Future.microtask(() => _initializeAsync());
    return [];
  }

  Future<void> _initializeAsync() async {
    try {
      // Clear any previous error state
      ref.read(templatesErrorProvider.notifier).state = null;

      _storageService = ref.read(templateStorageServiceProvider);
      final templates = _storageService!.loadTemplates();
      state = templates;
    } catch (e) {
      // Set error state - catches ALL errors including ref access failures
      try {
        ref.read(templatesErrorProvider.notifier).state =
            'Failed to load templates: ${e.toString()}';
      } catch (_) {
        // If we can't even set error state, just log (provider may be disposed)
      }
    } finally {
      // Mark loading as complete - always runs
      try {
        ref.read(templatesLoadingProvider.notifier).state = false;
      } catch (_) {
        // If we can't set loading state, provider may be disposed
      }
    }
  }

  /// Checks if the template limit has been reached
  bool get isAtLimit => state.length >= maxTemplateCount;

  /// Checks if a template name already exists (case-insensitive)
  bool isNameDuplicate(String name, {String? excludeId}) {
    final lowerName = name.trim().toLowerCase();
    return state.any((t) =>
        t.name.toLowerCase() == lowerName &&
        (excludeId == null || t.id != excludeId));
  }

  /// Adds a new template. Returns error message or null on success.
  Future<String?> addTemplate(CustomTemplate template) async {
    // Check limit
    if (isAtLimit) return 'Template limit reached';

    // Check for duplicate name
    if (isNameDuplicate(template.name)) return 'Duplicate template name';

    try {
      _storageService ??= ref.read(templateStorageServiceProvider);
      final success = await _storageService!.addTemplate(template);
      if (success) {
        state = [...state, template];
        return null; // Success
      }
      return 'Failed to save template';
    } catch (e) {
      return 'Error saving template: ${e.toString()}';
    }
  }

  /// Updates an existing template. Returns error message or null on success.
  Future<String?> updateTemplate(CustomTemplate template) async {
    // Check for duplicate name (excluding current template)
    if (isNameDuplicate(template.name, excludeId: template.id)) {
      return 'Duplicate template name';
    }

    try {
      _storageService ??= ref.read(templateStorageServiceProvider);
      final success = await _storageService!.updateTemplate(template);
      if (success) {
        state = state.map((t) => t.id == template.id ? template : t).toList();
        return null; // Success
      }
      return 'Failed to update template';
    } catch (e) {
      return 'Error updating template: ${e.toString()}';
    }
  }

  /// Deletes a template by ID. Returns error message or null on success.
  Future<String?> deleteTemplate(String templateId) async {
    try {
      _storageService ??= ref.read(templateStorageServiceProvider);
      final success = await _storageService!.deleteTemplate(templateId);
      if (success) {
        state = state.where((t) => t.id != templateId).toList();
        return null; // Success
      }
      return 'Failed to delete template';
    } catch (e) {
      return 'Error deleting template: ${e.toString()}';
    }
  }

  /// Generates a default template name like "Template 1", "Template 2", etc.
  /// Skips names already in use.
  String generateDefaultName() {
    final existing = state;
    int counter = existing.length + 1;
    String candidate = 'Template $counter';
    while (existing.any((t) => t.name.toLowerCase() == candidate.toLowerCase())) {
      counter++;
      candidate = 'Template $counter';
    }
    return candidate;
  }

  /// Gets a template by ID
  CustomTemplate? getTemplate(String templateId) {
    try {
      return state.firstWhere((t) => t.id == templateId);
    } catch (_) {
      return null;
    }
  }
}

/// Provider that checks if template limit is reached
final templateLimitReachedProvider = Provider<bool>((ref) {
  final templates = ref.watch(customTemplatesNotifierProvider);
  return templates.length >= maxTemplateCount;
});

/// Provider that checks if a name is duplicate
final isTemplateNameDuplicateProvider =
    Provider.family<bool, String>((ref, name) {
  final templates = ref.watch(customTemplatesNotifierProvider);
  final lowerName = name.trim().toLowerCase();
  return templates.any((t) => t.name.toLowerCase() == lowerName);
});

// ============================================================================
// Build Own Page State (Selection & Search)
// ============================================================================

/// Provider for the template name being edited
final buildOwnTemplateNameProvider = StateProvider<String>((ref) => '');

/// Provider for selected item IDs during template building
final buildOwnSelectedIdsProvider = StateProvider<Set<String>>((ref) => {});

/// Provider for the raw (immediate) search query input
final buildOwnSearchInputProvider = StateProvider<String>((ref) => '');

/// Provider for the debounced search query
final buildOwnSearchQueryProvider = StateProvider<String>((ref) => '');

/// Notifier that handles debouncing of search input for build own page
class BuildOwnSearchNotifier extends StateNotifier<String> {
  final Ref _ref;
  Timer? _debounceTimer;

  static const _debounceDuration = Duration(milliseconds: 300);

  BuildOwnSearchNotifier(this._ref) : super('');

  /// Updates the search query with debouncing
  void updateSearch(String query) {
    // Update the input provider immediately (for UI responsiveness)
    _ref.read(buildOwnSearchInputProvider.notifier).state = query;

    // Cancel any pending debounce
    _debounceTimer?.cancel();

    // Set up new debounce timer
    _debounceTimer = Timer(_debounceDuration, () {
      _ref.read(buildOwnSearchQueryProvider.notifier).state = query;
    });
  }

  /// Clears the search query immediately
  void clearSearch() {
    _debounceTimer?.cancel();
    _ref.read(buildOwnSearchInputProvider.notifier).state = '';
    _ref.read(buildOwnSearchQueryProvider.notifier).state = '';
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Provider for the search notifier
final buildOwnSearchNotifierProvider =
    StateNotifierProvider<BuildOwnSearchNotifier, String>((ref) {
  return BuildOwnSearchNotifier(ref);
});

/// Computed provider that returns filtered library items based on search query
final filteredBuildOwnItemsProvider = Provider<List<DentalItem>>((ref) {
  final query = ref.watch(buildOwnSearchQueryProvider);
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

/// Helper provider to check if template creation is valid
final canCreateTemplateProvider = Provider<bool>((ref) {
  final selectedIds = ref.watch(buildOwnSelectedIdsProvider);
  return selectedIds.isNotEmpty;
});

/// Helper provider for selection count
final buildOwnSelectionCountProvider = Provider<int>((ref) {
  return ref.watch(buildOwnSelectedIdsProvider).length;
});

// ============================================================================
// Edit Template Page State
// ============================================================================

/// Provider for edit mode state on custom template page
final templateEditModeProvider = StateProvider<bool>((ref) => false);

/// Provider for the template name being edited (in edit mode)
final editTemplateNameProvider = StateProvider<String>((ref) => '');

/// Provider for selected item IDs during template editing
final editTemplateSelectedIdsProvider =
    StateProvider<List<String>>((ref) => []);

/// Provider for search input in edit mode
final editTemplateSearchInputProvider = StateProvider<String>((ref) => '');

/// Provider for debounced search in edit mode
final editTemplateSearchQueryProvider = StateProvider<String>((ref) => '');

/// Search notifier for edit mode
class EditTemplateSearchNotifier extends StateNotifier<String> {
  final Ref _ref;
  Timer? _debounceTimer;

  static const _debounceDuration = Duration(milliseconds: 300);

  EditTemplateSearchNotifier(this._ref) : super('');

  void updateSearch(String query) {
    _ref.read(editTemplateSearchInputProvider.notifier).state = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      _ref.read(editTemplateSearchQueryProvider.notifier).state = query;
    });
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    _ref.read(editTemplateSearchInputProvider.notifier).state = '';
    _ref.read(editTemplateSearchQueryProvider.notifier).state = '';
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final editTemplateSearchNotifierProvider =
    StateNotifierProvider<EditTemplateSearchNotifier, String>((ref) {
  return EditTemplateSearchNotifier(ref);
});

/// Filtered items for edit mode (shows items NOT currently selected)
final filteredEditTemplateItemsProvider = Provider<List<DentalItem>>((ref) {
  final query = ref.watch(editTemplateSearchQueryProvider);
  final language = ref.watch(contentLanguageNotifierProvider);
  final selectedIds = ref.watch(editTemplateSelectedIdsProvider);

  // Filter out already selected items
  var items = DentalItems.all
      .where((item) => !selectedIds.contains(item.id))
      .toList();

  if (query.isEmpty) {
    return items;
  }

  final lowerQuery = query.toLowerCase();
  return items.where((item) {
    final caption = ContentTranslations.getCaption(item.id, language);
    return caption.toLowerCase().contains(lowerQuery);
  }).toList();
});

/// Gets DentalItems from a list of IDs
List<DentalItem> getItemsFromIds(List<String> ids) {
  return DentalItems.getByIds(ids);
}
