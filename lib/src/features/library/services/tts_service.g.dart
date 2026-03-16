// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ttsServiceHash() => r'13f4fec27ae215a230eece3f2e1c056745d1937d';

/// Provider for TtsService with automatic lifecycle management.
/// Uses keepAlive to prevent disposal and re-initialization issues.
/// TTS is NOT pre-initialized - it initializes lazily on first speak().
///
/// Copied from [ttsService].
@ProviderFor(ttsService)
final ttsServiceProvider = Provider<TtsService>.internal(
  ttsService,
  name: r'ttsServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$ttsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TtsServiceRef = ProviderRef<TtsService>;
String _$ttsSpeakingStateHash() => r'8cf51558d87e0cc414b96370ed0029b4199db82f';

/// Provider that exposes the current speaking state as a stream.
/// Updates whenever TTS starts or stops speaking.
///
/// Copied from [ttsSpeakingState].
@ProviderFor(ttsSpeakingState)
final ttsSpeakingStateProvider = StreamProvider<bool>.internal(
  ttsSpeakingState,
  name: r'ttsSpeakingStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ttsSpeakingStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TtsSpeakingStateRef = StreamProviderRef<bool>;
String _$ttsSpeakingTextStreamHash() =>
    r'eba842a721c1463bd05f8cdf85c1bd2c1ac6a1b2';

/// Provider that exposes the currently speaking text as a stream.
/// Returns null when not speaking.
/// Uses stream-based approach instead of invalidateSelf for better performance.
///
/// Copied from [ttsSpeakingTextStream].
@ProviderFor(ttsSpeakingTextStream)
final ttsSpeakingTextStreamProvider = StreamProvider<String?>.internal(
  ttsSpeakingTextStream,
  name: r'ttsSpeakingTextStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ttsSpeakingTextStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TtsSpeakingTextStreamRef = StreamProviderRef<String?>;
String _$ttsSpeakingTextHash() => r'64ee187005b214405a90b685e7f61b2e580b0f3f';

/// Provider that exposes the currently speaking text synchronously.
/// Watches the stream provider for updates.
///
/// Copied from [ttsSpeakingText].
@ProviderFor(ttsSpeakingText)
final ttsSpeakingTextProvider = AutoDisposeProvider<String?>.internal(
  ttsSpeakingText,
  name: r'ttsSpeakingTextProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ttsSpeakingTextHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TtsSpeakingTextRef = AutoDisposeProviderRef<String?>;
String _$ttsSettingsHash() => r'489c99b7400e7a04052f8db4cf8d7e1d44ff2153';

/// Convenience provider for TTS settings
///
/// Copied from [ttsSettings].
@ProviderFor(ttsSettings)
final ttsSettingsProvider = Provider<TtsSettings>.internal(
  ttsSettings,
  name: r'ttsSettingsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$ttsSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TtsSettingsRef = ProviderRef<TtsSettings>;
String _$ttsSettingsNotifierHash() =>
    r'eebcd4c76b5dceba7f3ad526e374d533767997c3';

/// Notifier for TTS settings that automatically applies changes to the TTS service.
/// Persists settings to SharedPreferences.
///
/// Copied from [TtsSettingsNotifier].
@ProviderFor(TtsSettingsNotifier)
final ttsSettingsNotifierProvider =
    NotifierProvider<TtsSettingsNotifier, TtsSettings>.internal(
  TtsSettingsNotifier.new,
  name: r'ttsSettingsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ttsSettingsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TtsSettingsNotifier = Notifier<TtsSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
