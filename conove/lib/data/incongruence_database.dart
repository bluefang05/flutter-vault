import '../models/incongruence_item.dart';

class IncongruenceDatabase {
  static const List<IncongruenceItem> items = [
    // --- CASO 1 (Ventas): Objeción de precio encubierta ---
    IncongruenceItem(
      id: 'inc_sales_price',
      speakerRole: 'Director de Compras en reunión comercial',
      spokenPhrase: 'El precio me parece bastante razonable y está dentro de nuestro rango...',
      illustrationKey: 'closed_posture',
      physicalSignals: [
        'Brazos fuertemente cruzados formando una barrera',
        'Labios comprimidos en una línea delgada',
        'Cuerpo reclinado ligeramente hacia atrás',
      ],
      isCongruent: false,
      realEmotion: 'Objeción silenciosa sobre el presupuesto o el valor',
      explanation: 'Las palabras dicen que el precio es razonable, pero los brazos cruzados y labios apretados revelan resistencia inconsciente y contención de una queja.',
      recommendedAction: 'No asumas que el precio está cerrado. Haz una pausa y pregunta: "Noto que estás evaluando el impacto, ¿cómo se compara esta inversión con el presupuesto asignado para esta área?"',
      targetAudience: 'sales_focus',
    ),

    // --- CASO 2 (Autismo/Social): Cortesía que oculta impaciencia ---
    IncongruenceItem(
      id: 'inc_social_impatience',
      speakerRole: 'Compañero de trabajo durante una conversación',
      spokenPhrase: 'No te preocupes, tómate todo el tiempo que necesites para explicarlo...',
      illustrationKey: 'finger_tapping',
      physicalSignals: [
        'Tamborileo rítmico e insistente de los dedos en la mesa',
        'Pestañeo acelerado y mirada frecuente hacia la puerta',
        'Cuerpo orientado hacia la salida',
      ],
      isCongruent: false,
      realEmotion: 'Impaciencia, sobrecarga o prisa por terminar',
      explanation: 'El mensaje verbal da permiso cordial de continuar, pero el tamborileo y la orientación hacia la salida indican que su nivel de atención está agotado.',
      recommendedAction: 'Resume tu idea principal en 1 frase y concluye: "En resumen, ese es el punto clave. Si quieres lo revisamos con calma más tarde cuando estés libre".',
      targetAudience: 'autism_focus',
    ),

    // --- CASO 3 (Ventas): Interés genuino y señal de compra (CONGRUENTE) ---
    IncongruenceItem(
      id: 'inc_sales_buying_signal',
      speakerRole: 'Cliente potencial tras ver la demostración',
      spokenPhrase: 'Me gusta mucho cómo resuelve nuestro problema operativo.',
      illustrationKey: 'leaning_forward',
      physicalSignals: [
        'Inclinación del torso hacia adelante sobre la mesa',
        'Sonrisa de Duchenne (mejillas elevadas y arrugas en los ojos)',
        'Palmas de las manos abiertas y visibles',
      ],
      isCongruent: true,
      realEmotion: 'Aprobación genuina, entusiasmo y receptividad de compra',
      explanation: 'Tanto las palabras como la inclinación corporal y la sonrisa de Duchenne concuerdan plenamente. Es una luz verde transparente.',
      recommendedAction: 'Avanza inmediatamente a la propuesta de cierre: "¿Te gustaría que agendemos el inicio de la instalación para este lunes?"',
      targetAudience: 'sales_focus',
    ),

    // --- CASO 4 (Autismo/Social): Desdén o burla oculta ---
    IncongruenceItem(
      id: 'inc_social_contempt',
      speakerRole: 'Conocido en un grupo social tras tu comentario',
      spokenPhrase: '¡Vaya, qué brillante tu opinión! Nunca se me hubiera ocurrido...',
      illustrationKey: 'smirk_contempt',
      physicalSignals: [
        'Elevación unilateral de una sola comisura de los labios (sonrisa torcida)',
        'Cabeza ligeramente inclinada hacia atrás con mirada de reojo',
        'Tono descendente y prolongado',
      ],
      isCongruent: false,
      realEmotion: 'Sarcasmo, desdén o sensación de superioridad',
      explanation: 'La sonrisa asimétrica unilateral es la microexpresión universal de desdén. Las palabras de elogio son irónicas y dicen lo contrario del mensaje real.',
      recommendedAction: 'No reacciones con enfado ni busques su aprobación. Responde de forma neutra y tranquila: "Es una perspectiva más. Sigamos con el tema central".',
      targetAudience: 'autism_focus',
    ),

    // --- CASO 5 (Ventas): Insatisfacción oculta con proveedor actual ---
    IncongruenceItem(
      id: 'inc_sales_supplier_doubt',
      speakerRole: 'Gerente General que evalúa alternativas',
      spokenPhrase: 'Ya tenemos un proveedor actual y la verdad estamos perfectamente con ellos.',
      illustrationKey: 'touching_neck',
      physicalSignals: [
        'Mano tocando y frotando la parte posterior del cuello',
        'Mirada baja esquivando el contacto visual directo',
        'Hombros asimétricos con tensión visible',
      ],
      isCongruent: false,
      realEmotion: 'Incomodidad, estrés o frustración no confesada con su proveedor',
      explanation: 'Tocarse el cuello es un gesto apaciguador que denota estrés e inseguridad. Aunque dice que todo está bien, su cuerpo revela que hay un punto de dolor no resuelto.',
      recommendedAction: 'Abre la brecha con una pregunta no amenazante: "Entiendo perfectamente. Si hubiera una sola cosa que tu proveedor actual pudiera mejorar en los tiempos de entrega, ¿cuál sería?"',
      targetAudience: 'sales_focus',
    ),

    // --- CASO 6 (Autismo/Social): Alegría sincera de bienvenida (CONGRUENTE) ---
    IncongruenceItem(
      id: 'inc_social_sincere_welcome',
      speakerRole: 'Amigo que te recibe en su casa',
      spokenPhrase: '¡Qué alegría que hayas podido venir hoy!',
      illustrationKey: 'eyebrow_flash',
      physicalSignals: [
        'Elevación rápida y espontánea de las cejas (flash de cejas)',
        'Sonrisa amplia mostrando dientes con ojos achinados',
        'Brazos abiertos listos para el saludo',
      ],
      isCongruent: true,
      realEmotion: 'Alegría sincera, afecto y bienvenida auténtica',
      explanation: 'El flash de cejas dura un tercio de segundo y es una señal biológica involuntaria de reconocimiento positivo y afecto genuino.',
      recommendedAction: 'Sonríe con calidez y responde con entusiasmo: "¡Muchas gracias por invitarme! Tenía muchas ganas de verte".',
      targetAudience: 'autism_focus',
    ),

    // --- CASO 7 (Ventas): Autoridad y poder de decisión (CONGRUENTE) ---
    IncongruenceItem(
      id: 'inc_sales_authority_steepling',
      speakerRole: 'Director Ejecutivo al escuchar tu propuesta',
      spokenPhrase: 'Entiendo el alcance. Tomaremos la decisión hoy mismo.',
      illustrationKey: 'steepling_hands',
      physicalSignals: [
        'Manos en ojiva (yemas de los dedos tocándose en forma de pirámide)',
        'Contacto visual sereno y sostenido',
        'Respiración pausada y postura erguida',
      ],
      isCongruent: true,
      realEmotion: 'Máxima seguridad, confianza y autoridad en la decisión',
      explanation: 'Las manos en campanario u ojiva son el reflejo físico de convicción y dominio técnico. El interlocutor tiene el poder y sabe lo que quiere.',
      recommendedAction: 'Mantén una postura asertiva y formal, sin titubear ni sobreexplicar: "Quedo a su disposición para coordinar los contratos hoy mismo".',
      targetAudience: 'sales_focus',
    ),

    // --- CASO 8 (Autismo/Social): Tristeza oculta tras un "Todo bien" ---
    IncongruenceItem(
      id: 'inc_social_hidden_sadness',
      speakerRole: 'Familiar o amigo cercano',
      spokenPhrase: 'No te preocupes por mí, estoy totalmente bien, todo en orden...',
      illustrationKey: 'turned_down_lips',
      physicalSignals: [
        'Comisuras labiales ligeramente caídas',
        'Voz monótona, baja y con pausas prolongadas',
        'Hombros encorvados hacia adelante y mirada fija en el piso',
      ],
      isCongruent: false,
      realEmotion: 'Tristeza, desánimo o necesidad de apoyo emocional',
      explanation: 'Las palabras intentan no ser una carga, pero la caída de comisuras y la voz apagada indican vulnerabilidad y dolor emocional.',
      recommendedAction: 'No tomes el "estoy bien" de forma literal. Acércate con calidez y di: "Noto que algo te preocupa. Aquí estoy si te apetece charlar o simplemente estar acompañados".',
      targetAudience: 'autism_focus',
    ),
  ];

  static List<IncongruenceItem> getByAudience(String audience) {
    if (audience == 'all') return items;
    return items.where((i) => i.targetAudience == audience || i.targetAudience == 'general').toList();
  }
}
