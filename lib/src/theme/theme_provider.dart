import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../common/services/shared_preferences_provider.dart';

part 'theme_provider.g.dart';

const String _themeModeKey = 'theme_mode';

/// Theme mode options for the app.
enum AppThemeMode {
  light,
  dark,
  system;

  /// Get the Flutter ThemeMode equivalent
  ThemeMode get themeMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Get the icon for this theme mode
  IconData get icon {
    switch (this) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}

/// Notifier that manages the app's theme mode.
/// Persists selection to SharedPreferences.
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  AppThemeMode build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final saved = prefs.getString(_themeModeKey);
    if (saved != null) {
      return AppThemeMode.values.where((m) => m.name == saved).firstOrNull ??
          AppThemeMode.light;
    }
    return AppThemeMode.light;
  }

  /// Set the theme mode
  void setThemeMode(AppThemeMode mode) {
    state = mode;
    ref.read(sharedPreferencesProvider).setString(_themeModeKey, mode.name);
  }

  /// Reset to default theme mode (light).
  void reset() {
    state = AppThemeMode.light;
    ref.read(sharedPreferencesProvider).remove(_themeModeKey);
  }

  /// Toggle between light and dark modes.
  /// - light → dark
  /// - dark → light
  /// - system → dark (switches from auto to explicit dark mode)
  void toggle() {
    state = state == AppThemeMode.dark ? AppThemeMode.light : AppThemeMode.dark;
  }

  /// Cycle through all theme modes
  void cycle() {
    final modes = AppThemeMode.values;
    final currentIndex = modes.indexOf(state);
    state = modes[(currentIndex + 1) % modes.length];
  }
}
