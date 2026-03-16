import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/services/shared_preferences_provider.dart';
import '../domain/custom_template.dart';

part 'template_storage_service.g.dart';

/// Key used for storing templates in SharedPreferences
const String _storageKey = 'custom_templates';

/// Service for persisting custom templates to local storage.
/// Uses SharedPreferences for simple key-value storage.
class TemplateStorageService {
  final SharedPreferences _prefs;

  TemplateStorageService(this._prefs);

  /// Loads all saved templates from storage
  List<CustomTemplate> loadTemplates() {
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => CustomTemplate.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If parsing fails, return empty list
      return [];
    }
  }

  /// Saves all templates to storage
  Future<bool> saveTemplates(List<CustomTemplate> templates) async {
    final jsonList = templates.map((t) => t.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    return await _prefs.setString(_storageKey, jsonString);
  }

  /// Adds a new template and persists
  Future<bool> addTemplate(CustomTemplate template) async {
    final templates = loadTemplates();
    templates.add(template);
    return await saveTemplates(templates);
  }

  /// Updates an existing template by ID
  Future<bool> updateTemplate(CustomTemplate template) async {
    final templates = loadTemplates();
    final index = templates.indexWhere((t) => t.id == template.id);
    if (index == -1) {
      return false;
    }
    templates[index] = template;
    return await saveTemplates(templates);
  }

  /// Deletes a template by ID
  Future<bool> deleteTemplate(String templateId) async {
    final templates = loadTemplates();
    templates.removeWhere((t) => t.id == templateId);
    return await saveTemplates(templates);
  }

  /// Gets a single template by ID
  CustomTemplate? getTemplate(String templateId) {
    final templates = loadTemplates();
    try {
      return templates.firstWhere((t) => t.id == templateId);
    } catch (_) {
      return null;
    }
  }
}

/// Provider for the template storage service
@Riverpod(keepAlive: true)
TemplateStorageService templateStorageService(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TemplateStorageService(prefs);
}

