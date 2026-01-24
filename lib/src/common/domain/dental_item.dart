/// Data model for a dental-related item with image and caption.
/// Used across Library, Before Visit, During Visit, and other dental content pages.
class DentalItem {
  final String id;
  final String imagePath;
  final String caption;

  const DentalItem({
    required this.id,
    required this.imagePath,
    required this.caption,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DentalItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          imagePath == other.imagePath &&
          caption == other.caption;

  @override
  int get hashCode => id.hashCode ^ imagePath.hashCode ^ caption.hashCode;
}







