# Verbident

Flutter application for Verbident deployed on **iOS and Android** across **mobile phones and tablets**.


## Deployment

The app uses **Fastlane** for automated deployments to TestFlight and Google Play.

### Prerequisites

- [Fastlane](https://fastlane.tools/) installed (`brew install fastlane`)
- API keys configured in `fastlane/` folder (gitignored for security)

### Version Format

```
major.minor.patch+build
  │     │     │    └── Build number (increments every upload)
  │     │     └─────── Patch (bug fixes, small changes)
  │     └───────────── Minor (new features)
  └─────────────────── Major (breaking changes)

Example: 1.2.3+45
```

### When to Bump What

| Component | When to Bump | Example |
|-----------|--------------|---------|
| **MAJOR** | Breaking changes, major redesign | `0.2.0 → 1.0.0` |
| **MINOR** | New features, significant improvements | `0.2.0 → 0.3.0` |
| **PATCH** | Bug fixes, small improvements | `0.2.0 → 0.2.1` |
| **BUILD** | Every TestFlight/Play Store upload | `0.2.0+1 → 0.2.0+2` |

> ⚠️ **Important**: Once a version is approved on TestFlight/App Store, you MUST bump at least the PATCH version for new submissions.

### Version Commands

```bash
# Show current version
fastlane version

# Bump build number only (for multiple uploads of same version)
fastlane bump              # 0.2.0+1 → 0.2.0+2

# Bump patch (bug fixes) - resets build to 1
fastlane bump_patch        # 0.2.0+2 → 0.2.1+1

# Bump minor (new features) - resets patch and build
fastlane bump_minor        # 0.2.1+1 → 0.3.0+1

# Bump major (breaking changes) - resets all
fastlane bump_major        # 0.3.0+1 → 1.0.0+1
```

### Deploy Commands

```bash
# Deploy to iOS TestFlight (binary only)
fastlane ios beta

# Deploy to Android Play Store Internal Testing (binary only)
fastlane android beta

# Upload metadata only (no binary)
fastlane ios metadata       # App Store descriptions, keywords, etc.
fastlane android metadata   # Play Store descriptions, changelogs

# Full release (binary + metadata)
fastlane ios release        # Build, upload, and update metadata
fastlane android release    # Build, upload, and update metadata

# Screenshot capture instructions
fastlane ios screenshots    # Shows how to capture iOS screenshots
fastlane android screenshots # Shows how to capture Android screenshots
```

### Typical Release Workflow

```bash
# 1. Make your code changes
# 2. Run tests
flutter test

# 3. Bump version appropriately
fastlane bump_patch   # or bump_minor, bump_major, or just bump

# 4. Update release notes in metadata files
# Edit: fastlane/metadata/en-US/release_notes.txt (iOS)
# Edit: fastlane/metadata/android/en-US/changelogs/default.txt (Android)

# 5. Deploy (with metadata)
fastlane ios release      # Uploads binary + metadata
fastlane android release  # Uploads binary + metadata

# 6. Commit changes
git add pubspec.yaml fastlane/metadata
git commit -m "chore: release v0.2.1"
```

### Updating App Store Metadata

Edit metadata files directly, then upload:

**iOS App Store:**
- `fastlane/metadata/en-US/description.txt` - Full description
- `fastlane/metadata/en-US/keywords.txt` - Search keywords
- `fastlane/metadata/en-US/release_notes.txt` - What's new
- `fastlane/metadata/en-US/promotional_text.txt` - Promo text

**Android Play Store:**
- `fastlane/metadata/android/en-US/full_description.txt` - Full description
- `fastlane/metadata/android/en-US/short_description.txt` - Short description
- `fastlane/metadata/android/en-US/changelogs/default.txt` - Release notes

After editing:
```bash
fastlane ios metadata      # Upload to App Store Connect
fastlane android metadata  # Upload to Play Store
```

### Screenshots

Screenshots are currently captured manually:

**iOS:** Run `fastlane ios screenshots` for device-specific instructions
- Save to: `fastlane/screenshots/en-US/`
- Required: iPhone 16 Pro Max, iPhone 15 Pro Max, iPhone 8 Plus, iPad Pro 12.9", iPad Pro 11"

**Android:** Run `fastlane android screenshots` for instructions
- Save to: `fastlane/metadata/android/en-US/images/phoneScreenshots/`

### Store Links

- **App Store Connect**: [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
- **Google Play Console**: [play.google.com/console](https://play.google.com/console)

## Content Management

### Adding Images

To add new images to the app, see the complete guide: **[docs/ADDING_IMAGES.md](docs/ADDING_IMAGES.md)**

Quick summary:
1. Add `.webp` image to `assets/images/library/`
2. Edit `assets/dental_items.yaml` to add metadata entry
3. Run `./scripts/generate_dental_items.sh` to generate code
4. Build and test the app

The app uses a metadata-driven workflow where images are defined in YAML and Dart code is auto-generated.
