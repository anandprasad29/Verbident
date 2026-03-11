import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Verbident'**
  String get appTitle;

  /// Navigation label for library section
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// Navigation label for before visit section
  ///
  /// In en, this message translates to:
  /// **'Before the visit'**
  String get navBeforeVisit;

  /// Navigation label for during visit section
  ///
  /// In en, this message translates to:
  /// **'During the visit'**
  String get navDuringVisit;

  /// Navigation label for build your own section
  ///
  /// In en, this message translates to:
  /// **'Build your own'**
  String get navBuildOwn;

  /// Page header for library page
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get pageHeaderLibrary;

  /// Page header for before visit page
  ///
  /// In en, this message translates to:
  /// **'Before the visit'**
  String get pageHeaderBeforeVisit;

  /// Page header for during visit page
  ///
  /// In en, this message translates to:
  /// **'During the visit'**
  String get pageHeaderDuringVisit;

  /// Page header for build your own page
  ///
  /// In en, this message translates to:
  /// **'Build your own'**
  String get pageHeaderBuildOwn;

  /// Label for language selector dropdown
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSelectorLabel;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingContent;

  /// Indicator shown when TTS is speaking
  ///
  /// In en, this message translates to:
  /// **'Speaking'**
  String get speakingIndicator;

  /// Dark mode toggle label
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// Light mode toggle label
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Placeholder text for search input
  ///
  /// In en, this message translates to:
  /// **'Search by caption...'**
  String get searchPlaceholder;

  /// Message shown when search returns no results
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get searchNoResults;

  /// Shows the number of search results
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String searchResultCount(int count);

  /// Placeholder text for template name input
  ///
  /// In en, this message translates to:
  /// **'Template Name'**
  String get templateNamePlaceholder;

  /// Shows the number of selected items
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// Button text to create a new template
  ///
  /// In en, this message translates to:
  /// **'Create Template'**
  String get createTemplate;

  /// Button text to edit a template
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editTemplate;

  /// Button text to delete a template
  ///
  /// In en, this message translates to:
  /// **'Delete Template'**
  String get deleteTemplate;

  /// Confirmation message for template deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this template?'**
  String get deleteConfirmation;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Section header for adding images in edit mode
  ///
  /// In en, this message translates to:
  /// **'Add Images'**
  String get addImages;

  /// Section header for current images in edit mode
  ///
  /// In en, this message translates to:
  /// **'Current Images'**
  String get currentImages;

  /// Hint text for removing images
  ///
  /// In en, this message translates to:
  /// **'Tap to remove'**
  String get tapToRemove;

  /// Message when no images are selected
  ///
  /// In en, this message translates to:
  /// **'No images selected yet'**
  String get noImagesSelected;

  /// Validation message for template creation
  ///
  /// In en, this message translates to:
  /// **'Select at least one image'**
  String get selectAtLeastOne;

  /// Validation message for template name
  ///
  /// In en, this message translates to:
  /// **'Please enter a template name'**
  String get enterTemplateName;

  /// Title for unsaved changes dialog
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChangesTitle;

  /// Message for unsaved changes dialog
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Are you sure you want to discard them?'**
  String get unsavedChangesMessage;

  /// Discard button text
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// Title when max templates reached
  ///
  /// In en, this message translates to:
  /// **'Template limit reached'**
  String get templateLimitReached;

  /// Message when max templates reached
  ///
  /// In en, this message translates to:
  /// **'You can create up to {count} templates. Please delete an existing template to create a new one.'**
  String templateLimitMessage(int count);

  /// Loading state for templates
  ///
  /// In en, this message translates to:
  /// **'Loading templates...'**
  String get loadingTemplates;

  /// Hint text for drag reorder
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get dragToReorder;

  /// Prompt when no images selected in build mode
  ///
  /// In en, this message translates to:
  /// **'Tap images below to add them to your template'**
  String get emptyTemplatePrompt;

  /// Error when template name is duplicate
  ///
  /// In en, this message translates to:
  /// **'A template with this name already exists'**
  String get duplicateNameError;

  /// Navigation label for visit workflow accordion
  ///
  /// In en, this message translates to:
  /// **'Visit Workflow'**
  String get navVisitWorkflow;

  /// Navigation label for settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Appearance section header
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// Speech section header
  ///
  /// In en, this message translates to:
  /// **'Speech'**
  String get settingsSpeech;

  /// Theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// Speech rate setting label
  ///
  /// In en, this message translates to:
  /// **'Speech Rate'**
  String get settingsSpeechRate;

  /// Slow speech rate
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get settingsSpeechRateSlow;

  /// Normal speech rate
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get settingsSpeechRateNormal;

  /// Fast speech rate
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get settingsSpeechRateFast;

  /// Very fast speech rate
  ///
  /// In en, this message translates to:
  /// **'Very Fast'**
  String get settingsSpeechRateVeryFast;

  /// Voice setting label
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get settingsVoice;

  /// Female voice option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get settingsVoiceFemale;

  /// Male voice option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get settingsVoiceMale;

  /// Test speech button label
  ///
  /// In en, this message translates to:
  /// **'Test Speech'**
  String get settingsTestSpeech;

  /// Test speech hint
  ///
  /// In en, this message translates to:
  /// **'Tap to hear a sample'**
  String get settingsTestSpeechHint;

  /// Sample text for TTS test
  ///
  /// In en, this message translates to:
  /// **'Hello! This is a test.'**
  String get settingsTestSpeechSample;

  /// Category header for actions and objects
  ///
  /// In en, this message translates to:
  /// **'Actions & Objects'**
  String get categorySectionActions;

  /// Category header for instructional words
  ///
  /// In en, this message translates to:
  /// **'Instructional Words'**
  String get categorySectionInstructional;

  /// Category header for expression items
  ///
  /// In en, this message translates to:
  /// **'Expression'**
  String get categorySectionExpression;

  /// Category header for non-dental items
  ///
  /// In en, this message translates to:
  /// **'Non-Dental'**
  String get categorySectionNonDental;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
