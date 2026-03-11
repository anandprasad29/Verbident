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
      'en': 'This is the Drill',
      'es': 'Este es el taladro',
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
    // Communication and actions
    'all-done': {
      'en': 'All done',
      'es': 'Todo listo',
    },
    'bite-down': {
      'en': 'Bite down',
      'es': 'Muerde',
    },
    'break': {
      'en': 'Break',
      'es': 'Descanso',
    },
    'close-your-mouth': {
      'en': 'Close your mouth',
      'es': 'Cierra la boca',
    },
    'do-not-swallow': {
      'en': 'Do not swallow',
      'es': 'No tragues',
    },
    'floss': {
      'en': 'Floss',
      'es': 'Hilo dental',
    },
    'hands-on-the-side': {
      'en': 'Hands on the side',
      'es': 'Manos a los lados',
    },
    'hurt': {
      'en': 'Hurt',
      'es': 'Duele',
    },
    'i-dont-like-that': {
      'en': "I don't like that",
      'es': 'No me gusta eso',
    },
    'mad': {
      'en': 'Mad',
      'es': 'Enojado',
    },
    'no': {
      'en': 'No',
      'es': 'No',
    },
    'spit-out': {
      'en': 'Spit out',
      'es': 'Escupe',
    },
    'tired': {
      'en': 'Tired',
      'es': 'Cansado',
    },
    'tongue': {
      'en': 'Tongue',
      'es': 'Lengua',
    },
    'tooth': {
      'en': 'Tooth',
      'es': 'Diente',
    },
    'toothbrush': {
      'en': 'Toothbrush',
      'es': 'Cepillo de dientes',
    },
    'toothpaste': {
      'en': 'Toothpaste',
      'es': 'Pasta de dientes',
    },
    'water': {
      'en': 'Water',
      'es': 'Agua',
    },
    'yes': {
      'en': 'Yes',
      'es': 'Sí',
    },
  };

  /// Category name translations keyed by category ID, then by language code.
  static const Map<String, Map<String, String>> _categoryNames = {
    'actions-and-objects': {
      'en': 'Actions & Objects',
      'es': 'Acciones y objetos',
    },
    'instructional-words': {
      'en': 'Instructional Words',
      'es': 'Palabras instructivas',
    },
    'expression': {
      'en': 'Expression',
      'es': 'Expresión',
    },
    'non-dental': {
      'en': 'Non-Dental',
      'es': 'No dental',
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

  /// Get the translated category name for a given category ID and language.
  /// Falls back to English if translation is not available.
  static String getCategoryName(String categoryId, ContentLanguage language) {
    final translations = _categoryNames[categoryId];
    if (translations == null) {
      return categoryId;
    }
    return translations[language.code] ?? translations['en'] ?? categoryId;
  }

  // Private constructor to prevent instantiation
  ContentTranslations._();
}
