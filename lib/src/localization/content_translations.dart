import 'content_language_provider.dart';

/// Provides translations for content captions based on item ID.
/// This keeps the LibraryItem model unchanged while supporting multiple languages.
class ContentTranslations {
  /// Caption translations keyed by item ID, then by language code.
  static const Map<String, Map<String, String>> _captions = {
    // Dental visit scenarios
    'dentist-chair': {
      'en': "This is the dentist's chair",
      'es': 'Esta es la silla del dentista',
    },
    'dentist-mask': {
      'en': 'The dentist wears a mask',
      'es': 'El dentista usa una máscara',
    },
    'dentist-gloves': {
      'en': 'The dentist wears a glove',
      'es': 'El dentista usa guantes',
    },
    'bright-light': {
      'en': 'The dentist has a bright light',
      'es': 'El dentista tiene una luz brillante',
    },
    'count-teeth': {
      'en': 'The dentist will count your teeth',
      'es': 'El dentista contará tus dientes',
    },
    // Dental tools and actions
    'dental-mirror': {
      'en': 'This is a mirror',
      'es': 'Este es un espejo',
    },
    'dental-drill': {
      'en': "This is the dentist's drill",
      'es': 'Este es el taladro del dentista',
    },
    'suction': {
      'en': 'This is a suction',
      'es': 'Esta es una succión',
    },
    'open-mouth': {
      'en': 'Open your mouth',
      'es': 'Abre la boca',
    },
    'stop': {
      'en': 'Stop',
      'es': 'Para',
    },
  };

  /// Get the translated caption for a given item ID and language.
  /// Falls back to English if translation is not available.
  static String getCaption(String id, ContentLanguage language) {
    final translations = _captions[id];
    if (translations == null) {
      return '';
    }
    return translations[language.code] ?? translations['en'] ?? '';
  }

  // Private constructor to prevent instantiation
  ContentTranslations._();
}







