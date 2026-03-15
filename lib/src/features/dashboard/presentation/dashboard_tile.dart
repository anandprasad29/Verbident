import 'package:flutter/material.dart';
import '../../../common/widgets/tappable_card.dart';
import '../../../constants/app_constants.dart';

/// A single feature tile for the dashboard hub.
/// Displays an icon and label on a colored background with tap animation.
class DashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const DashboardTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TappableCard(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'InstrumentSans',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
