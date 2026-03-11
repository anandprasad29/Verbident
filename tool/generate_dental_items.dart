#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'package:yaml/yaml.dart';

/// Generates lib/src/common/data/dental_items.dart from assets/dental_items.yaml
///
/// Usage: dart run tool/generate_dental_items.dart
void main() async {
  print('🦷 Generating dental_items.dart from metadata...');

  // Read the YAML file
  final yamlFile = File('assets/dental_items.yaml');
  if (!yamlFile.existsSync()) {
    print('❌ Error: assets/dental_items.yaml not found');
    exit(1);
  }

  final yamlContent = await yamlFile.readAsString();
  final dynamic yaml = loadYaml(yamlContent);

  // Parse dental items
  final items = <Map<String, String>>[];
  for (final item in yaml['dental_items'] as YamlList) {
    items.add({
      'id': item['id'] as String,
      'image': item['image'] as String,
      'caption': item['caption'] as String,
      'category': (item['category'] as String?) ?? '',
    });
  }

  // Parse category order
  final categories = (yaml['categories'] as YamlList?)
          ?.map((e) => e as String)
          .toList() ??
      <String>[];

  // Parse during visit items IDs
  final duringVisitItems = (yaml['during_visit_items'] as YamlList)
      .map((e) => e as String)
      .toList();

  // Generate the Dart code
  final buffer = StringBuffer();

  // File header
  buffer.writeln("// GENERATED CODE - DO NOT EDIT BY HAND");
  buffer.writeln("// Generated from assets/dental_items.yaml");
  buffer.writeln("// To regenerate, run: dart run tool/generate_dental_items.dart");
  buffer.writeln();
  buffer.writeln("import '../domain/dental_item.dart';");
  buffer.writeln();

  // Class header
  buffer.writeln("/// Central repository of all dental items used across the app.");
  buffer.writeln("/// This is the single source of truth for dental content.");
  buffer.writeln("/// All features (Library, Before Visit, Build Your Own, etc.) reference these items.");
  buffer.writeln("///");
  buffer.writeln("/// To add or modify items, edit assets/dental_items.yaml and regenerate this file.");
  buffer.writeln("class DentalItems {");

  // Generate all items list
  buffer.writeln("  /// All dental items available in the app.");
  buffer.writeln("  /// Images are stored in `assets/images/library/`.");
  buffer.writeln("  static const List<DentalItem> all = [");

  for (final item in items) {
    buffer.writeln("    DentalItem(");
    buffer.writeln("      id: '${item['id']}',");
    buffer.writeln("      imagePath: 'assets/images/library/${item['image']}',");
    buffer.writeln("      caption: ${_escapeDartString(item['caption']!)},");
    buffer.writeln("      category: '${item['category']}',");
    buffer.writeln("    ),");
  }

  buffer.writeln("  ];");
  buffer.writeln();

  // Generate ordered category list
  buffer.writeln("  /// Ordered list of category IDs for display.");
  buffer.writeln("  static const List<String> categories = [");
  for (final cat in categories) {
    buffer.writeln("    '$cat',");
  }
  buffer.writeln("  ];");
  buffer.writeln();

  // Generate during visit items IDs
  buffer.writeln("  /// IDs for the \"During Visit\" items grid.");
  buffer.writeln("  /// These items are shown as a flat image grid.");
  buffer.writeln("  static const List<String> duringVisitIds = [");
  for (final id in duringVisitItems) {
    buffer.writeln("    '$id',");
  }
  buffer.writeln("  ];");
  buffer.writeln();

  // Generate lookup map and helper methods
  buffer.writeln("  /// Lookup map for fast ID-based access.");
  buffer.writeln("  static final Map<String, DentalItem> _itemMap = {");
  buffer.writeln("    for (var item in all) item.id: item,");
  buffer.writeln("  };");
  buffer.writeln();

  buffer.writeln("  /// Get items by their IDs (preserves order).");
  buffer.writeln("  /// Returns only items that exist in the catalog.");
  buffer.writeln("  static List<DentalItem> getByIds(List<String> ids) {");
  buffer.writeln("    return ids");
  buffer.writeln("        .where((id) => _itemMap.containsKey(id))");
  buffer.writeln("        .map((id) => _itemMap[id]!)");
  buffer.writeln("        .toList();");
  buffer.writeln("  }");
  buffer.writeln();

  buffer.writeln("  /// Get a single item by ID.");
  buffer.writeln("  /// Returns null if not found.");
  buffer.writeln("  static DentalItem? getById(String id) => _itemMap[id];");
  buffer.writeln();

  buffer.writeln("  /// Get items filtered by category.");
  buffer.writeln("  static List<DentalItem> getByCategory(String category) {");
  buffer.writeln("    return all.where((item) => item.category == category).toList();");
  buffer.writeln("  }");
  buffer.writeln();

  buffer.writeln("  /// Get items for the During Visit items grid.");
  buffer.writeln("  static List<DentalItem> get duringVisitItems =>");
  buffer.writeln("      getByIds(duringVisitIds);");
  buffer.writeln();

  // Private constructor
  buffer.writeln("  // Private constructor to prevent instantiation");
  buffer.writeln("  DentalItems._();");
  buffer.writeln("}");
  buffer.writeln();

  // Write the generated file
  final outputFile = File('lib/src/common/data/dental_items.dart');
  await outputFile.writeAsString(buffer.toString());

  print('✅ Generated ${items.length} dental items');
  print('✅ Categories: ${categories.length} (${categories.join(', ')})');
  print('✅ During Visit: ${duringVisitItems.length} items');
  print('✅ Output: ${outputFile.path}');
}

/// Escape a string for Dart code generation
String _escapeDartString(String str) {
  // Check if string contains single quotes
  if (str.contains("'") && !str.contains('"')) {
    // Use double quotes if string has single quotes
    return '"$str"';
  } else {
    // Use single quotes and escape any single quotes inside
    return "'${str.replaceAll("'", r"\'")}'";
  }
}
