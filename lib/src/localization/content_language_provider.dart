import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../common/services/shared_preferences_provider.dart';

part 'content_language_provider.g.dart';

const String _contentLanguageKey = 'content_language';

/// Supported content languages for per-route content localization.
/// This is independent of the app-wide UI locale.
enum ContentLanguage {
  en('en-US', 'English', '🇺🇸'),
  es('es-ES', 'Español', '🇪🇸');

  const ContentLanguage(this.ttsCode, this.displayName, this.flag);

  /// The language code used for text-to-speech (e.g., 'en-US', 'es-ES')
  final String ttsCode;

  /// Human-readable display name
  final String displayName;

  /// Flag emoji for visual identification
  final String flag;

  /// Short language code (e.g., 'en', 'es')
  String get code => name;
}

/// Notifier that manages the currently selected content language.
/// This affects captions and TTS on non-dashboard routes.
/// Persists selection to SharedPreferences.
@riverpod
class ContentLanguageNotifier extends _$ContentLanguageNotifier {
  @override
  ContentLanguage build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final saved = prefs.getString(_contentLanguageKey);
    if (saved != null) {
      return ContentLanguage.values
              .where((l) => l.name == saved)
              .firstOrNull ??
          ContentLanguage.en;
    }
    return ContentLanguage.en;
  }

  /// Reset to default language (English).
  void reset() {
    state = ContentLanguage.en;
    ref.read(sharedPreferencesProvider).remove(_contentLanguageKey);
  }

  /// Update the selected content language.
  void setLanguage(ContentLanguage language) {
    state = language;
    ref
        .read(sharedPreferencesProvider)
        .setString(_contentLanguageKey, language.name);
  }
}
