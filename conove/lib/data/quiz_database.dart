import '../models/quiz_question.dart';
import '../models/category.dart';

class QuizDatabase {
  static const List<QuizQuestion> questions = [
    // --- QUIZ CON OPCIONES VISUALES (GRID DE TARJETAS CON IMÁGENES) ---
    QuizQuestion(
      id: 'q_visual_duchenne',
      category: CategoryType.expresionesFaciales,
      prompt: '¿Cuál de las siguientes imágenes corresponde a una Sonrisa Genuina (Duchenne)?',
      scenarioText: 'Observa detenidamente la activación muscular alrededor de los ojos y las mejillas.',
      options: [
        QuizOption(
          id: 'opt_duchenne',
          text: 'Sonrisa A',
          subtext: 'Ojos con arrugas perioculares y mejillas elevadas',
          illustrationKey: 'duchenne_smile',
          isCorrect: true,
        ),
        QuizOption(
          id: 'opt_polite',
          text: 'Sonrisa B',
          subtext: 'Solo labios estirados, ojos estáticos',
          illustrationKey: 'polite_smile',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_smirk',
          text: 'Sonrisa C',
          subtext: 'Una sola comisura elevada',
          illustrationKey: 'smirk_contempt',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_tight',
          text: 'Sonrisa D',
          subtext: 'Labios comprimidos en línea recta',
          illustrationKey: 'tight_lips',
          isCorrect: false,
        ),
      ],
      keyVisualClue: 'Contracción del músculo orbicular (arrugas "patas de gallo" y ojos achinados).',
      explanation:
          'La Sonrisa de Duchenne (Sonrisa A) involucra involuntariamente el músculo orbicular de los ojos, generando arrugas en los laterales de los ojos. En la Sonrisa Social (B), solo se activa la boca, lo cual denota cortesía o agrado fingido.',
    ),
    QuizQuestion(
      id: 'q_visual_posture_open',
      category: CategoryType.lenguajeCorporal,
      prompt: '¿Cuál de estas figuras muestra una Postura Abierta y Receptiva para negociar?',
      scenarioText: 'En ventas y liderazgo, la apertura corporal genera confianza y disminuye la resistencia.',
      options: [
        QuizOption(
          id: 'opt_closed',
          text: 'Figura A',
          subtext: 'Brazos cruzados en el pecho',
          illustrationKey: 'closed_posture',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_open',
          text: 'Figura B',
          subtext: 'Brazos relajados, pecho despejado',
          illustrationKey: 'open_posture',
          isCorrect: true,
        ),
        QuizOption(
          id: 'opt_leanback',
          text: 'Figura C',
          subtext: 'Cuerpo inclinado hacia atrás',
          illustrationKey: 'leaning_back',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_shrug',
          text: 'Figura D',
          subtext: 'Hombros elevados con palmas arriba',
          illustrationKey: 'shrug',
          isCorrect: false,
        ),
      ],
      keyVisualClue: 'Pecho despejado sin barreras de brazos y postura erguida pero relajada.',
      explanation:
          'La Figura B representa la postura abierta: los brazos están a los lados, el pecho no está bloqueado por barreras y la orientación es frontal y directa.',
    ),
    QuizQuestion(
      id: 'q_visual_posture_steeple',
      category: CategoryType.lenguajeCorporal,
      prompt: '¿Cuál de las siguientes imágenes muestra la postura de "Manos en Ojiva / Campanario" (Alta confianza y autoridad)?',
      scenarioText: 'Muy utilizada en negociaciones por expertos al plantear conclusiones definitivas.',
      options: [
        QuizOption(
          id: 'opt_steeple',
          text: 'Figura 1',
          subtext: 'Yemas tocándose en pirámide',
          illustrationKey: 'steepling_hands',
          isCorrect: true,
        ),
        QuizOption(
          id: 'opt_wring',
          text: 'Figura 2',
          subtext: 'Fricción de palmas',
          illustrationKey: 'hand_wringing',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_hips',
          text: 'Figura 3',
          subtext: 'Manos en jarra/caderas',
          illustrationKey: 'hands_on_hips',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_neck',
          text: 'Figura 4',
          subtext: 'Mano cubriendo la garganta',
          illustrationKey: 'touching_neck',
          isCorrect: false,
        ),
      ],
      keyVisualClue: 'Puntas de los dedos opuestos en contacto formando una carpa o pirámide simétrica.',
      explanation:
          'La Ojiva (Figura 1) es el gesto clásico de autoconfianza y solvencia intelectual. A diferencia del frotarse las manos (ansiedad o expectativa) o tocarse el cuello (estrés), la ojiva transmite control y convicción absoluta.',
    ),
    QuizQuestion(
      id: 'q_visual_posture_pacifying',
      category: CategoryType.lenguajeCorporal,
      prompt: '¿Cuál de estas posturas es un gesto de "Pacificación o Alivio de Estrés" (calmar la ansiedad)?',
      scenarioText: 'Los gestos pacificadores ocurren cuando el sistema nervioso busca reducir el ritmo cardíaco.',
      options: [
        QuizOption(
          id: 'opt_headtilt',
          text: 'Figura A',
          subtext: 'Cabeza ladeada con sonrisa',
          illustrationKey: 'head_tilt',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_neck_touch',
          text: 'Figura B',
          subtext: 'Mano tocando el hueco del cuello / nuca',
          illustrationKey: 'touching_neck',
          isCorrect: true,
        ),
        QuizOption(
          id: 'opt_behind_head',
          text: 'Figura C',
          subtext: 'Manos entrelazadas en la nuca',
          illustrationKey: 'hands_behind_head',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_behind_back',
          text: 'Figura D',
          subtext: 'Manos tomadas a la espalda',
          illustrationKey: 'hands_behind_back',
          isCorrect: false,
        ),
      ],
      keyVisualClue: 'Mano protegiendo la zona vulnerable del cuello/garganta.',
      explanation:
          'Tocarse el cuello o la fosa suprasternal (Figura B) es una de las respuestas automáticas más universales para mitigar la ansiedad o el estrés ante preguntas difíciles o momentos de tensión.',
    ),
    QuizQuestion(
      id: 'q_visual_posture_empathy',
      category: CategoryType.lenguajeCorporal,
      prompt: '¿Qué postura corporal comunica "Escucha Activa, Empatía y Conexión No Amenazante"?',
      scenarioText: 'Fundamental para generar confianza en conversaciones personales o de ventas consultivas.',
      options: [
        QuizOption(
          id: 'opt_headtilt_correct',
          text: 'Opción 1',
          subtext: 'Cabeza inclinada de lado con cuello expuesto',
          illustrationKey: 'head_tilt',
          isCorrect: true,
        ),
        QuizOption(
          id: 'opt_hips_incorrect',
          text: 'Opción 2',
          subtext: 'Manos en jarras con codos abiertos',
          illustrationKey: 'hands_on_hips',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_pockets_incorrect',
          text: 'Opción 3',
          subtext: 'Manos ocultas en los bolsillos',
          illustrationKey: 'hands_in_pockets',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_leanback_incorrect',
          text: 'Opción 4',
          subtext: 'Cuerpo recostado hacia atrás',
          illustrationKey: 'leaning_back',
          isCorrect: false,
        ),
      ],
      keyVisualClue: 'Inclinación lateral de la cabeza dejando expuesto el cuello de manera amistosa.',
      explanation:
          'Ladear la cabeza (Opción 1) es una señal biológica de sumisión amistosa y empatía: expone la zona sensible del cuello y demuestra atención completa a lo que la otra persona está diciendo.',
    ),

    QuizQuestion(
      id: 'q_visual_desden',
      category: CategoryType.expresionesFaciales,
      prompt: 'Identifica la expresión de Desdén o Desprecio (Superioridad / Sarcasmo):',
      scenarioText: 'Esta microexpresión es crítica en ventas: indica que el interlocutor descalifica la propuesta.',
      options: [
        QuizOption(
          id: 'opt_frown',
          text: 'Expresión 1',
          subtext: 'Ceño fruncido simétrico',
          illustrationKey: 'frowning_brow',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_desden',
          text: 'Expresión 2',
          subtext: 'Media sonrisa asimétrica',
          illustrationKey: 'smirk_contempt',
          isCorrect: true,
        ),
        QuizOption(
          id: 'opt_surprise',
          text: 'Expresión 3',
          subtext: 'Ojos redondos y cejas altas',
          illustrationKey: 'surprised_look',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_wink',
          text: 'Expresión 4',
          subtext: 'Guiño de complicidad',
          illustrationKey: 'winking_face',
          isCorrect: false,
        ),
      ],
      keyVisualClue: 'Asimetría labial: una sola comisura de los labios se eleva hacia un lado.',
      explanation:
          'El desprecio o desdén es la única emoción universalmente asimétrica en el rostro. Se reconoce porque solo un lado de la boca se curva hacia arriba, a menudo con una mirada altiva.',
    ),
    QuizQuestion(
      id: 'q_visual_proxemics',
      category: CategoryType.proxemica,
      prompt: '¿Qué zona de distancia corresponde al Espacio Social (reuniones de negocios y clientes)?',
      scenarioText: 'La proxémica define los límites aceptables en el entorno laboral neurotípico.',
      options: [
        QuizOption(
          id: 'opt_intima',
          text: 'Zona Íntima',
          subtext: '0 a 45 cm (abrazos y susurros)',
          illustrationKey: 'proxemics_intima',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_personal',
          text: 'Zona Personal',
          subtext: '45 cm a 1.2 m (amigos cercanos)',
          illustrationKey: 'proxemics_personal',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_social',
          text: 'Zona Social',
          subtext: '1.2 m a 3.6 m (trabajo y clientes)',
          illustrationKey: 'proxemics_social',
          isCorrect: true,
        ),
        QuizOption(
          id: 'opt_publica',
          text: 'Zona Pública',
          subtext: '+3.6 m (discursos y auditorios)',
          illustrationKey: 'proxemics_publica',
          isCorrect: false,
        ),
      ],
      keyVisualClue: 'El tercer anillo concéntrico (1.2m a 3.6m), equivalente al ancho de una mesa de juntas.',
      explanation:
          'La Zona Social (1.2 a 3.6 metros) es el rango formal seguro para interacciones profesionales y comerciales. Permite interactuar cómodamente sin que ninguna de las partes se sienta invadida.',
    ),
    QuizQuestion(
      id: 'q_visual_paralinguistics_sarcasm',
      category: CategoryType.factoresParalinguisticos,
      prompt: '¿Qué gráfico representa una Inflexión Sarcástica / Tono Irónico?',
      scenarioText: 'En el sarcasmo, la curva tonal se eleva exageradamente y cae de golpe en contradicción con el texto.',
      options: [
        QuizOption(
          id: 'opt_sarcasm_img',
          text: 'Figura 1',
          subtext: 'Curva tonal descendente irónica',
          illustrationKey: 'sarcastic_inflection',
          isCorrect: true,
        ),
        QuizOption(
          id: 'opt_monotone_img',
          text: 'Figura 2',
          subtext: 'Frecuencia plana sin modulación',
          illustrationKey: 'voice_monotone',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_high_vol_img',
          text: 'Figura 3',
          subtext: 'Megáfono de volumen alto',
          illustrationKey: 'voice_volume_high',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_assertive_img',
          text: 'Figura 4',
          subtext: 'Onda sinusoidal armónica',
          illustrationKey: 'assertive_voice',
          isCorrect: false,
        ),
      ],
      keyVisualClue: 'Onda tonal con pico ascendente artificial que se desploma con un remate burlón.',
      explanation:
          'La inflexión sarcástica (Figura 1) rompe la melodía natural del habla modulando en exceso para señalar que las palabras pronunciadas son una ironía.',
    ),
    QuizQuestion(
      id: 'q_visual_environment_round_table',
      category: CategoryType.entornoApariencia,
      prompt: '¿Cuál de las siguientes disposiciones del mobiliario fomenta la Colaboración Igualitaria sin jerarquías?',
      scenarioText: 'La psicología del espacio demuestra que la forma de la mesa influye directamente en la toma de decisiones.',
      options: [
        QuizOption(
          id: 'opt_round_table',
          text: 'Opción A',
          subtext: 'Mesa Redonda colaborativa',
          illustrationKey: 'round_table',
          isCorrect: true,
        ),
        QuizOption(
          id: 'opt_desk_barrier',
          text: 'Opción B',
          subtext: 'Escritorio como barrera de poder',
          illustrationKey: 'desk_barrier',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_seating_l',
          text: 'Opción C',
          subtext: 'Ubicación en esquina 90°',
          illustrationKey: 'seating_angle',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_formal_suit',
          text: 'Opción D',
          subtext: 'Código de vestimenta formal',
          illustrationKey: 'dress_formal',
          isCorrect: false,
        ),
      ],
      keyVisualClue: 'Distribución circular equidistante donde ninguna silla ocupa la cabecera dominante.',
      explanation:
          'La mesa redonda (Opción A) elimina la cabecera del jefe, haciendo que todos los participantes sientan que su opinión tiene el mismo peso y promoviendo la empatía.',
    ),
    QuizQuestion(
      id: 'q_visual_environment_seating_angle',
      category: CategoryType.entornoApariencia,
      prompt: '¿Qué posición en la mesa es la "Esquina Cooperativa a 90°" (ideal para cerrar ventas y evitar confrontación)?',
      scenarioText: 'Sentarse frente a frente (180°) aumenta la resistencia; colocarse a 90° crea sensación de equipo.',
      options: [
        QuizOption(
          id: 'opt_l_angle_img',
          text: 'Disposición 1',
          subtext: 'En L (90 grados) compartiendo mesa',
          illustrationKey: 'seating_angle',
          isCorrect: true,
        ),
        QuizOption(
          id: 'opt_barrier_desk_img',
          text: 'Disposición 2',
          subtext: 'Escritorio frontal macizo',
          illustrationKey: 'desk_barrier',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_circle_table_img',
          text: 'Disposición 3',
          subtext: 'Mesa circular amplia',
          illustrationKey: 'round_table',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_casual_dress_img',
          text: 'Disposición 4',
          subtext: 'Vestimenta casual',
          illustrationKey: 'dress_casual',
          isCorrect: false,
        ),
      ],
      keyVisualClue: 'Dos sillas contiguas en el ángulo de una mesa mirando hacia el mismo documento.',
      explanation:
          'El ángulo de 90° (Disposición 1) es el posicionamiento estratégico más efectivo: elimina el duelo visual cara a cara y permite que cliente y asesor miren juntos la solución.',
    ),
    QuizQuestion(
      id: 'q_visual_facial_jaw_clench',
      category: CategoryType.expresionesFaciales,
      prompt: '¿Cuál de estas expresiones refleja Mandíbula Apretada (Ira contenida / Frustración)?',
      scenarioText: 'Un signo revelador de que la persona está soportando estrés o desacuerdo sin decirlo.',
      options: [
        QuizOption(
          id: 'opt_jaw_img',
          text: 'Expresión A',
          subtext: 'Maseteros en tensión y labios firmes',
          illustrationKey: 'jaw_clenching',
          isCorrect: true,
        ),
        QuizOption(
          id: 'opt_duchenne_img',
          text: 'Expresión B',
          subtext: 'Sonrisa genuina con patas de gallo',
          illustrationKey: 'duchenne_smile',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_eyebrow_img',
          text: 'Expresión C',
          subtext: 'Flash rápido de cejas',
          illustrationKey: 'eyebrow_flash',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_wink_img',
          text: 'Expresión D',
          subtext: 'Guiño de complicidad',
          illustrationKey: 'winking_face',
          isCorrect: false,
        ),
      ],
      keyVisualClue: 'Borde mandibular endurecido y abultamiento en los ángulos de la mandíbula.',
      explanation:
          'Apretar la mandíbula (Expresión A) es un indicador clave de que el interlocutor está conteniendo un reclamo o una gran tensión interna.',
    ),
    QuizQuestion(
      id: 'q_visual_digital_seen_ticks',
      category: CategoryType.comunicacionDigital,
      prompt: '¿Qué ilustración representa el fenómeno de "Dejar en Visto / Doble Check sin Respuesta"?',
      scenarioText: 'En la mensajería moderna, el tiempo transcurrido tras la lectura comunica intención implícita.',
      options: [
        QuizOption(
          id: 'opt_visto_img',
          text: 'Figura A',
          subtext: 'Doble tilde azul con reloj de espera',
          illustrationKey: 'digital_visto',
          isCorrect: true,
        ),
        QuizOption(
          id: 'opt_caps_img',
          text: 'Figura B',
          subtext: 'Burbuja de texto con exclamaciones de grito',
          illustrationKey: 'digital_mayusculas',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_emoji_img',
          text: 'Figura C',
          subtext: 'Emoticono cálido en el chat',
          illustrationKey: 'digital_emojis',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_audio_img',
          text: 'Figura D',
          subtext: 'Nota de voz con barra de reproducción',
          illustrationKey: 'digital_audio',
          isCorrect: false,
        ),
      ],
      keyVisualClue: 'Doble check de confirmación de lectura acompañado de un reloj de espera prolongado.',
      explanation:
          'El doble check azul con reloj (Figura A) simboliza que el mensaje fue recibido y abierto, pero el destinatario eligió postergar o evitar responder.',
    ),

    // --- QUIZZES DE ANÁLISIS DE CASO Y VENTAS ---
    QuizQuestion(
      id: 'q_sales_arms_crossed',
      category: CategoryType.lenguajeCorporal,
      prompt: 'Durante una presentación de ventas, el cliente cruza los brazos y aprieta los labios. ¿Qué significa?',
      questionIllustrationKey: 'closed_posture',
      scenarioText: 'Acabas de mencionar el precio mensual del servicio.',
      options: [
        QuizOption(
          id: 'opt_1',
          text: 'El cliente está muy convencido y listo para firmar el contrato.',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_2',
          text: 'Tiene objeciones no expresadas o desacuerdo con lo que acaba de escuchar.',
          isCorrect: true,
        ),
        QuizOption(
          id: 'opt_3',
          text: 'Solo está cansado físicamente y quiere que sigas hablando más rápido.',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_4',
          text: 'Es una señal de sumisión y aceptación pasiva.',
          isCorrect: false,
        ),
      ],
      keyVisualClue: 'Combinación de barrera física (brazos cruzados) + contención verbal (labios apretados).',
      explanation:
          'Cuando los brazos cruzados se combinan con labios apretados, la persona está reteniendo una objeción o desacuerdo. La mejor respuesta es pausar y preguntar: "¿Qué impresión te da esta cifra?" para permitirle desahogar la duda.',
    ),
    QuizQuestion(
      id: 'q_para_sarcasm',
      category: CategoryType.factoresParalinguisticos,
      prompt: 'Tu compañero te dice "¡Qué maravillosa idea!" arrastrando las palabras y con tono plano. ¿Cómo interpretarlo?',
      questionIllustrationKey: 'narrowed_eyes',
      scenarioText: 'Propusiste trabajar el sábado por la tarde para terminar un informe.',
      options: [
        QuizOption(
          id: 'opt_literal',
          text: 'Literalmente piensa que es una idea brillante y entusiasta.',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_sarcastico',
          text: 'Es un tono sarcástico: en realidad piensa que es una mala idea.',
          isCorrect: true,
        ),
        QuizOption(
          id: 'opt_duda',
          text: 'No escuchó bien y está pidiendo que lo repitas.',
          isCorrect: false,
        ),
      ],
      keyVisualClue: 'Incongruencia entre la palabra positiva ("maravillosa") y el tono descendente/arrastrado.',
      explanation:
          'En la comunicación neurotípica, cuando el tono de voz contradice el significado literal de las palabras, el TONO SIEMPRE TIENE LA PRIORIDAD de significado. Aquí el mensaje real es rechazo.',
    ),
    QuizQuestion(
      id: 'q_digital_caps',
      category: CategoryType.comunicacionDigital,
      prompt: 'Un cliente te envía por WhatsApp: "NECESITO EL REPORTE AHORA MISMO". ¿Qué tono transmite?',
      questionIllustrationKey: 'digital_mayusculas',
      scenarioText: 'Mensajería instantánea en horario laboral.',
      options: [
        QuizOption(
          id: 'opt_normal',
          text: 'Es un mensaje casual sin ninguna emoción particular.',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_grito',
          text: 'Transmite urgencia extrema, enojo o exigencia imperativa (equivalente a gritar).',
          isCorrect: true,
        ),
        QuizOption(
          id: 'opt_positivo',
          text: 'Indica entusiasmo y alegría por recibir el reporte.',
          isCorrect: false,
        ),
      ],
      keyVisualClue: 'Todas las palabras en MAYÚSCULAS sostenidas en comunicación digital.',
      explanation:
          'En el código no escrito de internet, escribir todo en mayúsculas se interpreta casi unánimemente como levantar la voz o gritar con frustración o extrema urgencia.',
    ),
    QuizQuestion(
      id: 'q_leaning_forward_meaning',
      category: CategoryType.lenguajeCorporal,
      prompt: 'En una entrevista de trabajo, el entrevistador se inclina hacia adelante sobre la mesa y asiente. ¿Qué indica?',
      questionIllustrationKey: 'leaning_forward',
      scenarioText: 'Estás describiendo cómo resolviste un problema técnico complejo.',
      options: [
        QuizOption(
          id: 'opt_a',
          text: 'Alto interés, enganche positivo y deseo de escuchar más detalles.',
          isCorrect: true,
        ),
        QuizOption(
          id: 'opt_b',
          text: 'Intimidación y deseo de que te calles de inmediato.',
          isCorrect: false,
        ),
        QuizOption(
          id: 'opt_c',
          text: 'Desinterés y aburrimiento.',
          isCorrect: false,
        ),
      ],
      keyVisualClue: 'Inclinación del torso hacia adelante + asentimiento rítmico.',
      explanation:
          'Inclinarse hacia adelante (*leaning in*) reduce la distancia psicológica y demuestra que la persona está genuinamente interesada en lo que estás diciendo.',
    ),
  ];

  static List<QuizQuestion> getByCategory(CategoryType category) {
    return questions.where((q) => q.category == category).toList();
  }

  static List<QuizQuestion> getImageCardQuestions() {
    return questions.where((q) => q.isImageOptionGrid).toList();
  }
}
