# Verbadent - Claude Code Project Guide

## Project Overview
Verbadent is a Flutter dental education app for kids. It teaches children about dental visits through illustrated stories, a library of dental items with text-to-speech captions, and a "Build Your Own" story creator. Targets iOS and Android (phones and tablets) with responsive layouts.

**Current version:** See `pubspec.yaml` (`version:` field)
**Bundle ID:** `com.verbident`

## Build & Run Commands

```bash
# Full code generation pipeline (dental items → build_runner → l10n)
scripts/build.sh

# Individual steps
dart run tool/generate_dental_items.dart          # Regenerate dental items from YAML
dart run build_runner build --delete-conflicting-outputs  # Regenerate Riverpod providers (.g.dart)
flutter gen-l10n                                   # Regenerate localization files

# Development
flutter run                # Run the app
flutter test               # Run all tests
flutter analyze            # Static analysis
dart run flutter_launcher_icons  # Regenerate app icons
```

After changing any `@riverpod`-annotated code, run `build_runner`. After changing `assets/dental_items.yaml`, run the full `scripts/build.sh`.

## Architecture

Feature-based structure under `lib/src/`:

```
lib/src/
├── features/           # Feature modules (each has domain/presentation/services)
│   ├── before_visit/   # "Before Visit" story sequence
│   ├── build_own/      # Custom story builder
│   ├── dashboard/      # Main dashboard / home screen
│   ├── home/           # Home wrapper
│   ├── library/        # Dental items library with TTS
│   └── settings/       # App settings
├── common/
│   ├── data/           # Shared data (dental_items.dart — generated)
│   ├── domain/         # Shared domain models (dental_item.dart)
│   ├── services/       # Analytics service (Firebase)
│   └── widgets/        # Reusable widgets (image_card, story_sequence, tappable_card, etc.)
├── widgets/            # App shell, sidebar, language selector, theme toggle
├── constants/          # AppConstants — breakpoints, grid columns, dimensions
├── localization/       # ARB files (en/es), content language provider, translations
├── routing/            # GoRouter config with deferred loading
├── theme/              # Colors, text styles, theme provider
└── utils/              # Utilities
```

## Key Patterns & Conventions

### Metadata-driven content
- **Source of truth:** `assets/dental_items.yaml` — all dental items (id, image, caption)
- **Generator:** `tool/generate_dental_items.dart` — reads YAML, writes `lib/src/common/data/dental_items.dart`
- **Workflow:** Edit YAML → run `dart run tool/generate_dental_items.dart` → rebuild

### State management — Riverpod with codegen
- Uses `@riverpod` annotations from `riverpod_annotation`
- Generated files: `*.g.dart` (via `build_runner`)
- Key providers: `ContentLanguageNotifier`, `ThemeProvider`, `AnalyticsService`, `BuildOwnProviders`, `TtsService`

### Routing — GoRouter
- Defined in `lib/src/routing/app_router.dart` with `@riverpod`
- Route constants in `lib/src/routing/routes.dart`
- Non-critical pages use **deferred loading** (`deferred as before_visit`)
- Custom fade+slide transitions

### Responsive layout
- Breakpoints in `lib/src/constants/app_constants.dart`: mobile (600), tablet (900), desktop (1200), sidebar (800)
- Grid columns adapt: 2 (mobile) → 3 (tablet) → 5 (desktop)
- Sidebar shows/hides at 800px

### Localization
- Dual system: Flutter l10n (ARB files for UI strings) + `ContentLanguage` enum (per-route content language for TTS)
- ARB files: `lib/src/localization/app_en.arb`, `app_es.arb`
- Content translations: `lib/src/localization/content_translations.dart`

### Services
- **TTS:** `flutter_tts` with lazy initialization (`lib/src/features/library/services/tts_service.dart`)
- **Firebase:** Analytics, Crashlytics, Performance (`lib/src/common/services/analytics_service.dart`)
- **SharedPreferences:** Used for persisting user settings (theme, language)

## Testing

**Always add tests when adding new features or code.** New widgets need widget tests, new providers/models need unit tests, and visual changes need golden test updates. Run `flutter test` before committing.

```bash
flutter test                        # All tests
flutter test test/library_page_test.dart  # Single test file
flutter test --update-goldens       # Update golden files after visual changes
```

Key test files: `library_page_test.dart`, `dashboard_page_test.dart`, `tts_service_test.dart`, `responsive_layout_test.dart`, `story_sequence_test.dart`, `build_own_test.dart`, `sidebar_test.dart`, `category_header_test.dart`

Tests use `SharedPreferences.setMockInitialValues({})` for mock setup. Golden tests are in `test/goldens/`.

## Deployment

See `Agents.md` for full deployment docs including version numbering, fastlane commands, metadata management, screenshot capture, and release workflows.

Quick reference:
```bash
fastlane version          # Show current version
fastlane bump_patch       # Bump patch version
fastlane ios beta         # Build & upload to TestFlight
fastlane android beta     # Build & upload to Play Store Internal
fastlane ios release      # Full release (binary + metadata)
fastlane android release  # Full release (binary + metadata)
```

## Key Files Quick Reference

| File | Purpose |
|------|---------|
| `assets/dental_items.yaml` | Source of truth for all dental items |
| `tool/generate_dental_items.dart` | YAML → Dart code generator |
| `lib/src/common/data/dental_items.dart` | Generated dental items (do not edit) |
| `lib/src/routing/app_router.dart` | All routes and navigation |
| `lib/src/routing/routes.dart` | Route path constants |
| `lib/src/constants/app_constants.dart` | Breakpoints, grid, dimensions |
| `lib/src/widgets/app_shell.dart` | App shell with sidebar |
| `lib/src/theme/app_theme.dart` | Theme definition |
| `lib/src/localization/content_translations.dart` | Per-language content strings |
| `scripts/build.sh` | Full code generation pipeline |
| `Agents.md` | Deployment & release guide |
