// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Verbident';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navBeforeVisit => 'Antes de la visita';

  @override
  String get navDuringVisit => 'Durante la visita';

  @override
  String get navBuildOwn => 'Crea el tuyo';

  @override
  String get pageHeaderLibrary => 'Biblioteca';

  @override
  String get pageHeaderBeforeVisit => 'Antes de la visita';

  @override
  String get pageHeaderDuringVisit => 'Durante la visita';

  @override
  String get pageHeaderBuildOwn => 'Crea el tuyo';

  @override
  String get languageSelectorLabel => 'Idioma';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get loadingContent => 'Cargando...';

  @override
  String get speakingIndicator => 'Hablando';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get lightMode => 'Modo claro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get searchPlaceholder => 'Buscar por texto...';

  @override
  String get searchNoResults => 'No se encontraron resultados';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
      zero: 'Sin elementos',
    );
    return '$_temp0';
  }

  @override
  String get templateNamePlaceholder => 'Nombre de la plantilla';

  @override
  String selectedCount(int count) {
    return '$count seleccionados';
  }

  @override
  String get createTemplate => 'Crear plantilla';

  @override
  String get editTemplate => 'Editar';

  @override
  String get deleteTemplate => 'Eliminar plantilla';

  @override
  String get deleteConfirmation =>
      '¿Estás seguro de que quieres eliminar esta plantilla?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get addImages => 'Agregar imágenes';

  @override
  String get currentImages => 'Imágenes actuales';

  @override
  String get tapToRemove => 'Toca para eliminar';

  @override
  String get noImagesSelected => 'Aún no hay imágenes seleccionadas';

  @override
  String get selectAtLeastOne => 'Selecciona al menos una imagen';

  @override
  String get enterTemplateName =>
      'Por favor ingresa un nombre para la plantilla';

  @override
  String get unsavedChangesTitle => 'Cambios sin guardar';

  @override
  String get unsavedChangesMessage =>
      'Tienes cambios sin guardar. ¿Estás seguro de que quieres descartarlos?';

  @override
  String get discard => 'Descartar';

  @override
  String get templateLimitReached => 'Límite de plantillas alcanzado';

  @override
  String templateLimitMessage(int count) {
    return 'Puedes crear hasta $count plantillas. Por favor elimina una plantilla existente para crear una nueva.';
  }

  @override
  String get loadingTemplates => 'Cargando plantillas...';

  @override
  String get dragToReorder => 'Arrastra para reordenar';

  @override
  String get emptyTemplatePrompt =>
      'Toca las imágenes abajo para agregarlas a tu plantilla';

  @override
  String get duplicateNameError => 'Ya existe una plantilla con este nombre';

  @override
  String get navVisitWorkflow => 'Flujo de visita';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsSpeech => 'Voz';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsSpeechRate => 'Velocidad de voz';

  @override
  String get settingsSpeechRateSlow => 'Lento';

  @override
  String get settingsSpeechRateNormal => 'Normal';

  @override
  String get settingsSpeechRateFast => 'Rápido';

  @override
  String get settingsSpeechRateVeryFast => 'Muy rápido';

  @override
  String get settingsVoice => 'Voz';

  @override
  String get settingsVoiceFemale => 'Femenina';

  @override
  String get settingsVoiceMale => 'Masculina';

  @override
  String get settingsTestSpeech => 'Probar voz';

  @override
  String get settingsTestSpeechHint => 'Toca para escuchar una muestra';

  @override
  String get settingsTestSpeechSample => '¡Hola! Esta es una prueba.';

  @override
  String get categorySectionActions => 'Acciones y objetos';

  @override
  String get categorySectionInstructional => 'Palabras instructivas';

  @override
  String get categorySectionExpression => 'Expresión';

  @override
  String get categorySectionNonDental => 'No dental';

  @override
  String get dashboardWelcome => '¿Qué te gustaría hacer?';

  @override
  String get dashboardBeforeVisit => 'Antes de la visita';

  @override
  String get dashboardDuringVisit => 'Durante la visita';

  @override
  String get dashboardLibrary => 'Biblioteca';

  @override
  String get dashboardBuildOwn => 'Crea el tuyo';

  @override
  String get dashboardMyTemplates => 'Mis plantillas';

  @override
  String get dashboardCreateNew => 'Crear nueva';

  @override
  String get ok => 'Aceptar';

  @override
  String get templateNotFound => 'Plantilla no encontrada';

  @override
  String get allImagesAdded => 'Todas las imágenes han sido agregadas';

  @override
  String get settingsRestoreDefaults => 'Restaurar valores predeterminados';

  @override
  String get settingsRestoreDefaultsHint =>
      'Restablecer todos los ajustes a los valores originales';

  @override
  String get settingsRestoreDefaultsConfirm =>
      '¿Estás seguro de que quieres restaurar todos los ajustes a sus valores predeterminados?';

  @override
  String get restore => 'Restaurar';
}
