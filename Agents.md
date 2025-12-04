# Verbident - AI Context & Agent Guide

## Project Overview
Verbident is a Flutter application for dental/healthcare management, targeting **iOS and Android** across **mobile phones and tablets**. It focuses on responsive design to support different screen sizes seamlessly.


## Deployment & Release

### Version Numbering (Semantic Versioning)

The app uses **semantic versioning** with build numbers:

```
major.minor.patch+build
  │     │     │    └── Build: Increments every store upload
  │     │     └─────── Patch: Bug fixes, small improvements
  │     └───────────── Minor: New features (backwards compatible)
  └─────────────────── Major: Breaking changes, major redesign
```

#### When to Bump Each Component

| Component | When to Bump | Command | Example |
|-----------|--------------|---------|---------|
| **BUILD** | Every upload to same version | `fastlane bump` | `0.2.0+1 → 0.2.0+2` |
| **PATCH** | Bug fixes, text changes, small improvements | `fastlane bump_patch` | `0.2.0 → 0.2.1` |
| **MINOR** | New features, significant improvements | `fastlane bump_minor` | `0.2.0 → 0.3.0` |
| **MAJOR** | Breaking changes, major redesign, v1.0.0 | `fastlane bump_major` | `0.3.0 → 1.0.0` |

#### Important Rules

1. **After TestFlight/App Store approval**: You MUST bump at least PATCH for new submissions
2. **Build number**: Must be unique per version on each store
3. **Version bumps reset build**: `bump_patch`, `bump_minor`, `bump_major` all reset build to 1

### Fastlane Commands Reference

```bash
# VERSION MANAGEMENT
fastlane version       # Show current version breakdown
fastlane bump          # Increment build number only
fastlane bump_patch    # Bump patch, reset build to 1
fastlane bump_minor    # Bump minor, reset patch & build
fastlane bump_major    # Bump major, reset all

# DEPLOYMENT (Binary Only)
fastlane ios beta      # Build and upload to TestFlight
fastlane android beta  # Build and upload to Play Store Internal

# METADATA MANAGEMENT
fastlane ios metadata       # Upload App Store metadata (descriptions, keywords, etc.)
fastlane android metadata   # Upload Play Store metadata
fastlane ios screenshots    # Instructions for capturing iOS screenshots
fastlane android screenshots # Instructions for capturing Android screenshots

# FULL RELEASE (Binary + Metadata)
fastlane ios release      # Build, upload binary, and update metadata
fastlane android release  # Build, upload binary, and update metadata
```

### Fastlane Configuration

```
fastlane/
├── Appfile              # App identifiers (com.verbident)
├── Fastfile             # Build lanes and version management
├── Deliverfile          # iOS App Store metadata configuration
├── Snapfile             # iOS screenshot capture configuration
├── Screengrabfile       # Android screenshot capture configuration
├── rating_config.json   # App age ratings configuration
├── .gitignore           # Protects API keys
├── AuthKey_*.p8         # iOS App Store Connect API key (gitignored)
├── play-store-key.json  # Android Google Play API key (gitignored)
└── metadata/
    ├── en-US/                    # iOS App Store metadata
    │   ├── name.txt             # App name (30 chars)
    │   ├── subtitle.txt         # App subtitle (30 chars)
    │   ├── description.txt      # Full description (4000 chars)
    │   ├── keywords.txt         # Search keywords (100 chars)
    │   ├── promotional_text.txt # Promo text (170 chars)
    │   ├── release_notes.txt    # What's new (4000 chars)
    │   ├── support_url.txt      # Support URL
    │   └── privacy_url.txt      # Privacy policy URL
    └── android/
        └── en-US/                # Android Play Store metadata
            ├── title.txt        # App name (50 chars)
            ├── short_description.txt  # Short description (80 chars)
            ├── full_description.txt  # Full description (4000 chars)
            └── changelogs/
                └── default.txt  # Release notes
```

### Release Workflow

#### Standard Bug Fix Release
```bash
flutter test                    # Verify tests pass
fastlane bump_patch             # 0.2.0+1 → 0.2.1+1
# Update release notes in metadata files
fastlane ios release            # Upload binary + metadata to TestFlight
fastlane android release        # Upload binary + metadata to Play Store
git add pubspec.yaml fastlane/metadata && git commit -m "chore: release v0.2.1"
```

#### New Feature Release
```bash
flutter test
fastlane bump_minor             # 0.2.1+1 → 0.3.0+1
# Update descriptions and release notes in metadata files
fastlane ios release
fastlane android release
git add pubspec.yaml fastlane/metadata && git commit -m "chore: release v0.3.0"
```

#### Quick Fix (Same Version, New Build)
```bash
flutter test
fastlane bump                   # 0.3.0+1 → 0.3.0+2
fastlane ios beta               # Binary only (no metadata update)
fastlane android beta
git add pubspec.yaml && git commit -m "chore: build 2"
```

#### Update Metadata Only (No New Build)
```bash
# Edit metadata files in fastlane/metadata/
fastlane ios metadata           # Upload metadata to App Store Connect
fastlane android metadata       # Upload metadata to Play Store
git add fastlane/metadata && git commit -m "docs: update app store metadata"
```

### Metadata Management

#### Updating App Store Descriptions

Edit the metadata files directly:

**iOS App Store:**
- `fastlane/metadata/en-US/description.txt` - Full app description
- `fastlane/metadata/en-US/keywords.txt` - Search keywords (comma-separated)
- `fastlane/metadata/en-US/release_notes.txt` - What's new in this version
- `fastlane/metadata/en-US/promotional_text.txt` - Promotional text (can change without new version)

**Android Play Store:**
- `fastlane/metadata/android/en-US/full_description.txt` - Full description
- `fastlane/metadata/android/en-US/short_description.txt` - Short description (80 chars)
- `fastlane/metadata/android/en-US/changelogs/default.txt` - Release notes

After editing, upload:
```bash
fastlane ios metadata      # Upload to App Store Connect
fastlane android metadata  # Upload to Play Store
```

#### Screenshot Capture

**iOS:**
1. Run `fastlane ios screenshots` for instructions
2. Or manually: `flutter run -d 'iPhone 16 Pro Max'`
3. Navigate to each screen and press Cmd+S in Simulator
4. Save screenshots to `fastlane/screenshots/en-US/`
5. Required devices: iPhone 16 Pro Max, iPhone 15 Pro Max, iPhone 8 Plus, iPad Pro 12.9", iPad Pro 11"

**Android:**
1. Run `fastlane android screenshots` for instructions
2. Or manually: `flutter run -d emulator-5554`
3. Navigate to each screen
4. Capture: `adb shell screencap -p /sdcard/screen.png && adb pull /sdcard/screen.png`
5. Save to `fastlane/metadata/android/en-US/images/phoneScreenshots/`

### API Key Setup (One-time)

#### iOS (App Store Connect)
1. [App Store Connect](https://appstoreconnect.apple.com) → Users and Access → Keys
2. Generate API Key with "App Manager" role
3. Save `.p8` file as `fastlane/AuthKey_<KeyID>.p8`
4. Note the Key ID and Issuer ID (configured in Fastfile)

#### Android (Google Play)
1. [Google Play Console](https://play.google.com/console) → Settings → API access
2. Create Service Account with JSON key
3. Save as `fastlane/play-store-key.json`
4. Grant service account access to app

### Store URLs

- **TestFlight/App Store**: https://appstoreconnect.apple.com
- **Google Play Console**: https://play.google.com/console
- **Bundle ID**: `com.verbident`
