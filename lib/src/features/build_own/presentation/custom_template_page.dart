import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../common/services/analytics_service.dart';
import '../../../constants/app_constants.dart';
import '../../../localization/app_localizations.dart';
import '../../../localization/content_language_provider.dart';
import '../../../localization/content_translations.dart';
import '../../../routing/routes.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/app_shell.dart';
import '../../../widgets/language_selector.dart';
import '../../library/presentation/widgets/library_card.dart';
import '../../library/services/tts_service.dart';
import '../domain/custom_template.dart';
import 'build_own_providers.dart';
import 'widgets/selectable_library_card.dart';

/// Page for viewing and editing a custom template.
/// Has two modes:
/// - View mode (default): Read-only display similar to Before Visit
/// - Edit mode: Allows editing name, reordering, adding/removing images
class CustomTemplatePage extends ConsumerStatefulWidget {
  final String templateId;

  const CustomTemplatePage({super.key, required this.templateId});

  @override
  ConsumerState<CustomTemplatePage> createState() => _CustomTemplatePageState();
}

class _CustomTemplatePageState extends ConsumerState<CustomTemplatePage> {
  late TextEditingController _nameController;
  late TextEditingController _searchController;

  // Track original state to detect unsaved changes
  String _originalName = '';
  List<String> _originalSelectedIds = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _searchController = TextEditingController();
    // Initialize edit state after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeEditState();
    });
  }

  void _initializeEditState() {
    final template = ref
        .read(customTemplatesNotifierProvider.notifier)
        .getTemplate(widget.templateId);
    if (template != null) {
      // Initialize providers with template data
      ref.read(editTemplateNameProvider.notifier).state = template.name;
      ref.read(editTemplateSelectedIdsProvider.notifier).state = List.from(
        template.selectedItemIds,
      );
      _nameController.text = template.name;

      // Also initialize original state for unsaved changes detection
      // This ensures correct comparison even if data changes before entering edit mode
      _originalName = template.name;
      _originalSelectedIds = List.from(template.selectedItemIds);

      // Log template played analytics
      ref.read(analyticsServiceProvider).logTemplatePlayed(
        template.selectedItemIds.length,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _enterEditMode() {
    final template = ref
        .read(customTemplatesNotifierProvider.notifier)
        .getTemplate(widget.templateId);
    if (template != null) {
      // Store original state for unsaved changes detection
      _originalName = template.name;
      _originalSelectedIds = List.from(template.selectedItemIds);

      ref.read(editTemplateNameProvider.notifier).state = template.name;
      ref.read(editTemplateSelectedIdsProvider.notifier).state = List.from(
        template.selectedItemIds,
      );
      _nameController.text = template.name;
      ref.read(templateEditModeProvider.notifier).state = true;
    }
  }

  bool _hasUnsavedChanges() {
    final currentName = ref.read(editTemplateNameProvider);
    final currentIds = ref.read(editTemplateSelectedIdsProvider);

    if (currentName != _originalName) return true;
    if (currentIds.length != _originalSelectedIds.length) return true;
    for (int i = 0; i < currentIds.length; i++) {
      if (currentIds[i] != _originalSelectedIds[i]) return true;
    }
    return false;
  }

  /// Exits edit mode. If [skipUnsavedCheck] is true, skips the confirmation dialog.
  Future<void> _exitEditMode({bool skipUnsavedCheck = false}) async {
    if (!skipUnsavedCheck && _hasUnsavedChanges()) {
      final l10n = AppLocalizations.of(context);
      final shouldDiscard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: context.appCardBackground,
          title: Text(
            l10n?.unsavedChangesTitle ?? 'Unsaved Changes',
            style: TextStyle(
              fontFamily: 'InstrumentSans',
              color: context.appTextPrimary,
            ),
          ),
          content: Text(
            l10n?.unsavedChangesMessage ??
                'You have unsaved changes. Are you sure you want to discard them?',
            style: TextStyle(
              fontFamily: 'InstrumentSans',
              color: context.appTextSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                l10n?.cancel ?? 'Cancel',
                style: TextStyle(color: context.appNeutral),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                l10n?.discard ?? 'Discard',
                style: TextStyle(color: context.appError),
              ),
            ),
          ],
        ),
      );

      if (shouldDiscard != true) return;
    }

    ref.read(templateEditModeProvider.notifier).state = false;
    ref.read(editTemplateSearchNotifierProvider.notifier).clearSearch();
    _searchController.clear();
  }

  Future<void> _saveChanges() async {
    final name = ref.read(editTemplateNameProvider).trim();
    final selectedIds = ref.read(editTemplateSelectedIdsProvider);

    if (name.isEmpty || selectedIds.isEmpty) return;

    final template = ref
        .read(customTemplatesNotifierProvider.notifier)
        .getTemplate(widget.templateId);
    if (template != null) {
      final updatedTemplate = template.copyWith(
        name: name,
        selectedItemIds: selectedIds,
      );
      final error = await ref
          .read(customTemplatesNotifierProvider.notifier)
          .updateTemplate(updatedTemplate);

      if (mounted) {
        if (error == null) {
          // Skip unsaved check since we just saved
          _exitEditMode(skipUnsavedCheck: true);
        } else {
          _showErrorSnackBar(error);
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'InstrumentSans'),
        ),
        backgroundColor: context.appError,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteTemplate() async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.appCardBackground,
        title: Text(
          l10n?.deleteTemplate ?? 'Delete Template',
          style: TextStyle(
            fontFamily: 'InstrumentSans',
            color: context.appTextPrimary,
          ),
        ),
        content: Text(
          l10n?.deleteConfirmation ??
              'Are you sure you want to delete this template?',
          style: TextStyle(
            fontFamily: 'InstrumentSans',
            color: context.appTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n?.cancel ?? 'Cancel',
              style: TextStyle(color: context.appNeutral),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n?.delete ?? 'Delete',
              style: TextStyle(color: context.appError),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final error = await ref
          .read(customTemplatesNotifierProvider.notifier)
          .deleteTemplate(widget.templateId);
      if (mounted) {
        if (error == null) {
          context.go(Routes.buildOwn);
        } else {
          _showErrorSnackBar(error);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(templatesLoadingProvider);
    final templates = ref.watch(customTemplatesNotifierProvider);
    final template = templates
        .where((t) => t.id == widget.templateId)
        .firstOrNull;
    final isEditMode = ref.watch(templateEditModeProvider);
    final l10n = AppLocalizations.of(context);

    // Show loading state while templates are being loaded from storage
    if (isLoading) {
      return AppShell(
        showHomeButton: true,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: context.appPrimary),
              const SizedBox(height: 16),
              Text(
                l10n?.loadingTemplates ?? 'Loading templates...',
                style: TextStyle(
                  fontFamily: 'InstrumentSans',
                  color: context.appTextSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Only show "not found" after loading is complete
    if (template == null) {
      return AppShell(
        showHomeButton: true,
        child: Center(
          child: Text(
            'Template not found',
            style: TextStyle(
              fontFamily: 'InstrumentSans',
              color: context.appTextSecondary,
            ),
          ),
        ),
      );
    }

    return AppShell(
      showHomeButton: true,
      child: isEditMode
          ? _buildEditMode(context, template)
          : _buildViewMode(context, template),
    );
  }

  Widget _buildViewMode(BuildContext context, CustomTemplate template) {
    final ttsService = ref.read(ttsServiceProvider);
    final contentLanguage = ref.watch(contentLanguageNotifierProvider);
    final speakingTextAsync = ref.watch(ttsSpeakingTextStreamProvider);
    final speakingText = speakingTextAsync.valueOrNull;

    // Update TTS language when content language changes
    ref.listen<ContentLanguage>(contentLanguageNotifierProvider, (
      previous,
      next,
    ) {
      ttsService.setLanguage(next);
    });

    // Single MediaQuery call for all layout values (performance optimization)
    final layout = Responsive.getGridLayout(context);
    final l10n = AppLocalizations.of(context);

    final items = getItemsFromIds(template.selectedItemIds);

    return Container(
      color: context.appBackground,
      child: CustomScrollView(
        slivers: [
          // Header with template name (desktop only)
          if (layout.showHeader)
            SliverAppBar(
              expandedHeight: AppConstants.headerExpandedHeight,
              pinned: true,
              floating: false,
              backgroundColor: context.appBackground,
              automaticallyImplyLeading: false,
              actions: [
                // Edit button
                IconButton(
                  icon: Icon(Icons.edit, color: context.appPrimary),
                  onPressed: _enterEditMode,
                  tooltip: l10n?.editTemplate ?? 'Edit',
                ),
                // Language selector
                Padding(
                  padding: const EdgeInsets.only(right: 16, top: 8),
                  child: LanguageSelector(compact: true),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 16),
                title: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    template.name,
                    style: TextStyle(
                      fontFamily: 'InstrumentSans',
                      fontSize: AppConstants.headerFontSize,
                      color: context.appTextPrimary,
                    ),
                  ),
                ),
                expandedTitleScale: layout.headerScale,
              ),
            ),
          // Mobile header with edit button
          if (!layout.showHeader)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  left: layout.padding.left,
                  right: layout.padding.right,
                  top: 16,
                  bottom: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        template.name,
                        style: TextStyle(
                          fontFamily: 'InstrumentSans',
                          fontSize: 20,
                          color: context.appTextPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: context.appPrimary),
                      onPressed: _enterEditMode,
                      tooltip: l10n?.editTemplate ?? 'Edit',
                    ),
                  ],
                ),
              ),
            ),
          // Grid of template images
          SliverPadding(
            padding: layout.padding.copyWith(top: layout.showHeader ? 16 : 8),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: layout.columnCount,
                mainAxisSpacing: layout.spacing,
                crossAxisSpacing: layout.spacing,
                childAspectRatio: layout.aspectRatio,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = items[index];
                  final translatedCaption = ContentTranslations.getCaption(
                    item.id,
                    contentLanguage,
                  );
                  return LibraryCard(
                    key: ValueKey(item.id),
                    item: item,
                    caption: translatedCaption,
                    onTap: () => ttsService.speak(translatedCaption),
                    isSpeaking: speakingText == translatedCaption,
                  );
                },
                childCount: items.length,
                // Optimize memory for template grids
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
              ),
            ),
          ),
          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildEditMode(BuildContext context, CustomTemplate template) {
    final contentLanguage = ref.watch(contentLanguageNotifierProvider);
    final editName = ref.watch(editTemplateNameProvider);
    final selectedIds = ref.watch(editTemplateSelectedIdsProvider);
    final searchInput = ref.watch(editTemplateSearchInputProvider);
    final availableItems = ref.watch(filteredEditTemplateItemsProvider);

    // Single MediaQuery call for all layout values (performance optimization)
    final layout = Responsive.getGridLayout(context);
    final l10n = AppLocalizations.of(context);

    // Sync controller
    if (_nameController.text != editName) {
      _nameController.text = editName;
      _nameController.selection = TextSelection.fromPosition(
        TextPosition(offset: editName.length),
      );
    }
    if (_searchController.text != searchInput) {
      _searchController.text = searchInput;
    }

    final selectedItems = getItemsFromIds(selectedIds);
    final canSave = editName.trim().isNotEmpty && selectedIds.isNotEmpty;

    return Scaffold(
      backgroundColor: context.appBackground,
      body: CustomScrollView(
        slivers: [
          // Edit mode header
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: context.appBackground,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(Icons.close, color: context.appNeutral),
              onPressed: _exitEditMode,
              tooltip: l10n?.cancel ?? 'Cancel',
            ),
            title: Text(
              l10n?.editTemplate ?? 'Edit',
              style: TextStyle(
                fontFamily: 'InstrumentSans',
                fontSize: 18,
                color: context.appTextPrimary,
              ),
            ),
            centerTitle: true,
            actions: [
              // Delete button
              IconButton(
                icon: Icon(Icons.delete_outline, color: context.appError),
                onPressed: _deleteTemplate,
                tooltip: l10n?.deleteTemplate ?? 'Delete Template',
              ),
              // Save button
              TextButton(
                onPressed: canSave ? _saveChanges : null,
                child: Text(
                  l10n?.save ?? 'Save',
                  style: TextStyle(
                    fontFamily: 'InstrumentSans',
                    fontWeight: FontWeight.bold,
                    color: canSave ? context.appPrimary : context.appNeutral,
                  ),
                ),
              ),
            ],
          ),
          // Name input
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: layout.padding.left,
                vertical: 16,
              ),
              child: TextField(
                controller: _nameController,
                onChanged: (value) {
                  ref.read(editTemplateNameProvider.notifier).state = value;
                },
                style: TextStyle(
                  fontFamily: 'InstrumentSans',
                  fontSize: 24,
                  color: context.appTextPrimary,
                ),
                decoration: InputDecoration(
                  hintText: l10n?.templateNamePlaceholder ?? 'Template Name',
                  hintStyle: TextStyle(
                    fontFamily: 'InstrumentSans',
                    fontSize: 24,
                    color: context.appNeutral,
                  ),
                  border: InputBorder.none,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: context.appCardBorder.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: context.appPrimary, width: 2),
                  ),
                ),
              ),
            ),
          ),
          // Current images section header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: layout.padding.left),
              child: Row(
                children: [
                  Text(
                    l10n?.currentImages ?? 'Current Images',
                    style: TextStyle(
                      fontFamily: 'InstrumentSans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.appTextSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${selectedIds.length})',
                    style: TextStyle(
                      fontFamily: 'InstrumentSans',
                      fontSize: 14,
                      color: context.appNeutral,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    l10n?.tapToRemove ?? 'Tap to remove',
                    style: TextStyle(
                      fontFamily: 'InstrumentSans',
                      fontSize: 12,
                      color: context.appNeutral,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          // Current images - reorderable grid
          if (selectedItems.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: layout.padding.left),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: context.appCardBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      l10n?.noImagesSelected ?? 'No images selected yet',
                      style: TextStyle(
                        fontFamily: 'InstrumentSans',
                        color: context.appNeutral,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: layout.padding.left),
                child: _buildReorderableGrid(
                  context,
                  selectedItems,
                  selectedIds,
                  contentLanguage,
                  layout,
                ),
              ),
            ),
          // Add images section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: layout.padding.left,
                right: layout.padding.right,
                top: 32,
                bottom: 12,
              ),
              child: Text(
                l10n?.addImages ?? 'Add Images',
                style: TextStyle(
                  fontFamily: 'InstrumentSans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.appTextSecondary,
                ),
              ),
            ),
          ),
          // Search bar for adding images
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: layout.padding.left),
              child: _buildSearchBar(context, l10n, searchInput),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          // Available images grid
          if (availableItems.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: layout.padding.left),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: context.appCardBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      searchInput.isNotEmpty
                          ? (l10n?.searchNoResults ?? 'No results found')
                          : 'All images have been added',
                      style: TextStyle(
                        fontFamily: 'InstrumentSans',
                        color: context.appNeutral,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: layout.padding.copyWith(top: 0, bottom: 24),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: layout.columnCount,
                  mainAxisSpacing: layout.spacing,
                  crossAxisSpacing: layout.spacing,
                  childAspectRatio: layout.aspectRatio,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = availableItems[index];
                    final translatedCaption = ContentTranslations.getCaption(
                      item.id,
                      contentLanguage,
                    );
                    return SelectableLibraryCard(
                      key: ValueKey(item.id),
                      item: item,
                      caption: translatedCaption,
                      isSelected: false,
                      onTap: () => _addItem(item.id),
                    );
                  },
                  childCount: availableItems.length,
                  // Optimize memory for edit mode grids
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds a reorderable grid for the selected images
  Widget _buildReorderableGrid(
    BuildContext context,
    List<dynamic> selectedItems,
    List<String> selectedIds,
    ContentLanguage contentLanguage,
    GridLayout layout,
  ) {
    // Calculate item size based on available width (using cached layout values)
    final screenWidth = MediaQuery.sizeOf(context).width;
    final availableWidth =
        screenWidth - layout.padding.horizontal - (layout.showHeader ? 250 : 0);
    final itemWidth =
        (availableWidth - (layout.spacing * (layout.columnCount - 1))) /
        layout.columnCount;
    final itemHeight = itemWidth / layout.aspectRatio;

    return ReorderableWrap(
      spacing: layout.spacing,
      runSpacing: layout.spacing,
      onReorder: (oldIndex, newIndex) {
        final newIds = List<String>.from(selectedIds);
        final item = newIds.removeAt(oldIndex);
        newIds.insert(newIndex, item);
        ref.read(editTemplateSelectedIdsProvider.notifier).state = newIds;
      },
      children: selectedItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final translatedCaption = ContentTranslations.getCaption(
          item.id,
          contentLanguage,
        );
        return SizedBox(
          key: ValueKey(item.id),
          width: itemWidth,
          height: itemHeight,
          child: DraggableLibraryCard(
            item: item,
            caption: translatedCaption,
            onRemove: () => _removeItem(item.id),
            index: index,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    AppLocalizations? l10n,
    String searchInput,
  ) {
    final searchNotifier = ref.read(
      editTemplateSearchNotifierProvider.notifier,
    );

    return TextField(
      controller: _searchController,
      onChanged: (value) {
        searchNotifier.updateSearch(value);
      },
      decoration: InputDecoration(
        hintText: l10n?.searchPlaceholder ?? 'Search by caption...',
        hintStyle: TextStyle(
          fontFamily: 'InstrumentSans',
          color: context.appNeutral,
        ),
        prefixIcon: Icon(Icons.search, color: context.appCardBorder),
        suffixIcon: searchInput.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: context.appNeutral),
                onPressed: () {
                  searchNotifier.clearSearch();
                  _searchController.clear();
                },
              )
            : null,
        filled: true,
        fillColor: context.appCardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.appCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.appCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.appPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      style: TextStyle(
        fontFamily: 'InstrumentSans',
        color: context.appTextSecondary,
      ),
    );
  }

  void _addItem(String itemId) {
    final currentIds = ref.read(editTemplateSelectedIdsProvider);
    ref.read(editTemplateSelectedIdsProvider.notifier).state = [
      ...currentIds,
      itemId,
    ];
  }

  void _removeItem(String itemId) {
    final currentIds = ref.read(editTemplateSelectedIdsProvider);
    ref.read(editTemplateSelectedIdsProvider.notifier).state = currentIds
        .where((id) => id != itemId)
        .toList();
  }
}
