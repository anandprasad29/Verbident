import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';
import '../../../localization/app_localizations.dart';
import '../../../localization/content_language_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/theme_provider.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/app_shell.dart';
import '../../../widgets/language_selector.dart';
import '../../library/services/tts_service.dart';

/// Settings page for app configuration.
/// Includes theme settings, TTS controls, and other preferences.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final showHeader = Responsive.shouldShowPageHeader(context);
    final headerScale = Responsive.getHeaderExpandedScale(context);
    final padding = Responsive.getContentPadding(context);

    return AppShell(
      showHomeButton: true,
      showSettingsButton: false,
      child: Container(
        color: context.appBackground,
        child: CustomScrollView(
          slivers: [
            // Header (desktop only)
            if (showHeader)
              SliverAppBar(
                expandedHeight: AppConstants.headerExpandedHeight,
                pinned: true,
                floating: false,
                backgroundColor: context.appBackground,
                automaticallyImplyLeading: false,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16, top: 8),
                    child: LanguageSelector(compact: true),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(bottom: 16),
                  title: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      l10n?.settingsTitle ?? 'Settings',
                      style: TextStyle(
                        fontFamily: 'InstrumentSans',
                        fontSize: AppConstants.headerFontSize,
                        color: context.appTextPrimary,
                      ),
                    ),
                  ),
                  expandedTitleScale: headerScale,
                ),
              ),
            // Settings content
            SliverPadding(
              padding: padding.copyWith(top: showHeader ? 16 : 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSectionHeader(
                    context,
                    l10n?.settingsAppearance ?? 'Appearance',
                  ),
                  const SizedBox(height: 12),
                  _ThemeSettingsCard(),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    context,
                    l10n?.settingsSpeech ?? 'Speech',
                  ),
                  const SizedBox(height: 12),
                  _TtsSettingsCard(),
                  const SizedBox(height: 32),
                  _RestoreDefaultsButton(),
                  const SizedBox(height: 48),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'InstrumentSans',
        fontSize: 18,
        color: context.appTextPrimary,
      ),
    );
  }
}

