import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../common/domain/dental_item.dart';
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
import '../domain/custom_template.dart';
import 'build_own_providers.dart';
import 'widgets/selectable_library_card.dart';

/// Build Your Own page for creating custom templates.
/// Allows users to name a template and select images from the library.
class BuildOwnPage extends ConsumerStatefulWidget {
  const BuildOwnPage({super.key});

  @override
  ConsumerState<BuildOwnPage> createState() => _BuildOwnPageState();
}

class _BuildOwnPageState extends ConsumerState<BuildOwnPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: ref.read(buildOwnTemplateNameProvider),
    );
    _searchController = TextEditingController(
      text: ref.read(buildOwnSearchInputProvider),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameController.clear();
    _searchController.clear();
    ref.read(buildOwnTemplateNameProvider.notifier).state = '';
    ref.read(buildOwnSelectedIdsProvider.notifier).state = {};
    ref.read(buildOwnSearchNotifierProvider.notifier).clearSearch();
  }

  Future<void> _createTemplate() async {
    final l10n = AppLocalizations.of(context);
    var name = ref.read(buildOwnTemplateNameProvider).trim();
    final selectedIds = ref.read(buildOwnSelectedIdsProvider);
    final notifier = ref.read(customTemplatesNotifierProvider.notifier);

    if (selectedIds.isEmpty) return;

    // Auto-generate name if not provided
    if (name.isEmpty) {
      name = notifier.generateDefaultName();
    }

    // Check template limit
    if (notifier.isAtLimit) {
      _showLimitReachedDialog(l10n);
      return;
    }

    // Check for duplicate name
    if (notifier.isNameDuplicate(name)) {
      _showDuplicateNameError(l10n);
      return;
    }

    final template = CustomTemplate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      selectedItemIds: selectedIds.toList(),
      createdAt: DateTime.now(),
    );

    final error = await notifier.addTemplate(template);

    if (mounted) {
      if (error == null) {
        // Log template creation analytics
        ref.read(analyticsServiceProvider).logTemplateCreated(selectedIds.length);
        
        _resetForm();
        // Navigate to the newly created template
        context.go(Routes.customTemplatePath(template.id));
      } else {
        // Show error
        _showErrorSnackBar(error);
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

  void _showLimitReachedDialog(AppLocalizations? l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.appCardBackground,
        title: Text(
          l10n?.templateLimitReached ?? 'Template limit reached',
          style: TextStyle(
            fontFamily: 'InstrumentSans',
            color: context.appTextPrimary,
          ),
        ),
        content: Text(
          l10n?.templateLimitMessage(maxTemplateCount) ??
              'You can create up to $maxTemplateCount templates. Please delete an existing template to create a new one.',
          style: TextStyle(
            fontFamily: 'InstrumentSans',
            color: context.appTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: context.appPrimary)),
          ),
        ],
      ),
    );
  }

  void _showDuplicateNameError(AppLocalizations? l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n?.duplicateNameError ??
              'A template with this name already exists',
          style: const TextStyle(fontFamily: 'InstrumentSans'),
        ),
        backgroundColor: context.appError,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contentLanguage = ref.watch(contentLanguageNotifierProvider);
    final searchInput = ref.watch(buildOwnSearchInputProvider);
    final filteredItems = ref.watch(filteredBuildOwnItemsProvider);
    final selectedIds = ref.watch(buildOwnSelectedIdsProvider);
    final canCreate = ref.watch(canCreateTemplateProvider);
    final selectionCount = ref.watch(buildOwnSelectionCountProvider);

    // Sync controllers with providers
    final templateName = ref.watch(buildOwnTemplateNameProvider);
    if (_nameController.text != templateName) {
      _nameController.text = templateName;
      _nameController.selection = TextSelection.fromPosition(
        TextPosition(offset: templateName.length),
      );
    }
    if (_searchController.text != searchInput) {
      _searchController.text = searchInput;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: searchInput.length),
      );
    }

    return AppShell(
      child: _buildContent(
        context,
        contentLanguage,
        filteredItems,
        selectedIds,
        searchInput,
        canCreate,
        selectionCount,
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ContentLanguage contentLanguage,
    List<DentalItem> filteredItems,
    Set<String> selectedIds,
    String searchInput,
    bool canCreate,
    int selectionCount,
  ) {
    // Single MediaQuery call for all layout values (performance optimization)
    final layout = Responsive.getGridLayout(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.appBackground,
      floatingActionButton: _buildFAB(context, l10n, canCreate, selectionCount),
      body: CustomScrollView(
        slivers: [
          // Collapsible header area (desktop only)
          if (layout.showHeader)
            SliverAppBar(
              expandedHeight: AppConstants.headerExpandedHeight,
              pinned: true,
              floating: false,
              backgroundColor: context.appBackground,
              automaticallyImplyLeading: false,
              actions: [
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
                    l10n?.pageHeaderBuildOwn ?? 'Build your own',
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
          // Template name input
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: layout.padding.left,
                right: layout.padding.right,
                top: layout.showHeader ? 16 : 24,
                bottom: 16,
              ),
              child: _buildNameInput(context, l10n),
            ),
          ),
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: layout.padding.left),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(context, l10n, searchInput),
                  const SizedBox(height: 8),
                  _buildResultInfo(
                    context,
                    l10n,
                    filteredItems.length,
                    searchInput,
                    selectionCount,
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          // Grid of selectable items
          if (filteredItems.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, size: 64, color: context.appNeutral),
                    const SizedBox(height: 16),
                    Text(
                      l10n?.searchNoResults ?? 'No results found',
                      style: TextStyle(
                        fontFamily: 'InstrumentSans',
                        fontSize: 18,
                        color: context.appTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: layout.padding.copyWith(
                top: 0,
                bottom: 80,
              ), // Space for FAB
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: layout.columnCount,
                  mainAxisSpacing: layout.spacing,
                  crossAxisSpacing: layout.spacing,
                  childAspectRatio: layout.aspectRatio,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = filteredItems[index];
                    final translatedCaption = ContentTranslations.getCaption(
                      item.id,
                      contentLanguage,
                    );
                    final isSelected = selectedIds.contains(item.id);

                    return SelectableLibraryCard(
                      key: ValueKey(item.id),
                      item: item,
                      caption: translatedCaption,
                      isSelected: isSelected,
                      onTap: () => _toggleSelection(item.id),
                    );
                  },
                  childCount: filteredItems.length,
                  // Optimize memory for selection grids
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNameInput(BuildContext context, AppLocalizations? l10n) {
    final templateName = ref.watch(buildOwnTemplateNameProvider);
    final isEmpty = templateName.isEmpty;

    return TextField(
      controller: _nameController,
      onChanged: (value) {
        ref.read(buildOwnTemplateNameProvider.notifier).state = value;
      },
      style: TextStyle(
        fontFamily: 'InstrumentSans',
        fontSize: 24,
        color: isEmpty ? context.appNeutral : context.appTextPrimary,
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
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    AppLocalizations? l10n,
    String searchInput,
  ) {
    final searchNotifier = ref.read(buildOwnSearchNotifierProvider.notifier);

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

  Widget _buildResultInfo(
    BuildContext context,
    AppLocalizations? l10n,
    int count,
    String searchInput,
    int selectionCount,
  ) {
    return Row(
      children: [
        if (searchInput.isNotEmpty)
          Text(
            l10n?.searchResultCount(count) ?? '$count items',
            style: TextStyle(
              fontFamily: 'InstrumentSans',
              fontSize: 14,
              color: context.appNeutral,
            ),
          )
        else if (selectionCount == 0)
          // Empty state prompt
          Flexible(
            child: Row(
              children: [
                Icon(Icons.touch_app, size: 16, color: context.appPrimary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l10n?.emptyTemplatePrompt ??
                        'Tap images below to add them to your template',
                    style: TextStyle(
                      fontFamily: 'InstrumentSans',
                      fontSize: 14,
                      color: context.appPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        const Spacer(),
        if (selectionCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: context.appPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              l10n?.selectedCount(selectionCount) ?? '$selectionCount selected',
              style: TextStyle(
                fontFamily: 'InstrumentSans',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: context.appPrimary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFAB(
    BuildContext context,
    AppLocalizations? l10n,
    bool canCreate,
    int selectionCount,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: (canCreate ? context.appPrimary : context.appNeutral)
                .withValues(alpha: 0.7),
            child: InkWell(
              onTap: canCreate ? _createTemplate : null,
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      l10n?.createTemplate ?? 'Create Template',
                      style: const TextStyle(
                        fontFamily: 'InstrumentSans',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (selectionCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$selectionCount',
                          style: const TextStyle(
                            fontFamily: 'InstrumentSans',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleSelection(String itemId) {
    final selectedIds = ref.read(buildOwnSelectedIdsProvider);
    final newSelection = Set<String>.from(selectedIds);

    if (newSelection.contains(itemId)) {
      newSelection.remove(itemId);
    } else {
      newSelection.add(itemId);
    }

    ref.read(buildOwnSelectedIdsProvider.notifier).state = newSelection;
  }
}
