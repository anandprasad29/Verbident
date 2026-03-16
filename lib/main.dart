import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'src/common/services/shared_preferences_provider.dart';

Future<void> main() async {
  // Preserve splash screen until app is ready
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Firebase (skip gracefully on platforms without config, e.g. web)
  try {
    await Firebase.initializeApp();
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    debugPrint('Firebase initialization skipped: $e');
  }

  // Pre-initialize SharedPreferences so settings load synchronously
  final prefs = await SharedPreferences.getInstance();

  // Run non-critical initialization in parallel to reduce startup time
  // These don't need to complete before the app renders
  unawaited(_postInitialization());

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const VerbidentApp(),
    ),
  );
}

/// Non-critical initialization that can run after app starts rendering.
/// This reduces perceived startup time.
Future<void> _postInitialization() async {
  // Disable Crashlytics in debug mode for cleaner logs
  if (kDebugMode && Firebase.apps.isNotEmpty) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }

  // Set preferred orientations (all orientations allowed, so non-blocking is fine)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}
