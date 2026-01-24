import 'dart:convert';

/// Data model for a user-created custom template.
/// Contains a name and list of selected dental item IDs.
class CustomTemplate {
  final String id;
  final String name;
  final List<String> selectedItemIds;
  final DateTime createdAt;

  const CustomTemplate({
    required this.id,
    required this.name,
    required this.selectedItemIds,
    required this.createdAt,
  });

  /// Creates a copy with optional field overrides
  CustomTemplate copyWith({
    String? id,
    String? name,
    List<String>? selectedItemIds,
    DateTime? createdAt,
  }) {
    return CustomTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts to JSON map for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'selectedItemIds': selectedItemIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates from JSON map
  factory CustomTemplate.fromJson(Map<String, dynamic> json) {
    return CustomTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      selectedItemIds: List<String>.from(json['selectedItemIds'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Converts to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Creates from JSON string
  factory CustomTemplate.fromJsonString(String jsonString) {
    return CustomTemplate.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomTemplate &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          _listEquals(selectedItemIds, other.selectedItemIds) &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      selectedItemIds.hashCode ^
      createdAt.hashCode;

  /// Helper for list equality
  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'CustomTemplate(id: $id, name: $name, items: ${selectedItemIds.length})';
}




