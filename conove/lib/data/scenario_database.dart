import '../models/scenario.dart';

class ScenarioDatabase {
  static const List<Scenario> scenarios = [
    // --- ESCENARIO 1: VENTAS Y NEGOCIACIÓN ---
    Scenario(
      id: 'scenario_sales_closing',
      title: 'El Cierre de Ventas: Decodificando al Prospecto',
      domain: 'Ventas & Negociación',
      description: 'Aprende a leer el lenguaje corporal del cliente para saber cuándo callar, cuándo aclarar dudas y cuándo cerrar el trato.',
      contextOverview: 'Estás en la oficina del Director de Operaciones presentando una propuesta tecnológica clave.',
      iconName: 'briefcase',
      steps: [
        ScenarioStep(
          id: 'step_1',
          narrative: 'Acabas de explicar las características de tu producto durante 10 minutos. Observas que el cliente cruza los brazos, aprieta los labios y mira hacia abajo.',
          characterAction: 'Brazos fuertemente cruzados y labios en línea delgada.',
          illustrationKey: 'closed_posture',
          visibleSignals: ['Brazos cruzados (Barrera)', 'Labios comprimidos (Contención de objeción)', 'Mirada baja'],
          learningTakeaway: 'Los brazos cruzados + labios apretados indican que el cliente tiene una duda u objeción no resuelta.',
          choices: [
            ScenarioChoice(
              text: 'Seguir hablando más rápido para terminar toda la presentación antes de que pregunte.',
              analysis: 'Pésima opción: Si sigues hablando cuando el cliente ya se cerró mentalmente, sentirá que lo estás arrollando y aumentará su rechazo.',
              isBestAction: false,
              nextStepIndex: 1,
              consequenceSummary: 'El cliente se desconecta y empieza a mirar su reloj.',
            ),
            ScenarioChoice(
              text: 'Hacer una pausa intencional y preguntar: "Noto que estás analizando este punto, ¿hay algún detalle que te genere dudas?"',
              analysis: 'Excelente decisión: Validas su proceso mental sin confrontarlo y le das permiso seguro para expresar su objeción.',
              isBestAction: true,
              nextStepIndex: 1,
              consequenceSummary: 'El cliente descruza los brazos y dice: "El costo de implementación me parece alto".',
            ),
            ScenarioChoice(
              text: 'Decirle directamente: "¿Por qué cruzas los brazos? ¿No te gusta mi producto?"',
              analysis: 'Demasiado invasivo y confrontativo. Pone a la otra persona a la defensiva.',
              isBestAction: false,
              nextStepIndex: 1,
              consequenceSummary: 'El cliente se incomoda y adopta una postura aún más fría.',
            ),
          ],
        ),
        ScenarioStep(
          id: 'step_2',
          narrative: 'El cliente te explica su objeción sobre el costo. Tú respondes mostrándole cómo el ahorro en 3 meses cubre la inversión inicial. El cliente se inclina hacia adelante sobre la mesa, asiente lentamente y muestra una sonrisa Duchenne con ojos achinados.',
          characterAction: 'Inclinación hacia adelante + sonrisa genuina con arrugas en los ojos.',
          illustrationKey: 'leaning_forward',
          visibleSignals: ['Inclinación frontal (Alto interés)', 'Sonrisa de Duchenne (Aprobación real)', 'Contacto visual directo'],
          learningTakeaway: 'Inclinarse hacia adelante con sonrisa genuina es una luz verde indiscutible de compra.',
          choices: [
            ScenarioChoice(
              text: 'Pedir el cierre: "¿Te parece si empezamos la implementación el próximo lunes para asegurar el cronograma?"',
              analysis: 'Perfecto: Identificaste la señal de compra y avanzaste al llamado a la acción en el momento de mayor convicción.',
              isBestAction: true,
              nextStepIndex: null, // Fin con éxito
              consequenceSummary: '¡Trato cerrado con éxito! El cliente firma entusiasmado.',
            ),
            ScenarioChoice(
              text: 'Seguir explicando 20 diapositivas más sobre la historia de la empresa.',
              analysis: 'Error común: Hablar de más después de que el cliente ya tomó la decisión puede reabrir dudas innecesarias.',
              isBestAction: false,
              nextStepIndex: null,
              consequenceSummary: 'El cliente pierde el entusiasmo inicial por sobreexplicación.',
            ),
          ],
        ),
      ],
    ),

    // --- ESCENARIO 2: ÁMBITO LABORAL ---
    Scenario(
      id: 'scenario_job_interview',
      title: 'La Entrevista Laboral: Conexión con el Reclutador',
      domain: 'Ámbito Laboral',
      description: 'Descubre cómo calibrar el nivel de formalidad, proximidad y ritmo en una entrevista de trabajo.',
      contextOverview: 'Estás en una sala de juntas pequeña con la Jefa del Departamento para una posición senior.',
      iconName: 'people',
      steps: [
        ScenarioStep(
          id: 'step_1',
          narrative: 'Entras a la sala. La entrevistadora se pone de pie, mantiene el contacto visual firme, sonríe con calidez y extiende su mano a una distancia de 1.5 metros.',
          characterAction: 'Contacto visual sostenido, postura abierta y saludo formal respetando el espacio social.',
          illustrationKey: 'open_posture',
          visibleSignals: ['Espacio Social respetado (1.5m)', 'Contacto visual seguro', 'Sonrisa de bienvenida'],
          learningTakeaway: 'El saludo en el espacio social marca el tono de profesionalismo y respeto recíproco.',
          choices: [
            ScenarioChoice(
              text: 'Dar un apretón de manos firme, mirándola a los ojos con una sonrisa y tomar asiento cuando ella lo indique.',
              analysis: 'Impecable: Transmite seguridad, respeto por los límites y excelentes habilidades sociales.',
              isBestAction: true,
              nextStepIndex: 1,
              consequenceSummary: 'La entrevistadora asiente complacida y abre tu currículum.',
            ),
            ScenarioChoice(
              text: 'Acercarte a darle dos besos en la mejilla como si fuera una amiga de fiesta.',
              analysis: 'Violación grave de la proxémica profesional. Invadir el espacio íntimo en una primera entrevista genera incomodidad inmediata.',
              isBestAction: false,
              nextStepIndex: 1,
              consequenceSummary: 'La entrevistadora retrocede un paso desconcertada.',
            ),
            ScenarioChoice(
              text: 'Mirar fijamente al suelo sin responder el saludo y sentarte de inmediato en silencio.',
              analysis: 'Puede interpretarse erróneamente como desinterés o falta severa de habilidades interpersonales.',
              isBestAction: false,
              nextStepIndex: 1,
              consequenceSummary: 'El ambiente se torna tenso.',
            ),
          ],
        ),
        ScenarioStep(
          id: 'step_2',
          narrative: 'A mitad de tu respuesta sobre un proyecto anterior, la entrevistadora empieza a cerrar los ojos por períodos de 2 segundos y tamborilea levemente los dedos en la mesa.',
          characterAction: 'Párpados cerrados prolongados + tamborileo de dedos.',
          illustrationKey: 'finger_tapping',
          visibleSignals: ['Párpados cerrados (Sobrecarga de información)', 'Tamborileo (Impaciencia con el tiempo)'],
          learningTakeaway: 'El tamborileo + ojos cerrados indica que tu respuesta es demasiado larga y necesita un resumen inmediato.',
          choices: [
            ScenarioChoice(
              text: 'Concluir con el resultado clave en 1 frase: "En resumen, logramos reducir los costos un 30% en 4 meses. ¿Te gustaría profundizar en algún aspecto?"',
              analysis: 'Brillante: Detectaste la señal de saturación y adaptaste tu comunicación al instante, demostrando síntesis y empatía.',
              isBestAction: true,
              nextStepIndex: null,
              consequenceSummary: 'La entrevistadora sonríe aliviada: "Excelente resultado, pasemos a la siguiente pregunta".',
            ),
            ScenarioChoice(
              text: 'Hablar durante 10 minutos más detallando cada una de las líneas de código.',
              analysis: 'Ignora por completo las señales de impaciencia.',
              isBestAction: false,
              nextStepIndex: null,
              consequenceSummary: 'La entrevistadora te interrumpe bruscamente para cortar la entrevista.',
            ),
          ],
        ),
      ],
    ),

    // --- ESCENARIO 3: SOCIAL & AMISTADES ---
    Scenario(
      id: 'scenario_friend_coffee',
      title: 'En el Café con un Amigo: Cuando algo anda mal',
      domain: 'Social & Amigos',
      description: 'Aprende a distinguir cuando un "Todo bien" en realidad oculta tristeza o preocupación.',
      contextOverview: 'Quedaste en una cafetería con un buen amigo que suele ser muy bromista.',
      iconName: 'heart',
      steps: [
        ScenarioStep(
          id: 'step_1',
          narrative: 'Le preguntas "¿Cómo te ha ido?". Tu amigo responde "Todo bien, normal..." con la voz apagada en volumen muy bajo, hombros caídos y mirando hacia su taza de café.',
          characterAction: 'Voz monótona baja + hombros caídos + mirada esquiva.',
          illustrationKey: 'turned_down_lips',
          visibleSignals: ['Volumen bajo (Retracción)', 'Hombros caídos (Desánimo)', 'Incongruencia entre "Todo bien" y su cuerpo'],
          learningTakeaway: 'En el contexto relacional cercano, las señales de retraimiento pesan más que las palabras de cortesía.',
          choices: [
            ScenarioChoice(
              text: 'Decir: "Te conozco y noto tu voz algo apagada. Si quieres desahogarte o hablar de algo, aquí estoy."',
              analysis: 'La respuesta ideal: Ofreces un espacio seguro y empático sin forzarlo agresivamente.',
              isBestAction: true,
              nextStepIndex: null,
              consequenceSummary: 'Tu amigo suspira aliviado y te cuenta el problema que lo tenía angustiado.',
            ),
            ScenarioChoice(
              text: 'Decir: "Ah, perfecto, qué bueno que estés bien", y hablar durante una hora de tus propias cosas.',
              analysis: 'Toma el mensaje puramente literal e ignora la petición de ayuda no verbal.',
              isBestAction: false,
              nextStepIndex: null,
              consequenceSummary: 'Tu amigo se siente invisible y distante.',
            ),
          ],
        ),
      ],
    ),
  ];

  static Scenario? getById(String id) {
    try {
      return scenarios.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
