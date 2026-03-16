import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../common/services/shared_preferences_provider.dart';
import '../../../localization/content_language_provider.dart';

part 'tts_service.g.dart';

const String _ttsSpeechRateKey = 'tts_speech_rate';
const String _ttsVoiceTypeKey = 'tts_voice_type';
const String _ttsVolumeKey = 'tts_volume';

/// Service for text-to-speech functionality.
/// Used to speak library item captions when tapped.
/// Exposes speaking state for UI feedback.
///
/// TTS initialization is completely deferred to first speak() call
/// to prevent blocking the main thread on Android.
class TtsService {
  FlutterTts? _flutterTts;
  String _currentLanguage = 'en-US';

  /// Cached voices by gender for current language
  Map<String, dynamic>? _femaleVoice;
  Map<String, dynamic>? _maleVoice;
  bool _voicesLoaded = false;

  /// Initialization completer to prevent race conditions.
  Completer<void>? _initCompleter;

  /// Whether initialization has been attempted
  bool _initAttempted = false;

  /// Whether TTS is available on this platform/device
  bool _isAvailable = true;
  bool get isAvailable => _isAvailable;

  /// Controller for speaking state changes
  final _speakingController = StreamController<bool>.broadcast();

  /// Stream of speaking state changes
  Stream<bool> get speakingStream => _speakingController.stream;

  /// Controller for speaking text changes
  final _speakingTextController = StreamController<String?>.broadcast();

  /// Stream of speaking text changes
  Stream<String?> get speakingTextStream => _speakingTextController.stream;

  /// Current speaking state
  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  /// The text currently being spoken (null if not speaking)
  String? _currentText;
  String? get currentText => _currentText;

  /// Initialize the TTS engine lazily on first use.
  /// This prevents blocking the main thread during app startup.
  Future<void> _ensureInitialized() async {
    // If already initialized or attempted, return
    if (_initAttempted) {
      // Wait for any in-progress initialization
      if (_initCompleter != null && !_initCompleter!.isCompleted) {
        await _initCompleter!.future;
      }
      return;
    }

    _initAttempted = true;
    _initCompleter = Completer<void>();

    try {
      // Create TTS instance lazily
      _flutterTts = FlutterTts();

      // Set up completion handlers first (these don't block)
      _setupHandlers();

      // Configure TTS with timeout to prevent hangs
      await _configureWithTimeout();

      _isAvailable = true;
    } catch (e) {
      debugPrint('TTS initialization error: $e');
      _isAvailable = false;
    } finally {
      _initCompleter!.complete();
    }
  }

  /// Configure TTS with a timeout to prevent blocking
  Future<void> _configureWithTimeout() async {
    if (_flutterTts == null) return;

    try {
      // Use a short timeout for each operation
      await _flutterTts!
          .setLanguage(_currentLanguage)
          .timeout(
            const Duration(seconds: 2),
            onTimeout: () => debugPrint('TTS setLanguage timed out'),
          );

      await _flutterTts!
          .setSpeechRate(0.5)
          .timeout(
            const Duration(seconds: 1),
            onTimeout: () => debugPrint('TTS setSpeechRate timed out'),
          );

      await _flutterTts!
          .setVolume(1.0)
          .timeout(
            const Duration(seconds: 1),
            onTimeout: () => debugPrint('TTS setVolume timed out'),
          );

      await _flutterTts!
          .setPitch(1.0)
          .timeout(
            const Duration(seconds: 1),
            onTimeout: () => debugPrint('TTS setPitch timed out'),
          );

      // Don't await speak completion - it can block
      _flutterTts!.awaitSpeakCompletion(false);

      // Load available voices for gender selection
      await _loadVoicesForLanguage(_currentLanguage);
    } catch (e) {
      debugPrint('TTS configuration error: $e');
      _isAvailable = false;
    }
  }

