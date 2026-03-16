// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'build_own_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$customTemplatesNotifierHash() =>
    r'08d70805dbc588065b365c2e314bd4dfbdbaeecb';

/// State notifier for managing the list of custom templates.
/// Persists to local storage via TemplateStorageService.
///
/// Copied from [CustomTemplatesNotifier].
@ProviderFor(CustomTemplatesNotifier)
final customTemplatesNotifierProvider =
    NotifierProvider<CustomTemplatesNotifier, List<CustomTemplate>>.internal(
  CustomTemplatesNotifier.new,
  name: r'customTemplatesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$customTemplatesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CustomTemplatesNotifier = Notifier<List<CustomTemplate>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