/// Card for theme/appearance settings
class _ThemeSettingsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: context.appCardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appCardBorder),
      ),
      child: Column(
        children: [
          // Theme mode selector
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: l10n?.settingsTheme ?? 'Theme',
            subtitle: _getThemeModeLabel(themeMode, l10n),
            trailing: _ThemeModeSelector(
              currentMode: themeMode,
              onChanged: (mode) {
                ref.read(themeModeNotifierProvider.notifier).setThemeMode(mode);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeModeLabel(AppThemeMode mode, AppLocalizations? l10n) {
    switch (mode) {
      case AppThemeMode.light:
        return l10n?.settingsThemeLight ?? 'Light';
      case AppThemeMode.dark:
        return l10n?.settingsThemeDark ?? 'Dark';
      case AppThemeMode.system:
        return l10n?.settingsThemeSystem ?? 'System';
    }
  }
}

/// Theme mode selector widget
class _ThemeModeSelector extends StatelessWidget {
  final AppThemeMode currentMode;
  final ValueChanged<AppThemeMode> onChanged;

  const _ThemeModeSelector({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.appCardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: AppThemeMode.values.map((mode) {
          final isSelected = mode == currentMode;
          return GestureDetector(
            onTap: () => onChanged(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? context.appPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                mode.icon,
                size: 20,
                color: isSelected ? Colors.white : context.appNeutral,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Card for TTS/speech settings
class _TtsSettingsCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_TtsSettingsCard> createState() => _TtsSettingsCardState();
}

class _TtsSettingsCardState extends ConsumerState<_TtsSettingsCard> {
  @override
  Widget build(BuildContext context) {
    final ttsSettings = ref.watch(ttsSettingsNotifierProvider);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: context.appCardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appCardBorder),
      ),
      child: Column(
        children: [
          // Voice type selector
          _SettingsTile(
            icon: Icons.record_voice_over,
            title: l10n?.settingsVoice ?? 'Voice',
            subtitle: _getVoiceTypeLabel(ttsSettings.voiceType, l10n),
            trailing: _VoiceTypeSelector(
              currentType: ttsSettings.voiceType,
              onChanged: (type) {
                ref
                    .read(ttsSettingsNotifierProvider.notifier)
                    .setVoiceType(type);
              },
            ),
          ),
          Divider(height: 1, color: context.appCardBorder),
          // Speech rate slider
          _SettingsTile(
            icon: Icons.speed,
            title: l10n?.settingsSpeechRate ?? 'Speech Rate',
            subtitle: _getSpeechRateLabel(ttsSettings.speechRate, l10n),
            trailing: SizedBox(
              width: 150,
              child: Slider(
                value: ttsSettings.speechRate,
                min: 0.25,
                max: 1.0,
                divisions: 3,
                activeColor: context.appPrimary,
                inactiveColor: context.appCardBorder,
                onChanged: (value) {
                  ref
                      .read(ttsSettingsNotifierProvider.notifier)
                      .setSpeechRate(value);
                },
              ),
            ),
          ),
          Divider(height: 1, color: context.appCardBorder),
          // Test speech button
          _SettingsTile(
            icon: Icons.play_circle_outline,
            title: l10n?.settingsTestSpeech ?? 'Test Speech',
            subtitle: l10n?.settingsTestSpeechHint ?? 'Tap to hear a sample',
            trailing: IconButton(
              icon: Icon(Icons.play_arrow, color: context.appPrimary),
              onPressed: () {
                ref
                    .read(ttsServiceProvider)
                    .speak(
                      l10n?.settingsTestSpeechSample ??
                          'Hello! This is a test.',
                    );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getVoiceTypeLabel(VoiceType type, AppLocalizations? l10n) {
    switch (type) {
      case VoiceType.female:
        return l10n?.settingsVoiceFemale ?? 'Female';
      case VoiceType.male:
        return l10n?.settingsVoiceMale ?? 'Male';
    }
  }

  String _getSpeechRateLabel(double rate, AppLocalizations? l10n) {
    if (rate <= 0.25) return l10n?.settingsSpeechRateSlow ?? 'Slow';
    if (rate <= 0.5) return l10n?.settingsSpeechRateNormal ?? 'Normal';
    if (rate <= 0.75) return l10n?.settingsSpeechRateFast ?? 'Fast';
    return l10n?.settingsSpeechRateVeryFast ?? 'Very Fast';
  }
}

/// Voice type selector widget
class _VoiceTypeSelector extends StatelessWidget {
  final VoiceType currentType;
  final ValueChanged<VoiceType> onChanged;

  const _VoiceTypeSelector({
    required this.currentType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.appCardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: VoiceType.values.map((type) {
          final isSelected = type == currentType;
          return GestureDetector(
            onTap: () => onChanged(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? context.appPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type == VoiceType.female ? Icons.woman : Icons.man,
                    size: 18,
                    color: isSelected ? Colors.white : context.appTextSubtle,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    type == VoiceType.female ? 'F' : 'M',
                    style: TextStyle(
                      fontFamily: 'InstrumentSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected ? Colors.white : context.appTextSubtle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Button to restore all settings to defaults
class _RestoreDefaultsButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: TextButton.icon(
        onPressed: () => _showConfirmDialog(context, ref, l10n),
        icon: Icon(Icons.restore, color: context.appTextSubtle),
        label: Text(
          l10n?.settingsRestoreDefaults ?? 'Restore Defaults',
          style: TextStyle(
            fontFamily: 'InstrumentSans',
            fontSize: 14,
            color: context.appTextSubtle,
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations? l10n,
  ) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.settingsRestoreDefaults ?? 'Restore Defaults'),
        content: Text(
          l10n?.settingsRestoreDefaultsConfirm ??
              'Are you sure you want to restore all settings to their defaults?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(themeModeNotifierProvider.notifier).reset();
              ref.read(ttsSettingsNotifierProvider.notifier).reset();
              ref.read(contentLanguageNotifierProvider.notifier).reset();
              Navigator.of(context).pop();
            },
            child: Text(l10n?.restore ?? 'Restore'),
          ),
        ],
      ),
    );
  }
}

/// Reusable settings tile widget
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.appPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: context.appPrimary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'InstrumentSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: context.appTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'InstrumentSans',
                    fontSize: 13,
                    color: context.appTextSubtle,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
