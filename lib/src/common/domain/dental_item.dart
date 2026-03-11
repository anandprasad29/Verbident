/// Data model for a dental-related item with image and caption.
/// Used across Library, Before Visit, During Visit, and other dental content pages.
class DentalItem {
  final String id;
  final String imagePath;
  final String caption;
  final String category;

  const DentalItem({
    required this.id,
    required this.imagePath,
    required this.caption,
    this.category = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DentalItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          imagePath == other.imagePath &&
          caption == other.caption &&
          category == other.category;

  @override
  int get hashCode =>
      id.hashCode ^ imagePath.hashCode ^ caption.hashCode ^ category.hashCode;
}
