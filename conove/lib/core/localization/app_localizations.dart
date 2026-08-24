import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const List<Locale> supportedLocales = [
    Locale('es'),
    Locale('en'),
    Locale('fr'),
    Locale('pt'),
    Locale('de'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('es'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String get langCode => locale.languageCode;

  // Translation dictionaries
  static final Map<String, Map<String, String>> _values = {
    'es': {
      'appName': 'Gestura',
      'appSubtitle': 'Decodificador de Lenguaje Corporal y Comunicación No Verbal',
      'home': 'Inicio',
      'manual': 'Manual',
      'practice': 'Práctica',
      'scenarios': 'Escenarios',
      'settings': 'Ajustes',
      'search': 'Buscar',
      'searchHint': 'Buscar señal, microgesto o palabra clave...',
      'all': 'Todos',
      'quickDecoder': 'Decodificador Rápido',
      'quickDecoderDesc': 'Filtra por parte del cuerpo (ojos, boca, brazos, silencios) y descifra la intención oculta en segundos.',
      'openDecoder': 'Abrir Decodificador en Vivo',
      'dailyQuiz': 'Quiz Visual del Día',
      'dailyQuizDesc': 'Pon a prueba tu capacidad de reconocimiento de microexpresiones y posturas.',
      'startQuiz': 'Comenzar Práctica Diaria',
      'socialTree': 'Árbol de Decisión Social',
      'socialTreeDesc': '¿Ves un gesto difícil? Sigue el árbol: Si veo X ➔ Significa Y ➔ Hago Z.',
      'openTree': 'Abrir Árbol de Diagnóstico',
      'compareAB': 'Comparador Visual A/B',
      'compareABDesc': 'Contrasta pares de gestos confusos lado a lado con tabla de diferencias anatómicas.',
      'openCompare': 'Abrir Comparador',
      'cheatSheet': 'Guía de Bolsillo (Cheat Sheet)',
      'cheatSheetDesc': '20 señales no verbales críticas para negociaciones, entrevistas y ventas.',
      'openCheatSheet': 'Ver Guía de Bolsillo',
      'exploredSignals': 'Señales Exploradas',
      'totalScore': 'Puntos de Maestría',
      'streak': 'Racha de Estudio',
      'categoriesTitle': 'Categorías de Comunicación',
      'facialCat': 'Expresiones Faciales',
      'vocalCat': 'Factores Paralingüísticos',
      'bodyCat': 'Posturas y Corporal',
      'proxemicsCat': 'Espacio y Proxémica',
      'envCat': 'Entorno y Apariencia',
      'digitalCat': 'Señales Digitales',
      'signalReceptive': 'Luz Verde (Receptividad)',
      'signalCaution': 'Luz Amarilla (Precaución)',
      'signalObjection': 'Luz Roja (Objeción / Barrera)',
      'listenAloud': 'Escuchar Ficha',
      'stopAudio': 'Detener Audio',
      'anatomyClues': 'Pistas Anatómicas',
      'probableMeaning': 'Significado Probable',
      'whatToDo': '¿Qué debes hacer / responder tú?',
      'salesTip': 'Táctica de Ventas y Negociación',
      'language': 'Idioma de la Aplicación',
      'systemLanguage': 'Automático (Idioma del Sistema)',
      'appearance': 'Apariencia y Tema',
      'themeLight': 'Modo Claro',
      'themeDark': 'Modo Oscuro',
      'themeSystem': 'Tema del Sistema',
      'highContrast': 'Alto Contraste (Modo Accesibilidad)',
      'reduceMotion': 'Reducir Animaciones y Movimiento',
      'warmFilter': 'Filtro Cálido (Descanso Ocular)',
      'haptics': 'Respuesta Háptica (Vibración)',
      'ttsVoice': 'Lectura de Voz en Voz Alta (TTS)',
      'resetProgress': 'Reiniciar Progreso',
      'resetConfirm': '¿Estás seguro de reiniciar todo tu progreso?',
      'about': 'Acerca de Gestura',
      'version': 'Versión',
      'offlineFirst': '100% Local y Privado • Sin conexión requerida',
    },
    'en': {
      'appName': 'Gestura',
      'appSubtitle': 'Body Language & Nonverbal Communication Decoder',
      'home': 'Home',
      'manual': 'Manual',
      'practice': 'Practice',
      'scenarios': 'Scenarios',
      'settings': 'Settings',
      'search': 'Search',
      'searchHint': 'Search gesture, microexpression or keyword...',
      'all': 'All',
      'quickDecoder': 'Quick Decoder',
      'quickDecoderDesc': 'Filter by body part (eyes, mouth, arms, pauses) and decode hidden intention in seconds.',
      'openDecoder': 'Open Live Decoder',
      'dailyQuiz': 'Daily Visual Quiz',
      'dailyQuizDesc': 'Test your recognition of microexpressions and body postures.',
      'startQuiz': 'Start Daily Practice',
      'socialTree': 'Social Decision Tree',
      'socialTreeDesc': 'See a confusing gesture? Follow the tree: If I see X ➔ Means Y ➔ I do Z.',
      'openTree': 'Open Diagnostic Tree',
      'compareAB': 'Visual A/B Comparator',
      'compareABDesc': 'Contrast easily confused gesture pairs side-by-side with anatomical diff table.',
      'openCompare': 'Open Comparator',
      'cheatSheet': 'Pocket Cheat Sheet',
      'cheatSheetDesc': '20 critical nonverbal signals for negotiations, interviews, and sales.',
      'openCheatSheet': 'View Cheat Sheet',
      'exploredSignals': 'Explored Signals',
      'totalScore': 'Mastery Points',
      'streak': 'Study Streak',
      'categoriesTitle': 'Communication Categories',
      'facialCat': 'Facial Expressions',
      'vocalCat': 'Paralinguistic Factors',
      'bodyCat': 'Body Posture & Language',
      'proxemicsCat': 'Proxemics & Space',
      'envCat': 'Environment & Appearance',
      'digitalCat': 'Digital Signals',
      'signalReceptive': 'Green Light (Receptivity)',
      'signalCaution': 'Yellow Light (Caution / Hesitation)',
      'signalObjection': 'Red Light (Objection / Barrier)',
      'listenAloud': 'Listen to Card',
      'stopAudio': 'Stop Audio',
      'anatomyClues': 'Anatomical Clues',
      'probableMeaning': 'Probable Meaning',
      'whatToDo': 'What should you do / say?',
      'salesTip': 'Sales & Negotiation Tactic',
      'language': 'App Language',
      'systemLanguage': 'Automatic (System Language)',
      'appearance': 'Appearance & Theme',
      'themeLight': 'Light Mode',
      'themeDark': 'Dark Mode',
      'themeSystem': 'System Default',
      'highContrast': 'High Contrast (Accessibility Mode)',
      'reduceMotion': 'Reduce Motion & Animations',
      'warmFilter': 'Warm Ocular Filter (Eye Comfort)',
      'haptics': 'Haptic Vibration Feedback',
      'ttsVoice': 'Text-to-Speech Narration (TTS)',
      'resetProgress': 'Reset Progress',
      'resetConfirm': 'Are you sure you want to reset all your progress?',
      'about': 'About Gestura',
      'version': 'Version',
      'offlineFirst': '100% Offline & Private • No internet required',
    },
    'fr': {
      'appName': 'Gestura',
      'appSubtitle': 'Décodeur de Langage Corporel et Communication Non Verbale',
      'home': 'Accueil',
      'manual': 'Manuel',
      'practice': 'Pratique',
      'scenarios': 'Scénarios',
      'settings': 'Paramètres',
      'search': 'Rechercher',
      'searchHint': 'Rechercher un geste, micro-expression ou mot-clé...',
      'all': 'Tous',
      'quickDecoder': 'Décodeur Rapide',
      'quickDecoderDesc': 'Filtrez par partie du corps (yeux, bouche, bras, silences) et décodez l\'intention cachée en quelques secondes.',
      'openDecoder': 'Ouvrir le Décodeur',
      'dailyQuiz': 'Quiz Visuel du Jour',
      'dailyQuizDesc': 'Testez votre reconnaissance des micro-expressions et des postures.',
      'startQuiz': 'Commencer la Pratique',
      'socialTree': 'Arbre de Décision Sociale',
      'socialTreeDesc': 'Vous voyez un geste difficile ? Suivez l\'arbre : Si je vois X ➔ Signifie Y ➔ Je fais Z.',
      'openTree': 'Ouvrir l\'Arbre de Diagnostic',
      'compareAB': 'Comparateur Visuel A/B',
      'compareABDesc': 'Comparez côte à côte des paires de gestes facilement confondus avec tableau anatomique.',
      'openCompare': 'Ouvrir le Comparateur',
      'cheatSheet': 'Fiche Mémo de Poche',
      'cheatSheetDesc': '20 signaux non verbaux essentiels pour les négociations, entretiens et ventes.',
      'openCheatSheet': 'Voir la Fiche Mémo',
      'exploredSignals': 'Signaux Explorés',
      'totalScore': 'Points de Maîtrise',
      'streak': 'Série d\'Étude',
      'categoriesTitle': 'Catégories de Communication',
      'facialCat': 'Expressions Faciales',
      'vocalCat': 'Facteurs Paralinguistiques',
      'bodyCat': 'Postures et Corps',
      'proxemicsCat': 'Proxémique et Espace',
      'envCat': 'Environnement et Apparence',
      'digitalCat': 'Signaux Numériques',
      'signalReceptive': 'Feu Vert (Réceptivité)',
      'signalCaution': 'Feu Jaune (Prudence / Hésitation)',
      'signalObjection': 'Feu Rouge (Objection / Barrière)',
      'listenAloud': 'Écouter la Fiche',
      'stopAudio': 'Arrêter l\'Audio',
      'anatomyClues': 'Indices Anatomiques',
      'probableMeaning': 'Signification Probable',
      'whatToDo': 'Que devez-vous faire / répondre ?',
      'salesTip': 'Tactique de Vente et Négociation',
      'language': 'Langue de l\'Application',
      'systemLanguage': 'Automatique (Langue du Système)',
      'appearance': 'Apparence et Thème',
      'themeLight': 'Mode Clair',
      'themeDark': 'Mode Sombre',
      'themeSystem': 'Thème du Système',
      'highContrast': 'Contraste Élevé (Accessibilité)',
      'reduceMotion': 'Réduire les Animations',
      'warmFilter': 'Filtre Chaud (Confort Oculaire)',
      'haptics': 'Retour Haptique (Vibration)',
      'ttsVoice': 'Lecture Vocale (TTS)',
      'resetProgress': 'Réinitialiser la Progression',
      'resetConfirm': 'Êtes-vous sûr de vouloir réinitialiser votre progression ?',
      'about': 'À propos de Gestura',
      'version': 'Version',
      'offlineFirst': '100% Hors Ligne et Privé • Sans connexion requise',
    },
    'pt': {
      'appName': 'Gestura',
      'appSubtitle': 'Decodificador de Linguagem Corporal e Comunicação Não Verbal',
      'home': 'Início',
      'manual': 'Manual',
      'practice': 'Prática',
      'scenarios': 'Cenários',
      'settings': 'Ajustes',
      'search': 'Buscar',
      'searchHint': 'Buscar gesto, microexpressão ou palavra-chave...',
      'all': 'Todos',
      'quickDecoder': 'Decodificador Rápido',
      'quickDecoderDesc': 'Filtre por parte do corpo (olhos, boca, braços, silêncios) e decifre a intenção oculta em segundos.',
      'openDecoder': 'Abrir Decodificador',
      'dailyQuiz': 'Quiz Visual Diário',
      'dailyQuizDesc': 'Teste seu reconhecimento de microexpressões e posturas corporais.',
      'startQuiz': 'Começar Prática Diária',
      'socialTree': 'Árvore de Decisão Social',
      'socialTreeDesc': 'Viu um gesto confuso? Siga a árvore: Se vejo X ➔ Significa Y ➔ Faço Z.',
      'openTree': 'Abrir Árvore Diagnóstica',
      'compareAB': 'Comparador Visual A/B',
      'compareABDesc': 'Contraste pares de gestos lado a lado com tabela de diferenças anatômicas.',
      'openCompare': 'Abrir Comparador',
      'cheatSheet': 'Guia de Bolso (Cheat Sheet)',
      'cheatSheetDesc': '20 sinais não verbais críticos para negociações, entrevistas e vendas.',
      'openCheatSheet': 'Ver Guia de Bolso',
      'exploredSignals': 'Sinais Explorados',
      'totalScore': 'Pontos de Maestria',
      'streak': 'Sequência de Estudo',
      'categoriesTitle': 'Categorias de Comunicação',
      'facialCat': 'Expressões Faciais',
      'vocalCat': 'Fatores Paralinguísticos',
      'bodyCat': 'Postura e Linguagem Corporal',
      'proxemicsCat': 'Proxêmica e Espaço',
      'envCat': 'Ambiente e Aparência',
      'digitalCat': 'Sinais Digitais',
      'signalReceptive': 'Sinal Verde (Receptividade)',
      'signalCaution': 'Sinal Amarelo (Atenção / Dúvida)',
      'signalObjection': 'Sinal Vermelho (Objeção / Barreira)',
      'listenAloud': 'Ouvir Ficha',
      'stopAudio': 'Parar Áudio',
      'anatomyClues': 'Pistas Anatômicas',
      'probableMeaning': 'Significado Provável',
      'whatToDo': 'O que você deve fazer / responder?',
      'salesTip': 'Tática de Vendas e Negociação',
      'language': 'Idioma do Aplicativo',
      'systemLanguage': 'Automático (Idioma do Sistema)',
      'appearance': 'Aparência e Tema',
      'themeLight': 'Modo Claro',
      'themeDark': 'Modo Escuro',
      'themeSystem': 'Padrão do Sistema',
      'highContrast': 'Alto Contraste (Acessibilidade)',
      'reduceMotion': 'Reduzir Animações e Movimento',
      'warmFilter': 'Filtro Quente (Descanso Visual)',
      'haptics': 'Resposta Tátil (Vibração)',
      'ttsVoice': 'Leitura em Voz Alta (TTS)',
      'resetProgress': 'Redefinir Progresso',
      'resetConfirm': 'Tem certeza que deseja redefinir seu progresso?',
      'about': 'Sobre o Gestura',
      'version': 'Versão',
      'offlineFirst': '100% Offline e Privado • Sem internet necessária',
    },
    'de': {
      'appName': 'Gestura',
      'appSubtitle': 'Körpersprache & Nonverbale Kommunikation Decoder',
      'home': 'Start',
      'manual': 'Handbuch',
      'practice': 'Übung',
      'scenarios': 'Szenarien',
      'settings': 'Einstellungen',
      'search': 'Suchen',
      'searchHint': 'Geste, Mikromimik oder Stichwort suchen...',
      'all': 'Alle',
      'quickDecoder': 'Schnell-Decoder',
      'quickDecoderDesc': 'Nach Körperteil filtern (Augen, Mund, Arme, Stille) und verborgene Absichten in Sekunden entschlüsseln.',
      'openDecoder': 'Live-Decoder öffnen',
      'dailyQuiz': 'Tägliches Bild-Quiz',
      'dailyQuizDesc': 'Testen Sie Ihre Erkennung von Mikroausdrücken und Körperhaltungen.',
      'startQuiz': 'Tägliche Übung starten',
      'socialTree': 'Sozialer Entscheidungsbaum',
      'socialTreeDesc': 'Schwierige Geste? Folgen Sie dem Baum: Sehe ich X ➔ Bedeutet Y ➔ Tue ich Z.',
      'openTree': 'Diagnosebaum öffnen',
      'compareAB': 'Visueller A/B-Vergleich',
      'compareABDesc': 'Vergleichen Sie verwirrende Gestenpaare nebeneinander mit anatomischer Tabelle.',
      'openCompare': 'Vergleich öffnen',
      'cheatSheet': 'Taschen-Spickzettel (Cheat Sheet)',
      'cheatSheetDesc': '20 entscheidende nonverbale Signale für Verhandlungen, Vorstellungsgespräche und Vertrieb.',
      'openCheatSheet': 'Spickzettel anzeigen',
      'exploredSignals': 'Erforschte Signale',
      'totalScore': 'Meisterschaftspunkte',
      'streak': 'Lernserie',
      'categoriesTitle': 'Kommunikationskategorien',
      'facialCat': 'Gesichtsausdrücke',
      'vocalCat': 'Paralinguistische Faktoren',
      'bodyCat': 'Körperhaltung & Gestik',
      'proxemicsCat': 'Proxemik & Raum',
      'envCat': 'Umgebung & Erscheinung',
      'digitalCat': 'Digitale Signale',
      'signalReceptive': 'Grünes Licht (Aufgeschlossenheit)',
      'signalCaution': 'Gelbes Licht (Vorsicht / Zögern)',
      'signalObjection': 'Rotes Licht (Einwand / Barriere)',
      'listenAloud': 'Karte anhören',
      'stopAudio': 'Audio stoppen',
      'anatomyClues': 'Anatomische Hinweise',
      'probableMeaning': 'Wahrscheinliche Bedeutung',
      'whatToDo': 'Was sollten Sie tun / antworten?',
      'salesTip': 'Verkaufs- & Verhandlungstaktik',
      'language': 'App-Sprache',
      'systemLanguage': 'Automatisch (Systemsprache)',
      'appearance': 'Erscheinungsbild & Design',
      'themeLight': 'Helles Design',
      'themeDark': 'Dunkles Design',
      'themeSystem': 'Systemstandard',
      'highContrast': 'Hoher Kontrast (Barrierefreiheit)',
      'reduceMotion': 'Bewegungen reduzieren',
      'warmFilter': 'Warmfilter (Augenschonung)',
      'haptics': 'Haptisches Feedback (Vibration)',
      'ttsVoice': 'Sprachausgabe (TTS)',
      'resetProgress': 'Fortschritt zurücksetzen',
      'resetConfirm': 'Möchten Sie Ihren gesamten Fortschritt wirklich zurücksetzen?',
      'about': 'Über Gestura',
      'version': 'Version',
      'offlineFirst': '100% Offline & Privat • Kein Internet erforderlich',
    },
  };

  String translate(String key) {
    final lang = _values.containsKey(langCode) ? langCode : 'es';
    return _values[lang]?[key] ?? _values['es']?[key] ?? key;
  }

  // Getters
  String get appName => translate('appName');
  String get appSubtitle => translate('appSubtitle');
  String get home => translate('home');
  String get manual => translate('manual');
  String get practice => translate('practice');
  String get scenarios => translate('scenarios');
  String get settings => translate('settings');
  String get search => translate('search');
  String get searchHint => translate('searchHint');
  String get all => translate('all');
  String get quickDecoder => translate('quickDecoder');
  String get quickDecoderDesc => translate('quickDecoderDesc');
  String get openDecoder => translate('openDecoder');
  String get dailyQuiz => translate('dailyQuiz');
  String get dailyQuizDesc => translate('dailyQuizDesc');
  String get startQuiz => translate('startQuiz');
  String get socialTree => translate('socialTree');
  String get socialTreeDesc => translate('socialTreeDesc');
  String get openTree => translate('openTree');
  String get compareAB => translate('compareAB');
  String get compareABDesc => translate('compareABDesc');
  String get openCompare => translate('openCompare');
  String get cheatSheet => translate('cheatSheet');
  String get cheatSheetDesc => translate('cheatSheetDesc');
  String get openCheatSheet => translate('openCheatSheet');
  String get exploredSignals => translate('exploredSignals');
  String get totalScore => translate('totalScore');
  String get streak => translate('streak');
  String get categoriesTitle => translate('categoriesTitle');
  String get signalReceptive => translate('signalReceptive');
  String get signalCaution => translate('signalCaution');
  String get signalObjection => translate('signalObjection');
  String get listenAloud => translate('listenAloud');
  String get stopAudio => translate('stopAudio');
  String get anatomyClues => translate('anatomyClues');
  String get probableMeaning => translate('probableMeaning');
  String get whatToDo => translate('whatToDo');
  String get salesTip => translate('salesTip');
  String get language => translate('language');
  String get systemLanguage => translate('systemLanguage');
  String get appearance => translate('appearance');
  String get themeLight => translate('themeLight');
  String get themeDark => translate('themeDark');
  String get themeSystem => translate('themeSystem');
  String get highContrast => translate('highContrast');
  String get reduceMotion => translate('reduceMotion');
  String get warmFilter => translate('warmFilter');
  String get haptics => translate('haptics');
  String get ttsVoice => translate('ttsVoice');
  String get resetProgress => translate('resetProgress');
  String get resetConfirm => translate('resetConfirm');
  String get about => translate('about');
  String get version => translate('version');
  String get offlineFirst => translate('offlineFirst');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['es', 'en', 'fr', 'pt', 'de'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
