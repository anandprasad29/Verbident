import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../localization/content_language_provider.dart';
import '../../localization/content_translations.dart';
import '../../theme/app_colors.dart';
import '../domain/dental_item.dart';
import 'speaking_indicator.dart';
import 'tappable_card.dart';

/// A widget displaying dental items in a story sequence with arrow connectors.
///
/// Layout adapts based on screen width:
/// - **Tablet+ (>= 600px):** Horizontal layout with larger items, centered.
/// - **Phone (< 600px):** Vertical layout with downward arrows.
class StorySequence extends StatelessWidget {
  final List<DentalItem> items;
  final void Function(DentalItem item)? onItemTap;

  /// Content language for translations
  final ContentLanguage? contentLanguage;

  /// The text currently being spoken by TTS (for showing speaking indicator)
  final String? speakingText;

  /// Padding around the sequence
  final EdgeInsets padding;

  /// Horizontal padding between arrow and adjacent images
  final double arrowPadding;

  /// Size of the arrow connector (width when horizontal, height when vertical)
  final double arrowSize;

  /// Breakpoint for switching between horizontal and vertical layout
  static const double _tabletBreakpoint = 600.0;

  /// Minimum item size to ensure captions are readable
  static const double _minItemSize = 100.0;

  /// Maximum item size for tablet+ layout
  static const double _maxItemSize = 180.0;

  const StorySequence({
    super.key,
    required this.items,
    this.onItemTap,
    this.contentLanguage,
    this.speakingText,
    this.padding = const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
    this.arrowPadding = 8,
    this.arrowSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final isHorizontal = availableWidth >= _tabletBreakpoint;

          if (isHorizontal) {
            return _buildHorizontalLayout(availableWidth);
          } else {
            return _buildVerticalLayout(availableWidth);
          }
        },
      ),
    );
  }

  /// Horizontal layout for tablet+ screens
  Widget _buildHorizontalLayout(double availableWidth) {
    final itemCount = items.length;
    final arrowCount = itemCount - 1;
    final totalArrowSpace = arrowCount * (arrowSize + arrowPadding * 2);

    var itemSize = (availableWidth - totalArrowSpace) / itemCount;
    itemSize = itemSize.clamp(_minItemSize, _maxItemSize);

    final needsScroll = itemSize <= _minItemSize;

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: needsScroll ? MainAxisSize.min : MainAxisSize.max,
      children: _buildSequenceWidgets(itemSize, isVertical: false),
    );

    if (needsScroll) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: content,
      );
    }

    return content;
  }

  /// Vertical layout for phone screens
  Widget _buildVerticalLayout(double availableWidth) {
    // Use most of available width, capped at max size
    final itemSize = (availableWidth * 0.6).clamp(_minItemSize, _maxItemSize);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildSequenceWidgets(itemSize, isVertical: true),
      ),
    );
  }

  List<Widget> _buildSequenceWidgets(
    double itemSize, {
    required bool isVertical,
  }) {
    final List<Widget> widgets = [];

    for (int i = 0; i < items.length; i++) {
      final caption = contentLanguage != null
          ? ContentTranslations.getCaption(items[i].id, contentLanguage!)
          : items[i].caption;

      final isSpeaking = speakingText != null && speakingText == caption;

      widgets.add(
        _StoryItem(
          key: ValueKey('story_${items[i].id}'),
          item: items[i],
          caption: caption,
          size: itemSize,
          onTap: onItemTap != null ? () => onItemTap!(items[i]) : null,
          isSpeaking: isSpeaking,
        ),
      );

      if (i < items.length - 1) {
        widgets.add(
          _ArrowConnector(
            key: ValueKey('arrow_$i'),
            size: arrowSize,
            padding: arrowPadding,
            imageSize: itemSize,
            isVertical: isVertical,
          ),
        );
      }
    }

    return widgets;
  }
}

/// Individual item in the story sequence with image and caption.
class _StoryItem extends StatelessWidget {
  final DentalItem item;
  final String caption;
  final double size;
  final VoidCallback? onTap;
  final bool isSpeaking;

  const _StoryItem({
    super.key,
    required this.item,
    required this.caption,
    required this.size,
    this.onTap,
    this.isSpeaking = false,
  });

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheSize = (size * pixelRatio).ceil();

    return Semantics(
      label: caption,
      button: true,
      child: TappableCard(
        onTap: onTap,
        child: SizedBox(
          width: size,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSpeaking
                            ? context.appSpeakingIndicator
                            : context.appCardBorder,
                        width: isSpeaking
                            ? AppConstants.cardBorderWidth + 1
                            : AppConstants.cardBorderWidth,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppConstants.cardBorderRadius,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppConstants.cardBorderRadius -
                            AppConstants.cardBorderWidth,
                      ),
                      child: Image.asset(
                        item.imagePath,
                        fit: BoxFit.cover,
                        cacheWidth: cacheSize,
                        cacheHeight: cacheSize,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: context.appBackground,
                            child: Icon(
                              Icons.medical_services_outlined,
                              size: 48,
                              color: context.appCardBorder,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (isSpeaking)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: context.appCardBackground.withValues(
                            alpha: 0.9,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const SpeakingIndicator(size: 18),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                caption,
                style: TextStyle(
                  fontFamily: 'InstrumentSans',
                  fontWeight: FontWeight.bold,
                  fontSize: AppConstants.captionFontSize,
                  color: context.appTextSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Arrow connector between story items — horizontal or vertical.
class _ArrowConnector extends StatelessWidget {
  final double size;
  final double padding;
  final double imageSize;
  final bool isVertical;

  const _ArrowConnector({
    super.key,
    required this.size,
    required this.padding,
    required this.imageSize,
    required this.isVertical,
  });

  @override
  Widget build(BuildContext context) {
    if (isVertical) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: padding),
        child: CustomPaint(
          size: Size(16, size),
          painter: _ArrowPainter(
            color: context.appCardBorder,
            isVertical: true,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: SizedBox(
        width: size,
        child: Padding(
          padding: EdgeInsets.only(top: imageSize / 2 - 8),
          child: CustomPaint(
            size: Size(size, 16),
            painter: _ArrowPainter(color: context.appCardBorder),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for drawing an arrow — right-pointing or down-pointing.
class _ArrowPainter extends CustomPainter {
  final Color color;
  final bool isVertical;

  _ArrowPainter({required this.color, this.isVertical = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (isVertical) {
      final arrowHeadSize = size.width * 0.5;
      final centerX = size.width / 2;

      // Vertical line
      canvas.drawLine(
        Offset(centerX, 0),
        Offset(centerX, size.height - arrowHeadSize),
        paint,
      );

      // Arrow head pointing down
      final arrowPath = Path()
        ..moveTo(centerX - arrowHeadSize, size.height - arrowHeadSize)
        ..lineTo(centerX, size.height)
        ..lineTo(centerX + arrowHeadSize, size.height - arrowHeadSize);

      canvas.drawPath(arrowPath, paint);
    } else {
      final arrowHeadSize = size.height * 0.5;
      final centerY = size.height / 2;

      // Horizontal line
      canvas.drawLine(
        Offset(0, centerY),
        Offset(size.width - arrowHeadSize, centerY),
        paint,
      );

      // Arrow head pointing right
      final arrowPath = Path()
        ..moveTo(size.width - arrowHeadSize, centerY - arrowHeadSize)
        ..lineTo(size.width, centerY)
        ..lineTo(size.width - arrowHeadSize, centerY + arrowHeadSize);

      canvas.drawPath(arrowPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isVertical != isVertical;
}
