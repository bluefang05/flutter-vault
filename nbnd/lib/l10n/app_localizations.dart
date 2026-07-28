import 'package:flutter/material.dart';

import '../models/neuro_type.dart';

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
  String get learnProfiles => _pick(
    es: 'Conocer los perfiles',
    en: 'Learn the profiles',
    pt: 'Conhecer os perfis',
    fr: 'Découvrir les profils',
    de: 'Profile kennenlernen',
  );
  String get profilesIntro => _pick(
    es: 'Perfiles y experiencias representados como metáforas jugables. Esta información es educativa y no sustituye una evaluación profesional.',
    en: 'Profiles and experiences represented as playable metaphors. This information is educational and does not replace a professional evaluation.',
    pt: 'Perfis e experiências representados como metáforas jogáveis. Esta informação é educativa e não substitui uma avaliação profissional.',
    fr: 'Profils et expériences représentés comme des métaphores jouables. Ces informations sont éducatives et ne remplacent pas une évaluation professionnelle.',
    de: 'Profile und Erfahrungen als spielbare Metaphern. Diese Informationen sind pädagogisch und ersetzen keine professionelle Beurteilung.',
  );
  String get whatItIs => _pick(
    es: 'Qué es',
    en: 'What it is',
    pt: 'O que é',
    fr: 'Ce que c’est',
    de: 'Was es ist',
  );
  String get howItCanFeel => _pick(
    es: 'Cómo puede sentirse',
    en: 'How it can feel',
    pt: 'Como pode se sentir',
    fr: 'Comment cela peut se ressentir',
    de: 'Wie es sich anfühlen kann',
  );
  String get whatItDoesNotMean => _pick(
    es: 'Lo que no significa',
    en: 'What it does not mean',
    pt: 'O que não significa',
    fr: 'Ce que cela ne signifie pas',
    de: 'Was es nicht bedeutet',
  );
  String get nbndRepresentation => _pick(
    es: 'Cómo se representa en NBND',
    en: 'How NBND represents it',
    pt: 'Como NBND representa',
    fr: 'Comment NBND le représente',
    de: 'Wie NBND es darstellt',
  );
  String get communityVoices => _pick(
    es: 'Voces de la comunidad',
    en: 'Community voices',
    pt: 'Vozes da comunidade',
    fr: 'Voix de la communauté',
    de: 'Stimmen der Community',
  );
  String get communityVoicesBody => _pick(
    es: 'Espacio reservado para aportes voluntarios, moderados y con consentimiento. No se usarán textos anónimos tomados de redes.',
    en: 'Reserved for voluntary, moderated, consent-based contributions. Anonymous social media posts will not be used.',
    pt: 'Espaço reservado para contribuições voluntárias, moderadas e com consentimento. Textos anônimos de redes sociais não serão usados.',
    fr: 'Espace réservé aux contributions volontaires, modérées et consenties. Les textes anonymes de réseaux sociaux ne seront pas utilisés.',
    de: 'Platz für freiwillige, moderierte Beiträge mit Zustimmung. Anonyme Texte aus sozialen Medien werden nicht verwendet.',
  );
  String get everyPersonDiffers => _pick(
    es: 'Cada persona lo experimenta de manera diferente.',
    en: 'Each person experiences it differently.',
    pt: 'Cada pessoa vivencia isso de forma diferente.',
    fr: 'Chaque personne le vit différemment.',
    de: 'Jede Person erlebt es anders.',
  );
  String get playableMetaphorNote => _pick(
    es: 'En NBND, este poder es una metáfora jugable. No pretende representar todas las experiencias de las personas con este perfil.',
    en: 'In NBND, this power is a playable metaphor. It is not meant to represent every experience people with this profile may have.',
    pt: 'Em NBND, este poder é uma metáfora jogável. Ele não pretende representar todas as experiências das pessoas com este perfil.',
    fr: 'Dans NBND, ce pouvoir est une métaphore jouable. Il ne prétend pas représenter toutes les expériences des personnes ayant ce profil.',
    de: 'In NBND ist diese Kraft eine spielbare Metapher. Sie soll nicht alle Erfahrungen von Menschen mit diesem Profil darstellen.',
  );
  String get educationalDisclaimer => _pick(
    es: 'Esta información es educativa. No sirve para diagnosticar ni sustituye una evaluación profesional.',
    en: 'This information is educational. It is not for diagnosis and does not replace a professional evaluation.',
    pt: 'Esta informação é educativa. Não serve para diagnóstico nem substitui uma avaliação profissional.',
    fr: 'Ces informations sont éducatives. Elles ne servent pas au diagnostic et ne remplacent pas une évaluation professionnelle.',
    de: 'Diese Informationen sind pädagogisch. Sie dienen nicht der Diagnose und ersetzen keine professionelle Beurteilung.',
  );
  String get sources => _pick(
    es: 'Fuentes',
    en: 'Sources',
    pt: 'Fontes',
    fr: 'Sources',
    de: 'Quellen',
  );
  String get seekHelp => _pick(
    es: 'Buscar ayuda',
    en: 'Find help',
    pt: 'Buscar ajuda',
    fr: 'Chercher de l’aide',
    de: 'Hilfe suchen',
  );
  String get seekHelpBody => _pick(
    es: 'Si algo de esto se parece a una dificultad real en tu vida, habla con un profesional de salud mental o con una persona de confianza. Si hay peligro inmediato, usa los servicios de emergencia de tu zona.',
    en: 'If any of this resembles a real difficulty in your life, talk with a mental health professional or someone you trust. If there is immediate danger, use your local emergency services.',
    pt: 'Se algo disso parece uma dificuldade real na sua vida, fale com um profissional de saúde mental ou com alguém de confiança. Se houver perigo imediato, use os serviços de emergência locais.',
    fr: 'Si cela ressemble à une difficulté réelle dans ta vie, parle avec un professionnel de santé mentale ou une personne de confiance. En cas de danger immédiat, utilise les services d’urgence locaux.',
    de: 'Wenn dir etwas davon als echte Schwierigkeit in deinem Leben bekannt vorkommt, sprich mit einer Fachperson für psychische Gesundheit oder einer vertrauten Person. Bei unmittelbarer Gefahr nutze den örtlichen Notdienst.',
  );
  String get close => _pick(
    es: 'Cerrar',
    en: 'Close',
    pt: 'Fechar',
    fr: 'Fermer',
    de: 'Schließen',
  );
  String get aboutTitle => _pick(
    es: 'Acerca de',
    en: 'About',
    pt: 'Sobre',
    fr: 'À propos',
    de: 'Über',
  );
  String get aboutBody => _pick(
    es: 'NBND es un juego radial minimalista sobre percepción, ritmo y respuesta.',
    en: 'NBND is a minimalist radial game about perception, rhythm, and response.',
    pt: 'NBND é um jogo radial minimalista sobre percepção, ritmo e resposta.',
    fr: 'NBND est un jeu radial minimaliste sur la perception, le rythme et la réponse.',
    de: 'NBND ist ein minimalistisches Radialspiel über Wahrnehmung, Rhythmus und Reaktion.',
  );
  String get aboutThanks => _pick(
    es: 'Gracias a Ahris, Ariadna y Victoria por su aporte de inspiración a este proyecto.',
    en: 'Thanks to Ahris, Ariadna, and Victoria for their inspirational contribution to this project.',
    pt: 'Obrigado a Ahris, Ariadna e Victoria pela contribuição de inspiração a este projeto.',
    fr: 'Merci à Ahris, Ariadna et Victoria pour leur apport d’inspiration à ce projet.',
    de: 'Danke an Ahris, Ariadna und Victoria für ihren inspirierenden Beitrag zu diesem Projekt.',
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
  String get hapticsDescription => _pick(
    es: 'Respuesta táctil al activar poderes o perder.',
    en: 'Haptic feedback when activating powers or losing.',
    pt: 'Resposta tátil ao ativar poderes ou perder.',
    fr: 'Retour haptique lors d’un pouvoir ou d’une défaite.',
    de: 'Haptisches Feedback bei Kräften oder einer Niederlage.',
  );
  String get reducedFlashesDescription => _pick(
    es: 'Suaviza cambios de intensidad y proximidad.',
    en: 'Softens changes in intensity and proximity.',
    pt: 'Suaviza mudanças de intensidade e proximidade.',
    fr: 'Adoucit les variations d’intensité et de proximité.',
    de: 'Mildert Änderungen von Intensität und Nähe.',
  );
  String get practiceModeDescription => _pick(
    es: 'Reduce la velocidad general aproximadamente un 28 %.',
    en: 'Reduces overall speed by approximately 28%.',
    pt: 'Reduz a velocidade geral em aproximadamente 28%.',
    fr: 'Réduit la vitesse générale d’environ 28 %.',
    de: 'Reduziert die Gesamtgeschwindigkeit um etwa 28 %.',
  );
  String get adSpaceDescription => _pick(
    es: 'Muestra el banner superior de AdMob.',
    en: 'Shows the AdMob banner at the top.',
    pt: 'Mostra o banner do AdMob na parte superior.',
    fr: 'Affiche la bannière AdMob en haut.',
    de: 'Zeigt das AdMob-Banner oben an.',
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
  String get play =>
      _pick(es: 'Jugar', en: 'Play', pt: 'Jogar', fr: 'Jouer', de: 'Spielen');
  String playWith(String code) => _pick(
    es: 'Jugar con $code',
    en: 'Play with $code',
    pt: 'Jogar com $code',
    fr: 'Jouer avec $code',
    de: 'Mit $code spielen',
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
  String get pauseTitle =>
      _pick(es: 'Pausa', en: 'Pause', pt: 'Pausa', fr: 'Pause', de: 'Pause');
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
  String stageLabel(String stage, double seconds) =>
      '${stageName(stage)}  ${seconds.toStringAsFixed(1)} s';
  String stageName(String stage) => switch (stage) {
    'resonance' => _pick(
      es: 'RESONANCIA',
      en: 'RESONANCE',
      pt: 'RESSONÂNCIA',
      fr: 'RÉSONANCE',
      de: 'RESONANZ',
    ),
    'fracture' => _pick(
      es: 'FRACTURA',
      en: 'FRACTURE',
      pt: 'FRATURA',
      fr: 'FRACTURE',
      de: 'BRUCH',
    ),
    _ => _pick(
      es: 'PULSO',
      en: 'PULSE',
      pt: 'PULSO',
      fr: 'PULSATION',
      de: 'PULS',
    ),
  };
  String flowLine(int passes, double multiplier) => _pick(
    es: 'Flujo x${multiplier.toStringAsFixed(multiplier % 1 == 0 ? 0 : 1)}  $passes cruces',
    en: 'Flow x${multiplier.toStringAsFixed(multiplier % 1 == 0 ? 0 : 1)}  $passes passes',
    pt: 'Fluxo x${multiplier.toStringAsFixed(multiplier % 1 == 0 ? 0 : 1)}  $passes passagens',
    fr: 'Flow x${multiplier.toStringAsFixed(multiplier % 1 == 0 ? 0 : 1)}  $passes passages',
    de: 'Flow x${multiplier.toStringAsFixed(multiplier % 1 == 0 ? 0 : 1)}  $passes Durchgange',
  );
  String get breathingMoment => _pick(
    es: 'RESPIRA',
    en: 'BREATHE',
    pt: 'RESPIRE',
    fr: 'RESPIRE',
    de: 'ATME',
  );
  String get spoonRecovered => _pick(
    es: 'MEDIA CUCHARA RECUPERADA',
    en: 'HALF A SPOON RECOVERED',
    pt: 'MEIA COLHER RECUPERADA',
    fr: 'UNE DEMI-CUILLERE RECUPEREE',
    de: 'EIN HALBER LOFFEL ERHOLT',
  );
  String get clockwise => _pick(
    es: 'HORARIO',
    en: 'CLOCKWISE',
    pt: 'HORÁRIO',
    fr: 'SENS HORAIRE',
    de: 'IM UHRZEIGERSINN',
  );
  String get counterClockwise => _pick(
    es: 'ANTIHORARIO',
    en: 'COUNTERCLOCKWISE',
    pt: 'ANTI-HORÁRIO',
    fr: 'SENS ANTIHORAIRE',
    de: 'GEGEN DEN UHRZEIGERSINN',
  );
  String get touchAndHold => _pick(
    es: 'TOCA Y MANTÉN',
    en: 'TOUCH AND HOLD',
    pt: 'TOQUE E SEGURE',
    fr: 'TOUCHE ET MAINTIENS',
    de: 'BERÜHREN UND HALTEN',
  );
  String reserveSemantics(int current, int maximum) => _pick(
    es: 'Reserva: $current de $maximum medias cucharas',
    en: 'Reserve: $current of $maximum half spoons',
    pt: 'Reserva: $current de $maximum meias colheres',
    fr: 'Réserve : $current sur $maximum demi-cuillères',
    de: 'Reserve: $current von $maximum halben Löffeln',
  );

  String powerName(NeuroType type) => switch (type) {
    NeuroType.tdah => _pick(
      es: 'Impulso',
      en: 'Impulse',
      pt: 'Impulso',
      fr: 'Impulsion',
      de: 'Impuls',
    ),
    NeuroType.tea => _pick(
      es: 'Patrón',
      en: 'Pattern',
      pt: 'Padrão',
      fr: 'Motif',
      de: 'Muster',
    ),
    NeuroType.tlp => _pick(
      es: 'Resonancia',
      en: 'Resonance',
      pt: 'Ressonância',
      fr: 'Résonance',
      de: 'Resonanz',
    ),
    NeuroType.tid => _pick(
      es: 'Perspectivas',
      en: 'Perspectives',
      pt: 'Perspectivas',
      fr: 'Perspectives',
      de: 'Perspektiven',
    ),
    NeuroType.toc => _pick(
      es: 'Secuencia',
      en: 'Sequence',
      pt: 'Sequência',
      fr: 'Séquence',
      de: 'Sequenz',
    ),
    NeuroType.alexitimia => _pick(
      es: 'Silencio',
      en: 'Silence',
      pt: 'Silêncio',
      fr: 'Silence',
      de: 'Stille',
    ),
    NeuroType.anhedonia => _pick(
      es: 'Vacío',
      en: 'Void',
      pt: 'Vazio',
      fr: 'Vide',
      de: 'Leere',
    ),
    NeuroType.tag => _pick(
      es: 'Anticipación',
      en: 'Anticipation',
      pt: 'Antecipação',
      fr: 'Anticipation',
      de: 'Vorahnung',
    ),
  };

  String neuroTypeName(NeuroType type) => switch (type) {
    NeuroType.tdah => _pick(
      es: 'Trastorno por déficit de atención e hiperactividad',
      en: 'Attention deficit hyperactivity disorder',
      pt: 'Transtorno do déficit de atenção e hiperatividade',
      fr: 'Trouble du déficit de l’attention avec hyperactivité',
      de: 'Aufmerksamkeitsdefizit-Hyperaktivitätsstörung',
    ),
    NeuroType.tea => _pick(
      es: 'Trastorno del espectro autista',
      en: 'Autism spectrum disorder',
      pt: 'Transtorno do espectro autista',
      fr: 'Trouble du spectre de l’autisme',
      de: 'Autismus-Spektrum-Störung',
    ),
    NeuroType.tlp => _pick(
      es: 'Trastorno límite de la personalidad',
      en: 'Borderline personality disorder',
      pt: 'Transtorno de personalidade borderline',
      fr: 'Trouble de la personnalité borderline',
      de: 'Borderline-Persönlichkeitsstörung',
    ),
    NeuroType.tid => _pick(
      es: 'Trastorno de identidad disociativo',
      en: 'Dissociative identity disorder',
      pt: 'Transtorno dissociativo de identidade',
      fr: 'Trouble dissociatif de l’identité',
      de: 'Dissoziative Identitätsstörung',
    ),
    NeuroType.toc => _pick(
      es: 'Trastorno obsesivo-compulsivo',
      en: 'Obsessive-compulsive disorder',
      pt: 'Transtorno obsessivo-compulsivo',
      fr: 'Trouble obsessionnel compulsif',
      de: 'Zwangsstörung',
    ),
    NeuroType.alexitimia => _pick(
      es: 'Alexitimia',
      en: 'Alexithymia',
      pt: 'Alexitimia',
      fr: 'Alexithymie',
      de: 'Alexithymie',
    ),
    NeuroType.anhedonia => _pick(
      es: 'Anhedonia',
      en: 'Anhedonia',
      pt: 'Anedonia',
      fr: 'Anhédonie',
      de: 'Anhedonie',
    ),
    NeuroType.tag => _pick(
      es: 'Trastorno de ansiedad generalizada',
      en: 'Generalized anxiety disorder',
      pt: 'Transtorno de ansiedade generalizada',
      fr: 'Trouble anxieux généralisé',
      de: 'Generalisierte Angststörung',
    ),
  };

  String neuroDescription(NeuroType type) => switch (type) {
    NeuroType.tdah => _pick(
      es: 'Movimiento rápido y un hiperfoco que ralentiza el entorno.',
      en: 'Fast movement and hyperfocus that slows the environment.',
      pt: 'Movimento rápido e hiperfoco que desacelera o ambiente.',
      fr: 'Mouvement rapide et hyperfocus qui ralentit l’environnement.',
      de: 'Schnelle Bewegung und Hyperfokus, der die Umgebung verlangsamt.',
    ),
    NeuroType.tea => _pick(
      es: 'Patrones legibles, vista previa y estabilidad ante cambios bruscos.',
      en: 'Readable patterns, previews, and stability through sudden changes.',
      pt: 'Padrões legíveis, prévia e estabilidade diante de mudanças bruscas.',
      fr: 'Motifs lisibles, aperçu et stabilité face aux changements brusques.',
      de: 'Lesbare Muster, Vorschau und Stabilität bei plötzlichen Änderungen.',
    ),
    NeuroType.tlp => _pick(
      es: 'La cercanía al peligro carga una onda protectora.',
      en: 'Proximity to danger charges a protective wave.',
      pt: 'A proximidade do perigo carrega uma onda protetora.',
      fr: 'La proximité du danger charge une onde protectrice.',
      de: 'Die Nähe zur Gefahr lädt eine schützende Welle auf.',
    ),
    NeuroType.tid => _pick(
      es: 'Cambia de perspectiva y salta al punto opuesto.',
      en: 'Switches perspective and jumps to the opposite point.',
      pt: 'Muda de perspectiva e salta para o ponto oposto.',
      fr: 'Change de perspective et saute au point opposé.',
      de: 'Wechselt die Perspektive und springt zum Gegenpunkt.',
    ),
    NeuroType.toc => _pick(
      es: 'Secuencias predecibles y capacidad de alinear una abertura.',
      en: 'Predictable sequences and the ability to align an opening.',
      pt: 'Sequências previsíveis e capacidade de alinhar uma abertura.',
      fr: 'Séquences prévisibles et capacité à aligner une ouverture.',
      de: 'Vorhersehbare Sequenzen und die Fähigkeit, eine Öffnung auszurichten.',
    ),
    NeuroType.alexitimia => _pick(
      es: 'Menor velocidad, más reserva y lectura interna reducida.',
      en: 'Lower speed, more reserve, and reduced internal feedback.',
      pt: 'Menor velocidade, mais reserva e leitura interna reduzida.',
      fr: 'Vitesse réduite, réserve accrue et retour interne atténué.',
      de: 'Weniger Tempo, mehr Reserve und reduzierte innere Rückmeldung.',
    ),
    NeuroType.anhedonia => _pick(
      es: 'Inmunidad absoluta durante un breve momento.',
      en: 'Absolute immunity for a brief moment.',
      pt: 'Imunidade absoluta por um breve momento.',
      fr: 'Immunité absolue pendant un bref instant.',
      de: 'Absolute Immunität für einen kurzen Moment.',
    ),
    NeuroType.tag => _pick(
      es: 'Anticipa riesgos y retrocede cuando una decisión falla.',
      en: 'Anticipates risk and rewinds when a decision fails.',
      pt: 'Antecipa riscos e retrocede quando uma decisão falha.',
      fr: 'Anticipe les risques et remonte le temps après une erreur.',
      de: 'Erkennt Risiken und spult nach einer Fehlentscheidung zurück.',
    ),
  };

  String profileWhatItIs(NeuroType type) => switch (type) {
    NeuroType.tdah => _pick(
      es: 'El TDAH se asocia con patrones persistentes de inatención, hiperactividad o impulsividad. No es una falta de interés ni de esfuerzo.',
      en: 'ADHD is associated with persistent patterns of inattention, hyperactivity, or impulsivity. It is not a lack of interest or effort.',
      pt: 'O TDAH se associa a padrões persistentes de desatenção, hiperatividade ou impulsividade. Não é falta de interesse nem de esforço.',
      fr: 'Le TDAH est associé à des schémas persistants d’inattention, d’hyperactivité ou d’impulsivité. Ce n’est pas un manque d’intérêt ou d’effort.',
      de: 'ADHS ist mit anhaltenden Mustern von Unaufmerksamkeit, Hyperaktivität oder Impulsivität verbunden. Es ist kein Mangel an Interesse oder Anstrengung.',
    ),
    NeuroType.tea => _pick(
      es: 'El espectro autista reúne formas diversas de procesar comunicación, estímulos, rutinas e intereses. Puede incluir fortalezas y necesidades de apoyo distintas en cada persona.',
      en: 'The autism spectrum includes diverse ways of processing communication, stimuli, routines, and interests. Strengths and support needs differ by person.',
      pt: 'O espectro autista reúne formas diversas de processar comunicação, estímulos, rotinas e interesses. Forças e apoios variam em cada pessoa.',
      fr: 'Le spectre autistique regroupe différentes façons de traiter la communication, les stimuli, les routines et les intérêts. Les forces et besoins varient selon la personne.',
      de: 'Das Autismus-Spektrum umfasst unterschiedliche Arten, Kommunikation, Reize, Routinen und Interessen zu verarbeiten. Stärken und Unterstützungsbedarf sind individuell.',
    ),
    NeuroType.tlp => _pick(
      es: 'El TLP puede incluir dificultad para regular emociones intensas, impulsividad y cambios en la imagen de uno mismo o en las relaciones.',
      en: 'BPD can involve difficulty regulating intense emotions, impulsivity, and shifts in self-image or relationships.',
      pt: 'O TPB pode incluir dificuldade para regular emoções intensas, impulsividade e mudanças na autoimagem ou nas relações.',
      fr: 'Le trouble borderline peut inclure une difficulté à réguler des émotions intenses, de l’impulsivité et des variations de l’image de soi ou des relations.',
      de: 'Borderline kann Schwierigkeiten bei der Regulation intensiver Gefühle, Impulsivität und Veränderungen im Selbstbild oder in Beziehungen beinhalten.',
    ),
    NeuroType.tid => _pick(
      es: 'El TID pertenece a los trastornos disociativos y se relaciona con alteraciones de memoria, identidad, percepción y sentido del yo.',
      en: 'DID belongs to dissociative disorders and relates to disruptions in memory, identity, perception, and sense of self.',
      pt: 'O TDI pertence aos transtornos dissociativos e se relaciona a alterações de memória, identidade, percepção e senso de si.',
      fr: 'Le TDI fait partie des troubles dissociatifs et se relie à des perturbations de la mémoire, de l’identité, de la perception et du sentiment de soi.',
      de: 'DIS gehört zu den dissoziativen Störungen und betrifft Störungen von Gedächtnis, Identität, Wahrnehmung und Selbstgefühl.',
    ),
    NeuroType.toc => _pick(
      es: 'El TOC puede incluir obsesiones, que son pensamientos intrusivos y recurrentes, y compulsiones, que son conductas o actos mentales repetitivos.',
      en: 'OCD can include obsessions, meaning intrusive recurring thoughts, and compulsions, meaning repetitive behaviors or mental acts.',
      pt: 'O TOC pode incluir obsessões, pensamentos intrusivos e recorrentes, e compulsões, comportamentos ou atos mentais repetitivos.',
      fr: 'Le TOC peut inclure des obsessions, pensées intrusives récurrentes, et des compulsions, comportements ou actes mentaux répétitifs.',
      de: 'Zwangsstörungen können Obsessionen, also aufdringliche wiederkehrende Gedanken, und Zwänge, also wiederholte Handlungen oder mentale Akte, umfassen.',
    ),
    NeuroType.alexitimia => _pick(
      es: 'La alexitimia describe dificultad para identificar, diferenciar o expresar estados emocionales. Puede aparecer con distintas condiciones o como rasgo personal.',
      en: 'Alexithymia describes difficulty identifying, differentiating, or expressing emotional states. It can appear with different conditions or as a personal trait.',
      pt: 'A alexitimia descreve dificuldade para identificar, diferenciar ou expressar estados emocionais. Pode aparecer com diferentes condições ou como traço pessoal.',
      fr: 'L’alexithymie décrit une difficulté à identifier, différencier ou exprimer les états émotionnels. Elle peut apparaître avec différentes conditions ou comme trait personnel.',
      de: 'Alexithymie beschreibt Schwierigkeiten, emotionale Zustände zu erkennen, zu unterscheiden oder auszudrücken. Sie kann bei verschiedenen Zuständen oder als Merkmal auftreten.',
    ),
    NeuroType.anhedonia => _pick(
      es: 'La anhedonia es una reducción de la capacidad de sentir interés o placer. Puede aparecer como síntoma en diferentes problemas de salud mental.',
      en: 'Anhedonia is a reduced ability to feel interest or pleasure. It can appear as a symptom in different mental health conditions.',
      pt: 'A anedonia é uma redução da capacidade de sentir interesse ou prazer. Pode aparecer como sintoma em diferentes condições de saúde mental.',
      fr: 'L’anhédonie est une réduction de la capacité à ressentir de l’intérêt ou du plaisir. Elle peut apparaître comme symptôme dans différents problèmes de santé mentale.',
      de: 'Anhedonie ist eine verminderte Fähigkeit, Interesse oder Freude zu empfinden. Sie kann als Symptom bei unterschiedlichen psychischen Problemen auftreten.',
    ),
    NeuroType.tag => _pick(
      es: 'El TAG se asocia con preocupación excesiva y difícil de controlar. No es simplemente preocuparse mucho.',
      en: 'GAD is associated with excessive worry that is difficult to control. It is not simply worrying a lot.',
      pt: 'O TAG se associa a preocupação excessiva e difícil de controlar. Não é simplesmente se preocupar muito.',
      fr: 'Le trouble anxieux généralisé est associé à une inquiétude excessive et difficile à contrôler. Ce n’est pas simplement beaucoup s’inquiéter.',
      de: 'Generalisierte Angst ist mit übermäßiger, schwer kontrollierbarer Sorge verbunden. Es bedeutet nicht einfach, sich viel Sorgen zu machen.',
    ),
  };

  String profileHowItCanFeel(NeuroType type) => switch (type) {
    NeuroType.tdah => _pick(
      es: 'Puede sentirse como saltar entre estímulos, perder el hilo o entrar en una concentración muy intensa por momentos.',
      en: 'It can feel like jumping between stimuli, losing the thread, or entering very intense focus at times.',
      pt: 'Pode parecer saltar entre estímulos, perder o fio ou entrar em concentração muito intensa em certos momentos.',
      fr: 'Cela peut ressembler à passer d’un stimulus à l’autre, perdre le fil ou entrer parfois dans une concentration très intense.',
      de: 'Es kann sich anfühlen wie ein Springen zwischen Reizen, den Faden verlieren oder zeitweise sehr intensive Konzentration.',
    ),
    NeuroType.tea => _pick(
      es: 'Puede sentirse como necesitar previsibilidad, notar patrones con mucha precisión o saturarse ante cambios y estímulos intensos.',
      en: 'It can feel like needing predictability, noticing patterns precisely, or becoming overwhelmed by change and intense stimuli.',
      pt: 'Pode parecer precisar de previsibilidade, notar padrões com precisão ou se sobrecarregar com mudanças e estímulos intensos.',
      fr: 'Cela peut ressembler à un besoin de prévisibilité, une perception précise des motifs ou une surcharge face aux changements et stimuli intenses.',
      de: 'Es kann sich anfühlen wie ein Bedürfnis nach Vorhersehbarkeit, genaues Erkennen von Mustern oder Überforderung durch Veränderungen und starke Reize.',
    ),
    NeuroType.tlp => _pick(
      es: 'Algunas personas describen emociones que suben muy rápido, miedo al abandono o dificultad para volver a un punto estable.',
      en: 'Some people describe emotions rising very quickly, fear of abandonment, or difficulty returning to a stable point.',
      pt: 'Algumas pessoas descrevem emoções que sobem muito rápido, medo de abandono ou dificuldade para voltar a um ponto estável.',
      fr: 'Certaines personnes décrivent des émotions qui montent très vite, une peur de l’abandon ou une difficulté à retrouver un point stable.',
      de: 'Manche Menschen beschreiben Gefühle, die sehr schnell ansteigen, Angst vor Verlassenwerden oder Schwierigkeiten, wieder Stabilität zu finden.',
    ),
    NeuroType.tid => _pick(
      es: 'Puede sentirse como desconexión, vacíos de memoria o cambios en la forma de percibirse a sí mismo y al entorno.',
      en: 'It can feel like disconnection, memory gaps, or shifts in how the self and surroundings are perceived.',
      pt: 'Pode parecer desconexão, lacunas de memória ou mudanças na forma de perceber a si mesmo e o ambiente.',
      fr: 'Cela peut ressembler à une déconnexion, des trous de mémoire ou des changements dans la perception de soi et de l’environnement.',
      de: 'Es kann sich wie Abgetrenntsein, Erinnerungslücken oder Veränderungen in der Wahrnehmung von sich selbst und der Umgebung anfühlen.',
    ),
    NeuroType.toc => _pick(
      es: 'Algunas personas sienten que deben comprobar, repetir o completar algo para aliviar temporalmente una angustia intensa.',
      en: 'Some people feel they must check, repeat, or complete something to temporarily relieve intense distress.',
      pt: 'Algumas pessoas sentem que precisam verificar, repetir ou completar algo para aliviar temporariamente uma angústia intensa.',
      fr: 'Certaines personnes sentent qu’elles doivent vérifier, répéter ou compléter quelque chose pour soulager temporairement une forte angoisse.',
      de: 'Manche Menschen haben das Gefühl, etwas prüfen, wiederholen oder abschließen zu müssen, um starke Belastung vorübergehend zu lindern.',
    ),
    NeuroType.alexitimia => _pick(
      es: 'Puede sentirse como saber que algo ocurre por dentro, pero no encontrar una palabra clara para nombrarlo.',
      en: 'It can feel like knowing something is happening inside, but not finding a clear word for it.',
      pt: 'Pode parecer saber que algo acontece por dentro, mas não encontrar uma palavra clara para nomear.',
      fr: 'Cela peut ressembler à savoir que quelque chose se passe à l’intérieur sans trouver un mot clair pour le nommer.',
      de: 'Es kann sich anfühlen, als wüsste man, dass innerlich etwas passiert, findet aber kein klares Wort dafür.',
    ),
    NeuroType.anhedonia => _pick(
      es: 'Puede sentirse como una baja respuesta a cosas que antes importaban, interesaban o daban placer.',
      en: 'It can feel like a muted response to things that used to matter, interest, or bring pleasure.',
      pt: 'Pode parecer uma resposta reduzida a coisas que antes importavam, interessavam ou davam prazer.',
      fr: 'Cela peut ressembler à une réponse atténuée aux choses qui comptaient, intéressaient ou donnaient du plaisir avant.',
      de: 'Es kann sich wie eine gedämpfte Reaktion auf Dinge anfühlen, die früher wichtig, interessant oder erfreulich waren.',
    ),
    NeuroType.tag => _pick(
      es: 'Puede sentirse como revisar riesgos una y otra vez, anticipar escenarios y no poder apagar la alarma interna.',
      en: 'It can feel like reviewing risks again and again, anticipating scenarios, and being unable to turn off the internal alarm.',
      pt: 'Pode parecer revisar riscos repetidamente, antecipar cenários e não conseguir desligar o alarme interno.',
      fr: 'Cela peut ressembler à revoir les risques encore et encore, anticiper des scénarios et ne pas pouvoir éteindre l’alarme interne.',
      de: 'Es kann sich anfühlen wie ständiges Prüfen von Risiken, Vorwegnehmen von Szenarien und die innere Alarmanlage nicht abschalten können.',
    ),
  };

  String profileWhatItDoesNotMean(NeuroType type) => switch (type) {
    NeuroType.tdah => _pick(
      es: 'No significa falta de interés o esfuerzo.',
      en: 'It does not mean lack of interest or effort.',
      pt: 'Não significa falta de interesse ou esforço.',
      fr: 'Cela ne signifie pas un manque d’intérêt ou d’effort.',
      de: 'Es bedeutet keinen Mangel an Interesse oder Anstrengung.',
    ),
    NeuroType.tea => _pick(
      es: 'No significa falta de sentimientos.',
      en: 'It does not mean lack of feelings.',
      pt: 'Não significa falta de sentimentos.',
      fr: 'Cela ne signifie pas une absence de sentiments.',
      de: 'Es bedeutet nicht, keine Gefühle zu haben.',
    ),
    NeuroType.tlp => _pick(
      es: 'No significa manipulación ni que la persona sea su diagnóstico.',
      en: 'It does not mean manipulation, and the person is not their diagnosis.',
      pt: 'Não significa manipulação nem que a pessoa seja seu diagnóstico.',
      fr: 'Cela ne signifie pas manipulation, et la personne ne se réduit pas à son diagnostic.',
      de: 'Es bedeutet nicht Manipulation, und die Person ist nicht ihre Diagnose.',
    ),
    NeuroType.tid => _pick(
      es: 'No significa personalidad malvada ni espectáculo.',
      en: 'It does not mean an evil personality or a spectacle.',
      pt: 'Não significa personalidade malvada nem espetáculo.',
      fr: 'Cela ne signifie pas personnalité malveillante ni spectacle.',
      de: 'Es bedeutet keine böse Persönlichkeit und kein Spektakel.',
    ),
    NeuroType.toc => _pick(
      es: 'No significa únicamente limpieza, orden o perfeccionismo.',
      en: 'It does not only mean cleaning, order, or perfectionism.',
      pt: 'Não significa apenas limpeza, ordem ou perfeccionismo.',
      fr: 'Cela ne signifie pas seulement propreté, ordre ou perfectionnisme.',
      de: 'Es bedeutet nicht nur Sauberkeit, Ordnung oder Perfektionismus.',
    ),
    NeuroType.alexitimia => _pick(
      es: 'No significa no tener emociones.',
      en: 'It does not mean having no emotions.',
      pt: 'Não significa não ter emoções.',
      fr: 'Cela ne signifie pas ne pas avoir d’émotions.',
      de: 'Es bedeutet nicht, keine Gefühle zu haben.',
    ),
    NeuroType.anhedonia => _pick(
      es: 'No significa pereza ni ingratitud.',
      en: 'It does not mean laziness or ingratitude.',
      pt: 'Não significa preguiça nem ingratidão.',
      fr: 'Cela ne signifie pas paresse ou ingratitude.',
      de: 'Es bedeutet nicht Faulheit oder Undankbarkeit.',
    ),
    NeuroType.tag => _pick(
      es: 'No es simplemente preocuparse mucho.',
      en: 'It is not simply worrying a lot.',
      pt: 'Não é simplesmente se preocupar muito.',
      fr: 'Ce n’est pas simplement beaucoup s’inquiéter.',
      de: 'Es bedeutet nicht einfach, sich viel Sorgen zu machen.',
    ),
  };

  String profileNbndRepresentation(NeuroType type) => switch (type) {
    NeuroType.tdah => _pick(
      es: 'Impulso representa cambios rápidos de atención e hiperfoco.',
      en: 'Impulse represents quick attention shifts and hyperfocus.',
      pt: 'Impulso representa mudanças rápidas de atenção e hiperfoco.',
      fr: 'Impulsion représente les changements rapides d’attention et l’hyperfocus.',
      de: 'Impuls steht für schnelle Aufmerksamkeitswechsel und Hyperfokus.',
    ),
    NeuroType.tea => _pick(
      es: 'Patrón representa reconocimiento de regularidades y necesidad de previsibilidad.',
      en: 'Pattern represents recognizing regularities and needing predictability.',
      pt: 'Padrão representa reconhecer regularidades e precisar de previsibilidade.',
      fr: 'Motif représente la reconnaissance des régularités et le besoin de prévisibilité.',
      de: 'Muster steht für das Erkennen von Regelmäßigkeiten und das Bedürfnis nach Vorhersehbarkeit.',
    ),
    NeuroType.tlp => _pick(
      es: 'Resonancia representa intensidad emocional y regulación.',
      en: 'Resonance represents emotional intensity and regulation.',
      pt: 'Ressonância representa intensidade emocional e regulação.',
      fr: 'Résonance représente l’intensité émotionnelle et la régulation.',
      de: 'Resonanz steht für emotionale Intensität und Regulation.',
    ),
    NeuroType.tid => _pick(
      es: 'Perspectivas representa cambios en la experiencia del yo sin convertirlos en espectáculo.',
      en: 'Perspectives represents shifts in self-experience without turning them into spectacle.',
      pt: 'Perspectivas representa mudanças na experiência do eu sem transformá-las em espetáculo.',
      fr: 'Perspectives représente des changements dans l’expérience de soi sans les transformer en spectacle.',
      de: 'Perspektiven steht für Veränderungen im Selbsterleben, ohne sie zum Spektakel zu machen.',
    ),
    NeuroType.toc => _pick(
      es: 'Secuencia representa presión por completar patrones y seguir adelante sin perfección.',
      en: 'Sequence represents pressure to complete patterns and keep going without perfection.',
      pt: 'Sequência representa a pressão por completar padrões e continuar sem perfeição.',
      fr: 'Séquence représente la pression de compléter des motifs et de continuer sans perfection.',
      de: 'Sequenz steht für den Druck, Muster abzuschließen und ohne Perfektion weiterzugehen.',
    ),
    NeuroType.alexitimia => _pick(
      es: 'Silencio representa dificultad para identificar o expresar estados emocionales.',
      en: 'Silence represents difficulty identifying or expressing emotional states.',
      pt: 'Silêncio representa dificuldade para identificar ou expressar estados emocionais.',
      fr: 'Silence représente la difficulté à identifier ou exprimer des états émotionnels.',
      de: 'Stille steht für Schwierigkeiten, emotionale Zustände zu erkennen oder auszudrücken.',
    ),
    NeuroType.anhedonia => _pick(
      es: 'Vacío representa una reducción temporal de la respuesta al entorno.',
      en: 'Void represents a temporary reduction in response to the environment.',
      pt: 'Vazio representa uma redução temporária da resposta ao ambiente.',
      fr: 'Vide représente une réduction temporaire de la réponse à l’environnement.',
      de: 'Leere steht für eine vorübergehende Verringerung der Reaktion auf die Umgebung.',
    ),
    NeuroType.tag => _pick(
      es: 'Anticipación representa preocupación persistente y evaluación constante del riesgo.',
      en: 'Anticipation represents persistent worry and constant risk evaluation.',
      pt: 'Antecipação representa preocupação persistente e avaliação constante de risco.',
      fr: 'Anticipation représente l’inquiétude persistante et l’évaluation constante du risque.',
      de: 'Vorahnung steht für anhaltende Sorge und ständige Risikobewertung.',
    ),
  };

  String profileSources(NeuroType type) => switch (type) {
    NeuroType.tid => 'American Psychiatric Association: Dissociative Disorders',
    NeuroType.tlp =>
      'National Institute of Mental Health: Borderline Personality Disorder',
    NeuroType.toc =>
      'National Institute of Mental Health: Obsessive-Compulsive Disorder',
    NeuroType.tdah => 'National Institute of Mental Health: ADHD',
    NeuroType.tag => 'National Institute of Mental Health: Anxiety Disorders',
    NeuroType.tea =>
      'National Institute of Mental Health: Autism Spectrum Disorder',
    NeuroType.alexitimia =>
      'Contenido educativo general; revisar con profesionales de salud mental.',
    NeuroType.anhedonia =>
      'Contenido educativo general; revisar con profesionales de salud mental.',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
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
