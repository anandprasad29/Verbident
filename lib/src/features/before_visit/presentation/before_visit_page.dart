import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/domain/dental_item.dart';
import '../../../common/services/analytics_service.dart';
import '../../../common/widgets/story_sequence.dart';
import '../../../constants/app_constants.dart';
import '../../../localization/app_localizations.dart';
import '../../../localization/content_language_provider.dart';
import '../../../localization/content_translations.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/app_shell.dart';
import '../../../widgets/language_selector.dart';
import '../../library/services/tts_service.dart';

/// Story items shown in the Before Visit sequence.
/// These are defined locally (not in the shared library catalog).
const _storyItems = [
  DentalItem(
    id: 'dentist-chair',
    imagePath: 'assets/images/library/dentist_chair.webp',
    caption: "This is the dentist's chair",
  ),
  DentalItem(
    id: 'dentist-mask',
    imagePath: 'assets/images/library/dentist_mask.webp',
    caption: 'The dentist wears a mask',
  ),
  DentalItem(
    id: 'dentist-gloves',
    imagePath: 'assets/images/library/dentist_gloves.webp',
    caption: 'The dentist wears a glove',
  ),
  DentalItem(
    id: 'bright-light',
    imagePath: 'assets/images/library/bright_light.webp',
    caption: 'The dentist has a bright light',
  ),
  DentalItem(
    id: 'count-teeth',
    imagePath: 'assets/images/library/count_teeth.webp',
    caption: 'The dentist will count your teeth',
  ),
];

/// Before Visit page displaying dental visit preparation content.
/// Shows a story sequence with arrows — horizontal on tablets, vertical on phones.
/// Tapping any item triggers text-to-speech of the caption.
class BeforeVisitPage extends ConsumerStatefulWidget {
  const BeforeVisitPage({super.key});

  @override
  ConsumerState<BeforeVisitPage> createState() => _BeforeVisitPageState();
}

class _BeforeVisitPageState extends ConsumerState<BeforeVisitPage> {
  bool _imagesPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      _imagesPrecached = true;
      _precacheImages();
    }
  }

  void _precacheImages() {
    for (final item in _storyItems) {
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
                    l10n?.pageHeaderBeforeVisit ?? 'Before the visit',
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
          // Story sequence — vertically centered on tablet+, top-aligned on phone
          SliverToBoxAdapter(
            child: _buildStorySequence(
              context, layout, contentLanguage, speakingText, analytics,
              ttsService,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorySequence(
    BuildContext context,
    GridLayout layout,
    ContentLanguage contentLanguage,
    String? speakingText,
    AnalyticsService analytics,
    TtsService ttsService,
  ) {
    // Check if StorySequence will render horizontally by computing the same
    // available width it sees (content width minus horizontal padding).
    // StorySequence uses 600px as its tablet breakpoint.
    final contentWidth = Responsive.getContentWidth(context);
    final horizontalPadding = layout.padding.left + layout.padding.right;
    final storyAvailableWidth = contentWidth - horizontalPadding;
    final isHorizontalLayout = storyAvailableWidth >= 600;

    final topPadding = layout.showHeader ? 16.0 : 24.0;
    EdgeInsets padding;
    if (isHorizontalLayout) {
      // Vertically center the horizontal story sequence on screen
      final screenHeight = MediaQuery.of(context).size.height;
      final headerHeight =
          layout.showHeader ? AppConstants.headerExpandedHeight : 0.0;
      final availableHeight = screenHeight - headerHeight;
      const estimatedContentHeight = 260.0;
      final verticalPad =
          ((availableHeight - estimatedContentHeight) / 2).clamp(topPadding, double.infinity);
      padding = layout.padding.copyWith(top: verticalPad, bottom: 24);
    } else {
      padding = layout.padding.copyWith(top: topPadding, bottom: 24);
    }

    return StorySequence(
      items: _storyItems,
      contentLanguage: contentLanguage,
      speakingText: speakingText,
      padding: padding,
      onItemTap: (item) {
        final translatedCaption = ContentTranslations.getCaption(
          item.id,
          contentLanguage,
        );
        final position = _storyItems.indexOf(item);
        analytics.logStoryItemTapped(item.id, position);
        analytics.logStoryTtsPlayed(item.id, contentLanguage.code);
        ttsService.speak(translatedCaption);
      },
    );
  }
}
