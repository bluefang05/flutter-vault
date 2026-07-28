import 'package:flutter/material.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('en'),
    Locale('pt'),
    Locale('fr'),
    Locale('de'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static Locale resolveLocale(Locale? locale) {
    if (locale == null) return supportedLocales.first;
    return supportedLocales.firstWhere(
      (Locale supported) => supported.languageCode == locale.languageCode,
      orElse: () => supportedLocales.first,
    );
  }

  static final LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  final Locale locale;

  String get _code => locale.languageCode;

  String _pick({
    required String es,
    required String en,
    required String pt,
    required String fr,
    required String de,
  }) {
    return switch (_code) {
      'en' => en,
      'pt' => pt,
      'fr' => fr,
      'de' => de,
      _ => es,
    };
  }

  String get appTitle => 'NBND';
  String get homeSubtitle => _pick(
        es: 'El obstáculo cambia cuando cambia tu forma de percibirlo.',
        en: 'The obstacle changes when your perception changes.',
        pt: 'O obstáculo muda quando sua forma de perceber muda.',
        fr: 'L’obstacle change quand ta perception change.',
        de: 'Das Hindernis verändert sich, wenn sich deine Wahrnehmung verändert.',
      );
  String get choosePower => _pick(
        es: 'Elige tu poder',
        en: 'Choose your power',
        pt: 'Escolha seu poder',
        fr: 'Choisis ton pouvoir',
        de: 'Wähle deine Kraft',
      );
  String get settings => _pick(
        es: 'Ajustes',
        en: 'Settings',
        pt: 'Configurações',
        fr: 'Paramètres',
        de: 'Einstellungen',
      );
  String get vibration => _pick(
        es: 'Vibración',
        en: 'Vibration',
        pt: 'Vibração',
        fr: 'Vibration',
        de: 'Vibration',
      );
  String get reducedFlashes => _pick(
        es: 'Reducir destellos',
        en: 'Reduce flashes',
        pt: 'Reduzir flashes',
        fr: 'Réduire les flashs',
        de: 'Blitze reduzieren',
      );
  String get practiceMode => _pick(
        es: 'Modo práctica',
        en: 'Practice mode',
        pt: 'Modo prática',
        fr: 'Mode pratique',
        de: 'Übungsmodus',
      );
  String get showAdSpace => _pick(
        es: 'Mostrar espacio publicitario',
        en: 'Show ad space',
        pt: 'Mostrar espaço publicitário',
        fr: 'Afficher l’espace publicitaire',
        de: 'Werbefläche anzeigen',
      );
  String get save => _pick(
        es: 'Guardar',
        en: 'Save',
        pt: 'Salvar',
        fr: 'Enregistrer',
        de: 'Speichern',
      );
  String get play => _pick(
        es: 'Jugar',
        en: 'Play',
        pt: 'Jogar',
        fr: 'Jouer',
        de: 'Spielen',
      );
  String get record => _pick(
        es: 'Récord',
        en: 'Record',
        pt: 'Recorde',
        fr: 'Record',
        de: 'Rekord',
      );
  String get initialReserve => _pick(
        es: 'Reserva inicial',
        en: 'Initial reserve',
        pt: 'Reserva inicial',
        fr: 'Réserve initiale',
        de: 'Anfangsreserve',
      );
  String get startPrompt => _pick(
        es: 'Toca para comenzar',
        en: 'Tap to start',
        pt: 'Toque para começar',
        fr: 'Touchez pour commencer',
        de: 'Zum Starten tippen',
      );
  String get pauseTitle => _pick(
        es: 'Pausa',
        en: 'Pause',
        pt: 'Pausa',
        fr: 'Pause',
        de: 'Pause',
      );
  String get pauseMessage => _pick(
        es: 'El patrón queda detenido.',
        en: 'The pattern is frozen.',
        pt: 'O padrão fica parado.',
        fr: 'Le motif est figé.',
        de: 'Das Muster bleibt stehen.',
      );
  String get resume => _pick(
        es: 'Continuar',
        en: 'Resume',
        pt: 'Continuar',
        fr: 'Continuer',
        de: 'Fortsetzen',
      );
  String get gameOverTitle => _pick(
        es: 'Fin del pulso',
        en: 'End of pulse',
        pt: 'Fim do pulso',
        fr: 'Fin de l’impulsion',
        de: 'Ende des Pulses',
      );
  String get retry => _pick(
        es: 'Reintentar',
        en: 'Retry',
        pt: 'Repetir',
        fr: 'Réessayer',
        de: 'Erneut versuchen',
      );
  String get backToMenu => _pick(
        es: 'Volver al menú',
        en: 'Back to menu',
        pt: 'Voltar ao menu',
        fr: 'Retour au menu',
        de: 'Zurück zum Menü',
      );
  String scoreLine(int score, int bestScore) => _pick(
        es: 'Puntuación $score · Récord $bestScore',
        en: 'Score $score · Record $bestScore',
        pt: 'Pontuação $score · Recorde $bestScore',
        fr: 'Score $score · Record $bestScore',
        de: 'Punktzahl $score · Rekord $bestScore',
      );
  String stageLabel(String stage, double seconds) => _pick(
        es: '$stage  ${seconds.toStringAsFixed(1)} s',
        en: '$stage  ${seconds.toStringAsFixed(1)} s',
        pt: '$stage  ${seconds.toStringAsFixed(1)} s',
        fr: '$stage  ${seconds.toStringAsFixed(1)} s',
        de: '$stage  ${seconds.toStringAsFixed(1)} s',
      );
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (Locale supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(AppLocalizations.resolveLocale(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
