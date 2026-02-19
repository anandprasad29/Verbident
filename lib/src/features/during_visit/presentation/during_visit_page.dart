import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/data/dental_items.dart';
import '../../../common/services/analytics_service.dart';
import '../../../constants/app_constants.dart';
import '../../../localization/app_localizations.dart';
import '../../../localization/content_language_provider.dart';
import '../../../localization/content_translations.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/app_shell.dart';
import '../../../widgets/language_selector.dart';
import '../../library/presentation/widgets/library_card.dart';
import '../../library/services/tts_service.dart';

/// During Visit page displaying dental items as a flat image grid.
/// Tapping any item triggers text-to-speech of the caption.
class DuringVisitPage extends ConsumerStatefulWidget {
  const DuringVisitPage({super.key});

  @override
  ConsumerState<DuringVisitPage> createState() => _DuringVisitPageState();
}

class _DuringVisitPageState extends ConsumerState<DuringVisitPage> {
  bool _imagesPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      _imagesPrecached = true;
      _precacheImages();
    }
  }

  /// Precache all during visit images for smoother scrolling performance
  void _precacheImages() {
    for (final item in DentalItems.duringVisitItems) {
      precacheImage(AssetImage(item.imagePath), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ttsService = ref.read(ttsServiceProvider);
    final analytics = ref.read(analyticsServiceProvider);
    final contentLanguage = ref.watch(contentLanguageNotifierProvider);

    final speakingTextAsync = ref.watch(ttsSpeakingTextStreamProvider);
    final speakingText = speakingTextAsync.valueOrNull;

    ref.listen<ContentLanguage>(contentLanguageNotifierProvider, (
      previous,
      next,
    ) {
      ttsService.setLanguage(next);
    });

    return AppShell(
      child: _buildContent(
        context,
        ttsService,
        analytics,
        contentLanguage,
        speakingText,
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    TtsService ttsService,
    AnalyticsService analytics,
    ContentLanguage contentLanguage,
    String? speakingText,
  ) {
    final layout = Responsive.getGridLayout(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      color: context.appBackground,
      child: CustomScrollView(
        slivers: [
          // Collapsible header with "During the visit" title (desktop only)
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
                    l10n?.pageHeaderDuringVisit ?? 'During the visit',
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
          // Items grid
          SliverPadding(
            padding: layout.padding.copyWith(
              top: layout.showHeader ? layout.padding.top : 24,
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
                  final item = DentalItems.duringVisitItems[index];
                  final translatedCaption = ContentTranslations.getCaption(
                    item.id,
                    contentLanguage,
                  );
                  return LibraryCard(
                    key: ValueKey(item.id),
                    item: item,
                    caption: translatedCaption,
                    onTap: () {
                      analytics.logToolsItemTapped(item.id);
                      analytics.logToolsTtsPlayed(
                        item.id,
                        contentLanguage.code,
                      );
                      ttsService.speak(translatedCaption);
                    },
                    isSpeaking: speakingText == translatedCaption,
                  );
                },
                childCount: DentalItems.duringVisitItems.length,
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
}