  /// Load and cache voices by gender for the given language
  Future<void> _loadVoicesForLanguage(String language) async {
    if (_flutterTts == null) return;

    try {
      final voices = await _flutterTts!.getVoices;
      if (voices == null) return;

      final voiceList = List<Map<String, dynamic>>.from(
        voices.map((v) => Map<String, dynamic>.from(v as Map)),
      );

      // Get the base language code (e.g., "en" from "en-US")
      final langCode = language.split('-').first.toLowerCase();

      // Filter voices for the current language
      final langVoices = voiceList.where((v) {
        final locale = (v['locale'] as String?)?.toLowerCase() ?? '';
        return locale.startsWith(langCode);
      }).toList();

      // Find female and male voices
      _femaleVoice = _findVoiceByGender(langVoices, VoiceType.female);
      _maleVoice = _findVoiceByGender(langVoices, VoiceType.male);
      _voicesLoaded = true;

      debugPrint(
        'TTS voices loaded - Female: ${_femaleVoice?['name']}, Male: ${_maleVoice?['name']}',
      );
    } catch (e) {
      debugPrint('Failed to load TTS voices: $e');
      _voicesLoaded = false;
    }
  }

  /// Find a voice by gender from the voice list
  /// iOS/macOS have a 'gender' field, Android has gender in voice name
  Map<String, dynamic>? _findVoiceByGender(
    List<Map<String, dynamic>> voices,
    VoiceType targetGender,
  ) {
    final genderStr = targetGender == VoiceType.female ? 'female' : 'male';
    final altGenderStr = targetGender == VoiceType.female ? 'woman' : 'man';

    // First try: iOS/macOS style with explicit gender field
    for (final voice in voices) {
      final gender = (voice['gender'] as String?)?.toLowerCase();
      if (gender == genderStr) {
        return voice;
      }
    }

    // Second try: Android style - check voice name for gender indicators
    for (final voice in voices) {
      final name = (voice['name'] as String?)?.toLowerCase() ?? '';
      if (name.contains(genderStr) || name.contains(altGenderStr)) {
        return voice;
      }
    }

    // Third try: Use naming conventions (common female names vs male names)
    // This is a fallback for platforms with unclear gender info
    final femaleNames = [
      'samantha',
      'karen',
      'moira',
      'tessa',
      'fiona',
      'victoria',
      'allison',
    ];
    final maleNames = [
      'daniel',
      'alex',
      'tom',
      'fred',
      'ralph',
      'albert',
      'bruce',
    ];
    final targetNames = targetGender == VoiceType.female
        ? femaleNames
        : maleNames;

    for (final voice in voices) {
      final name = (voice['name'] as String?)?.toLowerCase() ?? '';
      for (final targetName in targetNames) {
        if (name.contains(targetName)) {
          return voice;
        }
      }
    }

    return null;
  }

  /// Set up TTS event handlers (non-blocking)
  void _setupHandlers() {
    if (_flutterTts == null) return;

    _flutterTts!.setStartHandler(() {
      _isSpeaking = true;
      _speakingController.add(true);
      _speakingTextController.add(_currentText);
    });

    _flutterTts!.setCompletionHandler(() {
      _isSpeaking = false;
      _currentText = null;
      _speakingController.add(false);
      _speakingTextController.add(null);
    });

    _flutterTts!.setCancelHandler(() {
      _isSpeaking = false;
      _currentText = null;
      _speakingController.add(false);
      _speakingTextController.add(null);
    });

    _flutterTts!.setErrorHandler((error) {
      debugPrint('TTS error: $error');
      _isSpeaking = false;
      _currentText = null;
      _speakingController.add(false);
      _speakingTextController.add(null);
    });
  }

  /// Pre-warm the TTS engine without speaking.
  /// Call this early (e.g., when a TTS-enabled page loads) to eliminate
  /// first-speak delay. This runs initialization in the background.
  void warmUp() {
    // Fire and forget - don't block the caller
    _ensureInitialized().catchError((e) {
      debugPrint('TTS warmUp error: $e');
    });
  }

