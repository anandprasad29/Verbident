import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

/// A wide, rounded banner widget for category section headers.
/// Displays a color-coded background with icon and category name.
class CategoryHeader extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  final bool isSticky;

  const CategoryHeader({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.isSticky = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final color = AppColors.getCategoryColor(categoryId, isDark: isDark);
    final icon = AppColors.getCategoryIcon(categoryId);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.4 : 0.3),
          width: 1,
        ),
        boxShadow: isSticky
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              categoryName,
              style: TextStyle(
                fontFamily: 'InstrumentSans',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
