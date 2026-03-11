import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/data/dental_items.dart';
import '../../../common/domain/dental_item.dart';
import '../../../common/services/analytics_service.dart';
import '../../../constants/app_constants.dart';
import '../../../localization/app_localizations.dart';
import '../../../localization/content_language_provider.dart';
import '../../../localization/content_translations.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/app_shell.dart';
import '../../../widgets/language_selector.dart';
import '../services/tts_service.dart';
import 'library_search_provider.dart';
import 'widgets/category_header.dart';
import 'widgets/library_card.dart';

/// Library page displaying a scrollable grid of dental-related images
/// with captions, organized by category sections.
/// Tapping an image triggers text-to-speech of the caption.
/// Includes search functionality with debouncing for performance.
class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  late final TextEditingController _searchController;
  bool _imagesPrecached = false;

  @override
  void initState() {
    super.initState();
    // Initialize controller with current search input value
    _searchController = TextEditingController(
      text: ref.read(librarySearchInputProvider),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache all library images on first load to eliminate decode jank during scroll
    // Only do this once to avoid redundant precaching
    if (!_imagesPrecached) {
      _imagesPrecached = true;
      _precacheImages();
    }
  }

  /// Precache all library images for smoother scrolling performance
  void _precacheImages() {
    for (final item in DentalItems.all) {
      precacheImage(AssetImage(item.imagePath), context);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read services (don't watch - only need for method calls)
    final ttsService = ref.read(ttsServiceProvider);
    final analytics = ref.read(analyticsServiceProvider);

    // Watch only what's needed for UI updates
    final contentLanguage = ref.watch(contentLanguageNotifierProvider);
    final searchInput = ref.watch(librarySearchInputProvider);
    final groupedItems = ref.watch(groupedLibraryItemsProvider);

    // Compute total filtered count for result display
    final totalFilteredCount =
        groupedItems.values.fold<int>(0, (sum, list) => sum + list.length);

    // Watch speaking text stream for UI feedback
    final speakingTextAsync = ref.watch(ttsSpeakingTextStreamProvider);
    final speakingText = speakingTextAsync.valueOrNull;

    // Update TTS language when content language changes
    ref.listen<ContentLanguage>(contentLanguageNotifierProvider, (
      previous,
      next,
    ) {
      ttsService.setLanguage(next);
    });

    // Sync controller text with provider (for external updates like clear)
    if (_searchController.text != searchInput) {
      _searchController.text = searchInput;
      // Move cursor to end
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: searchInput.length),
      );
    }

    return AppShell(
      child: _buildLibraryContent(
        context,
        ttsService,
        analytics,
        contentLanguage,
        speakingText,
        groupedItems,
        totalFilteredCount,
        searchInput,
      ),
    );
  }

  Widget _buildLibraryContent(
    BuildContext context,
    TtsService ttsService,
    AnalyticsService analytics,
    ContentLanguage contentLanguage,
    String? speakingText,
    Map<String, List<DentalItem>> groupedItems,
    int totalFilteredCount,
    String searchInput,
  ) {
    // Single MediaQuery call for all layout values (performance optimization)
    final layout = Responsive.getGridLayout(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      color: context.appBackground,
      child: CustomScrollView(
        slivers: [
          // Collapsible header with "Library" title (desktop only)
          if (layout.showHeader)
            SliverAppBar(
              expandedHeight: AppConstants.headerExpandedHeight,
              pinned: true,
              floating: false,
              backgroundColor: context.appBackground,
              automaticallyImplyLeading: false,
              // Language selector in actions
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
                    l10n?.pageHeaderLibrary ?? 'Library',
                    style: TextStyle(
                      fontFamily: 'KumarOne',
                      fontSize: AppConstants.headerFontSize,
                      color: context.appTextPrimary,
                    ),
                  ),
                ),
                expandedTitleScale: layout.headerScale,
              ),
            ),
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: layout.padding.left,
                right: layout.padding.right,
                top: layout.showHeader ? 16 : 24,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(context, l10n, searchInput),
                  const SizedBox(height: 8),
                  _buildResultCount(
                    context,
                    l10n,
                    totalFilteredCount,
                    searchInput,
                  ),
                ],
              ),
            ),
          ),
          // Sectioned category grids or empty state
          if (groupedItems.isEmpty)
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
            ...groupedItems.entries.map((entry) {
              final categoryId = entry.key;
              final items = entry.value;
              final categoryName = ContentTranslations.getCategoryName(
                categoryId,
                contentLanguage,
              );
              final categoryColor = AppColors.getCategoryColor(
                categoryId,
                isDark: context.isDarkMode,
              );

              return SliverMainAxisGroup(
                slivers: [
                  // Sticky category header (pinned within this group only)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _CategoryHeaderDelegate(
                      categoryId: categoryId,
                      categoryName: categoryName,
                      horizontalPadding: EdgeInsets.symmetric(
                        horizontal: layout.padding.left,
                      ),
                      backgroundColor: context.appBackground,
                      isDarkMode: context.isDarkMode,
                    ),
                  ),
                  // Category grid
                  SliverPadding(
                    padding: EdgeInsets.only(
                      left: layout.padding.left,
                      right: layout.padding.right,
                      top: AppConstants.categoryHeaderBottomGap,
                      bottom: AppConstants.categorySectionSpacing,
                    ),
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
                          final translatedCaption =
                              ContentTranslations.getCaption(
                            item.id,
                            contentLanguage,
                          );
                          return LibraryCard(
                            key: ValueKey(item.id),
                            item: item,
                            caption: translatedCaption,
                            borderColor: categoryColor,
                            onTap: () {
                              analytics.logLibraryItemTapped(item.id);
                              analytics.logLibraryTtsPlayed(
                                item.id,
                                contentLanguage.code,
                              );
                              ttsService.speak(translatedCaption);
                            },
                            isSpeaking: speakingText == translatedCaption,
                          );
                        },
                        childCount: items.length,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: true,
                      ),
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }

  /// Builds the search bar TextField with debounced input
  Widget _buildSearchBar(
    BuildContext context,
    AppLocalizations? l10n,
    String searchInput,
  ) {
    final searchNotifier = ref.read(librarySearchNotifierProvider.notifier);

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

  /// Builds the result count indicator
  Widget _buildResultCount(
    BuildContext context,
    AppLocalizations? l10n,
    int count,
    String searchInput,
  ) {
    // Only show count when there's an active search
    if (searchInput.isEmpty) {
      return const SizedBox.shrink();
    }

    final countText = l10n?.searchResultCount(count) ?? '$count items';

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        countText,
        style: TextStyle(
          fontFamily: 'InstrumentSans',
          fontSize: 14,
          color: context.appNeutral,
        ),
      ),
    );
  }
}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String categoryId;
  final String categoryName;
  final EdgeInsets horizontalPadding;
  final Color backgroundColor;
  final bool isDarkMode;

  _CategoryHeaderDelegate({
    required this.categoryId,
    required this.categoryName,
    required this.horizontalPadding,
    required this.backgroundColor,
    required this.isDarkMode,
  });

  @override
  double get maxExtent => AppConstants.categoryHeaderHeight;

  @override
  double get minExtent => AppConstants.categoryHeaderHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isSticky = overlapsContent || shrinkOffset > 0;

    return SizedBox.expand(
      child: Container(
        color: backgroundColor,
        padding: horizontalPadding.copyWith(top: 4, bottom: 4),
        child: CategoryHeader(
          categoryId: categoryId,
          categoryName: categoryName,
          isSticky: isSticky,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CategoryHeaderDelegate oldDelegate) {
    return categoryId != oldDelegate.categoryId ||
        categoryName != oldDelegate.categoryName ||
        horizontalPadding != oldDelegate.horizontalPadding ||
        backgroundColor != oldDelegate.backgroundColor ||
        isDarkMode != oldDelegate.isDarkMode;
  }
}