  /// Set the TTS language based on ContentLanguage.
  /// Non-blocking - fires and forgets if TTS not ready.
  void setLanguage(ContentLanguage language) {
    final newLanguage = language.ttsCode;
    final languageChanged = _currentLanguage != newLanguage;
    _currentLanguage = newLanguage;

    // If TTS is already initialized, update the language
    if (_flutterTts != null && _isAvailable) {
      _flutterTts!.setLanguage(_currentLanguage).catchError((e) {
        debugPrint('Failed to set TTS language: $e');
      });

      // Reload voices for the new language
      if (languageChanged) {
        _voicesLoaded = false;
        _loadVoicesForLanguage(_currentLanguage);
      }
    }
  }

  /// Speak the given text.
  /// Non-blocking - skips if TTS is still initializing to prevent UI freezes.
  /// Returns immediately while speech plays.
  Future<void> speak(String text) async {
    // If initialization is in progress, skip this speak request
    // This prevents queuing up multiple speaks during slow TTS init
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      debugPrint('TTS still initializing - skipping speak');
      return;
    }

    // If not initialized yet, start initialization but don't block
    if (!_initAttempted) {
      warmUp(); // Fire and forget
      debugPrint('TTS not ready - skipping speak, warming up');
      return;
    }

    if (!_isAvailable || _flutterTts == null) {
      debugPrint('TTS not available - skipping speak');
      return;
    }

    // Stop any current speech before starting new one
    if (_isSpeaking) {
      await _flutterTts!.stop();
    }

    _currentText = text;
    _speakingTextController.add(text);

    // Fire and forget - don't await speak
    _flutterTts!.speak(text).catchError((e) {
      debugPrint('TTS speak error: $e');
      _isSpeaking = false;
      _currentText = null;
      _speakingController.add(false);
      _speakingTextController.add(null);
    });
  }

  /// Stop any ongoing speech.
  Future<void> stop() async {
    if (_flutterTts != null) {
      try {
        await _flutterTts!.stop();
      } catch (e) {
        debugPrint('TTS stop error: $e');
      }
    }
    _isSpeaking = false;
    _currentText = null;
    _speakingController.add(false);
    _speakingTextController.add(null);
  }

  /// Update TTS settings (speech rate, voice type, volume).
  /// Non-blocking - fires and forgets if TTS not ready.
  void updateSettings(TtsSettings settings) {
    if (_flutterTts == null || !_isAvailable) return;

    _flutterTts!.setSpeechRate(settings.speechRate).catchError((e) {
      debugPrint('Failed to set TTS speech rate: $e');
    });
    _flutterTts!.setVolume(settings.volume).catchError((e) {
      debugPrint('Failed to set TTS volume: $e');
    });

    // Try to use actual voice for the selected gender
    final targetVoice = settings.voiceType == VoiceType.female
        ? _femaleVoice
        : _maleVoice;

    if (targetVoice != null && _voicesLoaded) {
      // Use actual voice - reset pitch to neutral
      _flutterTts!
          .setVoice({
            'name': targetVoice['name'],
            'locale': targetVoice['locale'],
          })
          .catchError((e) {
            debugPrint('Failed to set TTS voice: $e');
          });
      _flutterTts!.setPitch(1.0).catchError((e) {
        debugPrint('Failed to set TTS pitch: $e');
      });
      debugPrint('TTS using actual voice: ${targetVoice['name']}');
    } else {
      // Fallback: Use pitch to simulate voice gender
      // Female: higher pitch (1.2), Male: lower pitch (0.8)
      final pitch = settings.voiceType == VoiceType.female ? 1.2 : 0.8;
      _flutterTts!.setPitch(pitch).catchError((e) {
        debugPrint('Failed to set TTS pitch: $e');
      });
      debugPrint('TTS using pitch fallback: $pitch');
    }
  }

  /// Dispose of TTS resources.
  void dispose() {
    if (_flutterTts != null) {
      try {
        _flutterTts!.stop();
      } catch (_) {}
    }
    _speakingController.close();
    _speakingTextController.close();
  }
}

/// Provider for TtsService with automatic lifecycle management.
/// Uses keepAlive to prevent disposal and re-initialization issues.
/// TTS is NOT pre-initialized - it initializes lazily on first speak().
@Riverpod(keepAlive: true)
TtsService ttsService(Ref ref) {
  final service = TtsService();
  // DO NOT pre-initialize TTS here - it blocks the main thread on Android
  // TTS will initialize lazily on first speak() call
  ref.onDispose(() => service.dispose());
  return service;
}

