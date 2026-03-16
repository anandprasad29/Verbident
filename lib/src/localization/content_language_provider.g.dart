// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_language_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contentLanguageNotifierHash() =>
    r'6a89b7c4d908ef427f4f1e998fbefc6d5b187994';

/// Notifier that manages the currently selected content language.
/// This affects captions and TTS on non-dashboard routes.
/// Persists selection to SharedPreferences.
///
/// Copied from [ContentLanguageNotifier].
@ProviderFor(ContentLanguageNotifier)
final contentLanguageNotifierProvider = AutoDisposeNotifierProvider<
    ContentLanguageNotifier, ContentLanguage>.internal(
  ContentLanguageNotifier.new,
  name: r'contentLanguageNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contentLanguageNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ContentLanguageNotifier = AutoDisposeNotifier<ContentLanguage>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
