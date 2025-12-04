import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/features/library/services/tts_service.dart';
import 'src/localization/app_localizations.dart';
import 'src/routing/app_router.dart';
import 'src/theme/app_theme.dart';
import 'src/theme/theme_provider.dart';

class VerbidentApp extends ConsumerStatefulWidget {
  const VerbidentApp({super.key});

  @override
  ConsumerState<VerbidentApp> createState() => _VerbidentAppState();
}

class _VerbidentAppState extends ConsumerState<VerbidentApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Remove splash screen after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _initialized = true;

        // Pre-warm TTS engine at app start since it's the primary feature
        // This runs asynchronously and doesn't block the UI
        ref.read(ttsServiceProvider).warmUp();

        // Small delay to ensure smooth transition
        Future.delayed(const Duration(milliseconds: 100), () {
          FlutterNativeSplash.remove();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);

    return MaterialApp.router(
      routerConfig: goRouter,
      onGenerateTitle: (context) => 'Verbident',
      theme: AppTheme.staticLightTheme,
      darkTheme: AppTheme.staticDarkTheme,
      themeMode: themeMode.themeMode,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