/// Provider that exposes the current speaking state as a stream.
/// Updates whenever TTS starts or stops speaking.
@Riverpod(keepAlive: true)
Stream<bool> ttsSpeakingState(Ref ref) {
  final ttsService = ref.watch(ttsServiceProvider);
  return ttsService.speakingStream;
}

/// Provider that exposes the currently speaking text as a stream.
/// Returns null when not speaking.
/// Uses stream-based approach instead of invalidateSelf for better performance.
@Riverpod(keepAlive: true)
Stream<String?> ttsSpeakingTextStream(Ref ref) {
  final ttsService = ref.watch(ttsServiceProvider);
  return ttsService.speakingTextStream;
}

/// Provider that exposes the currently speaking text synchronously.
/// Watches the stream provider for updates.
@riverpod
String? ttsSpeakingText(Ref ref) {
  final streamAsync = ref.watch(ttsSpeakingTextStreamProvider);
  return streamAsync.valueOrNull;
}

/// Voice type enum for simplified voice selection
enum VoiceType {
  female,
  male;

  String get label {
    switch (this) {
      case VoiceType.female:
        return 'Female';
      case VoiceType.male:
        return 'Male';
    }
  }
}

/// TTS settings data class
class TtsSettings {
  final double speechRate;
  final double volume;
  final VoiceType voiceType;

  const TtsSettings({
    this.speechRate = 0.5,
    this.volume = 1.0,
    this.voiceType = VoiceType.female,
  });

  TtsSettings copyWith({
    double? speechRate,
    double? volume,
    VoiceType? voiceType,
  }) {
    return TtsSettings(
      speechRate: speechRate ?? this.speechRate,
      volume: volume ?? this.volume,
      voiceType: voiceType ?? this.voiceType,
    );
  }
}

/// Notifier for TTS settings that automatically applies changes to the TTS service.
/// Persists settings to SharedPreferences.
@Riverpod(keepAlive: true)
class TtsSettingsNotifier extends _$TtsSettingsNotifier {
  @override
  TtsSettings build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final speechRate = prefs.getDouble(_ttsSpeechRateKey);
    final volume = prefs.getDouble(_ttsVolumeKey);
    final voiceTypeName = prefs.getString(_ttsVoiceTypeKey);
    final voiceType = voiceTypeName != null
        ? VoiceType.values.where((v) => v.name == voiceTypeName).firstOrNull
        : null;
    return TtsSettings(
      speechRate: speechRate ?? 0.5,
      volume: volume ?? 1.0,
      voiceType: voiceType ?? VoiceType.female,
    );
  }

  /// Reset to default TTS settings.
  void reset() {
    state = const TtsSettings();
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.remove(_ttsSpeechRateKey);
    prefs.remove(_ttsVoiceTypeKey);
    prefs.remove(_ttsVolumeKey);
    _applyToTtsService();
  }

  void setSpeechRate(double rate) {
    state = state.copyWith(speechRate: rate);
    ref.read(sharedPreferencesProvider).setDouble(_ttsSpeechRateKey, rate);
    _applyToTtsService();
  }

  void setVoiceType(VoiceType voiceType) {
    state = state.copyWith(voiceType: voiceType);
    ref
        .read(sharedPreferencesProvider)
        .setString(_ttsVoiceTypeKey, voiceType.name);
    _applyToTtsService();
  }

  void setVolume(double volume) {
    state = state.copyWith(volume: volume);
    ref.read(sharedPreferencesProvider).setDouble(_ttsVolumeKey, volume);
    _applyToTtsService();
  }

  void _applyToTtsService() {
    final ttsService = ref.read(ttsServiceProvider);
    ttsService.updateSettings(state);
  }
}

/// Convenience provider for TTS settings
@Riverpod(keepAlive: true)
TtsSettings ttsSettings(Ref ref) {
  return ref.watch(ttsSettingsNotifierProvider);
}
