import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verbident/src/common/services/shared_preferences_provider.dart';
import 'package:flutter/services.dart';
import 'package:verbident/src/features/library/services/tts_service.dart';
import 'package:verbident/src/localization/content_language_provider.dart';
import 'package:verbident/src/theme/theme_provider.dart';

/// Creates a [ProviderContainer] with SharedPreferences pre-initialized
/// from the given [values].
ProviderContainer createContainer([Map<String, Object> values = const {}]) {
  SharedPreferences.setMockInitialValues(values);
  final prefs = SharedPreferences.getInstance();
  // SharedPreferences.getInstance() returns synchronously in test when
  // setMockInitialValues has been called.
  late SharedPreferences syncPrefs;
  prefs.then((p) => syncPrefs = p);

  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) => syncPrefs),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeModeNotifier persistence', () {
    test('defaults to light when no saved value', () {
      final container = createContainer();
      final theme = container.read(themeModeNotifierProvider);
      expect(theme, AppThemeMode.light);
      container.dispose();
    });

    test('loads saved theme mode on startup', () {
      final container = createContainer({'theme_mode': 'dark'});
      final theme = container.read(themeModeNotifierProvider);
      expect(theme, AppThemeMode.dark);
      container.dispose();
    });

    test('loads system theme mode on startup', () {
      final container = createContainer({'theme_mode': 'system'});
      final theme = container.read(themeModeNotifierProvider);
      expect(theme, AppThemeMode.system);
      container.dispose();
    });

    test('falls back to light for invalid saved value', () {
      final container = createContainer({'theme_mode': 'invalid'});
      final theme = container.read(themeModeNotifierProvider);
      expect(theme, AppThemeMode.light);
      container.dispose();
    });

    test('persists theme mode when changed', () async {
      final container = createContainer();
      final notifier = container.read(themeModeNotifierProvider.notifier);

      notifier.setThemeMode(AppThemeMode.dark);

      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getString('theme_mode'), 'dark');
      container.dispose();
    });

    test('persists across notifier reads', () async {
      final container = createContainer();
      container
          .read(themeModeNotifierProvider.notifier)
          .setThemeMode(AppThemeMode.system);

      // Read the prefs directly to confirm it was written
      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getString('theme_mode'), 'system');
      container.dispose();
    });
  });

  group('ContentLanguageNotifier persistence', () {
    test('defaults to English when no saved value', () {
      final container = createContainer();
      final lang = container.read(contentLanguageNotifierProvider);
      expect(lang, ContentLanguage.en);
      container.dispose();
    });

    test('loads saved language on startup', () {
      final container = createContainer({'content_language': 'es'});
      final lang = container.read(contentLanguageNotifierProvider);
      expect(lang, ContentLanguage.es);
      container.dispose();
    });

    test('falls back to English for invalid saved value', () {
      final container = createContainer({'content_language': 'invalid'});
      final lang = container.read(contentLanguageNotifierProvider);
      expect(lang, ContentLanguage.en);
      container.dispose();
    });

    test('persists language when changed', () {
      final container = createContainer();
      container
          .read(contentLanguageNotifierProvider.notifier)
          .setLanguage(ContentLanguage.es);

      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getString('content_language'), 'es');
      container.dispose();
    });
  });

  group('TtsSettingsNotifier persistence', () {
    test('defaults when no saved values', () {
      final container = createContainer();
      final settings = container.read(ttsSettingsNotifierProvider);
      expect(settings.speechRate, 0.5);
      expect(settings.volume, 1.0);
      expect(settings.voiceType, VoiceType.female);
      container.dispose();
    });

    test('loads saved speech rate', () {
      final container = createContainer({'tts_speech_rate': 0.75});
      final settings = container.read(ttsSettingsNotifierProvider);
      expect(settings.speechRate, 0.75);
      container.dispose();
    });

    test('loads saved voice type', () {
      final container = createContainer({'tts_voice_type': 'male'});
      final settings = container.read(ttsSettingsNotifierProvider);
      expect(settings.voiceType, VoiceType.male);
      container.dispose();
    });

    test('loads saved volume', () {
      final container = createContainer({'tts_volume': 0.8});
      final settings = container.read(ttsSettingsNotifierProvider);
      expect(settings.volume, 0.8);
      container.dispose();
    });

    test('loads all saved values together', () {
      final container = createContainer({
        'tts_speech_rate': 0.25,
        'tts_voice_type': 'male',
        'tts_volume': 0.6,
      });
      final settings = container.read(ttsSettingsNotifierProvider);
      expect(settings.speechRate, 0.25);
      expect(settings.voiceType, VoiceType.male);
      expect(settings.volume, 0.6);
      container.dispose();
    });

    test('falls back to defaults for invalid voice type', () {
      final container = createContainer({'tts_voice_type': 'invalid'});
      final settings = container.read(ttsSettingsNotifierProvider);
      expect(settings.voiceType, VoiceType.female);
      container.dispose();
    });

    test('persists speech rate when changed', () {
      final container = createContainer();
      container
          .read(ttsSettingsNotifierProvider.notifier)
          .setSpeechRate(0.75);

      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getDouble('tts_speech_rate'), 0.75);
      container.dispose();
    });

    test('persists voice type when changed', () {
      final container = createContainer();
      container
          .read(ttsSettingsNotifierProvider.notifier)
          .setVoiceType(VoiceType.male);

      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getString('tts_voice_type'), 'male');
      container.dispose();
    });

    test('persists volume when changed', () {
      final container = createContainer();
      container
          .read(ttsSettingsNotifierProvider.notifier)
          .setVolume(0.6);

      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getDouble('tts_volume'), 0.6);
      container.dispose();
    });
  });

  group('Reset to defaults', () {
    setUp(() {
      // Mock flutter_tts platform channel so TtsService.updateSettings works
      const channel = MethodChannel('flutter_tts');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return 1;
      });
    });

    tearDown(() {
      const channel = MethodChannel('flutter_tts');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('theme reset restores default and clears storage', () {
      final container = createContainer({'theme_mode': 'dark'});
      expect(container.read(themeModeNotifierProvider), AppThemeMode.dark);

      container.read(themeModeNotifierProvider.notifier).reset();

      expect(container.read(themeModeNotifierProvider), AppThemeMode.light);
      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getString('theme_mode'), isNull);
      container.dispose();
    });

    test('language reset restores default and clears storage', () {
      final container = createContainer({'content_language': 'es'});
      expect(
          container.read(contentLanguageNotifierProvider), ContentLanguage.es);

      container.read(contentLanguageNotifierProvider.notifier).reset();

      expect(
          container.read(contentLanguageNotifierProvider), ContentLanguage.en);
      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getString('content_language'), isNull);
      container.dispose();
    });

    test('TTS settings reset restores defaults and clears storage', () {
      final container = createContainer({
        'tts_speech_rate': 0.25,
        'tts_voice_type': 'male',
        'tts_volume': 0.6,
      });
      final settings = container.read(ttsSettingsNotifierProvider);
      expect(settings.speechRate, 0.25);
      expect(settings.voiceType, VoiceType.male);
      expect(settings.volume, 0.6);

      container.read(ttsSettingsNotifierProvider.notifier).reset();

      final resetSettings = container.read(ttsSettingsNotifierProvider);
      expect(resetSettings.speechRate, 0.5);
      expect(resetSettings.voiceType, VoiceType.female);
      expect(resetSettings.volume, 1.0);

      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getDouble('tts_speech_rate'), isNull);
      expect(prefs.getString('tts_voice_type'), isNull);
      expect(prefs.getDouble('tts_volume'), isNull);
      container.dispose();
    });
  });
}
