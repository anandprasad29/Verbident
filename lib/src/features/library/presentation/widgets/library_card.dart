import 'package:flutter/material.dart';
import '../../../../common/domain/dental_item.dart';
import '../../../../common/widgets/speaking_indicator.dart';
import '../../../../common/widgets/tappable_card.dart';
import '../../../../constants/app_constants.dart';
import '../../../../theme/app_colors.dart';

/// A card widget displaying a library item with image and caption.
/// Tapping the card triggers the onTap callback for TTS playback.
/// Includes visual tap feedback with scale animation.
/// Shows a speaking indicator when TTS is active for this card.
class LibraryCard extends StatelessWidget {
  final DentalItem item;
  final VoidCallback? onTap;

  /// Optional caption override for translations.
  /// If null, uses item.caption.
  final String? caption;

  /// Whether TTS is currently speaking this card's content
  final bool isSpeaking;

  /// Optional border color override for category tinting.
  /// If null, uses the default card border color.
  final Color? borderColor;

  const LibraryCard({
    super.key,
    required this.item,
    this.onTap,
    this.caption,
    this.isSpeaking = false,
    this.borderColor,
  });

  /// The displayed caption (uses override if provided, otherwise item.caption)
  String get displayCaption => caption ?? item.caption;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: displayCaption,
      button: true,
      child: TappableCard(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Square image container with blue border
            AspectRatio(
              aspectRatio: 1.0, // Square
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate optimal cache size based on display size and pixel ratio
                  // This reduces memory usage by ~70-90% for oversized source images
                  final displaySize = constraints.maxWidth;
                  final pixelRatio = MediaQuery.devicePixelRatioOf(context);
                  // Ensure cacheSize is at least 1 (required by Image.asset) or null if constraints are 0
                  final calculatedSize = (displaySize * pixelRatio).ceil();
                  final cacheSize = calculatedSize > 0 ? calculatedSize : null;

                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSpeaking
                                ? context.appSpeakingIndicator
                                : borderColor ?? context.appCardBorder,
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
                            width: double.infinity,
                            height: double.infinity,
                            // Decode image at display size to reduce memory usage
                            cacheWidth: cacheSize,
                            cacheHeight: cacheSize,
                            errorBuilder: (context, error, stackTrace) {
                              // Placeholder for missing images
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
                      // Speaking indicator overlay
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
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Caption text below the image
            Flexible(
              child: Text(
                displayCaption,
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
            ),
          ],
        ),
      ),
    );
  }
}
