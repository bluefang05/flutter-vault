import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(const GrapaApp());

class GrapaApp extends StatelessWidget {
  const GrapaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF25231F);
    const cream = Color(0xFFF8F4EA);
    const purple = Color(0xFF7656D6);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grapa',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          primary: purple,
          surface: cream,
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: ink,
          displayColor: ink,
          fontFamily: 'sans',
        ),
      ),
      home: const GrapaHome(),
    );
  }
}

class Mission {
  Mission(
    this.title,
    this.subtitle,
    this.categoryAsset,
    this.color, {
    this.done = false,
  });

  final String title;
  final String subtitle;
  final String categoryAsset;
  final Color color;
  bool done;
}

class GrapaAssets {
  static const neutral = 'assets/images/grapa/grapa_00_neutral.png';
  static const celebrating = 'assets/images/grapa/grapa_01_celebrando.png';
  static const laughing = 'assets/images/grapa/grapa_02_riendo.png';
  static const sad = 'assets/images/grapa/grapa_03_triste.png';
  static const crying = 'assets/images/grapa/grapa_04_llorando.png';
  static const determined = 'assets/images/grapa/grapa_05_determinada.png';
  static const worried = 'assets/images/grapa/grapa_06_preocupada.png';
  static const surprised = 'assets/images/grapa/grapa_07_sorprendida.png';
  static const sleepy = 'assets/images/grapa/grapa_08_somnolienta.png';
  static const thinking = 'assets/images/grapa/grapa_09_pensando.png';

  static String forProgress(double progress) {
    if (progress == 0) return sad;
    if (progress < .5) return worried;
    if (progress < 1) return determined;
    return celebrating;
  }
}

class PinAssets {
  static const neutral = 'assets/images/pin/pin_11_neutral_limpio.png';
  static const happy = 'assets/images/pin/pin_02_feliz_brazos_arriba.png';
  static const confused = 'assets/images/pin/pin_03_confundido.png';
  static const determined = 'assets/images/pin/pin_04_determinado.png';
  static const laughingCrying = 'assets/images/pin/pin_05_riendo_llorando.png';
  static const worried = 'assets/images/pin/pin_06_preocupado.png';
  static const sad = 'assets/images/pin/pin_07_triste.png';
  static const nervous = 'assets/images/pin/pin_08_nervioso.png';
  static const surprised = 'assets/images/pin/pin_09_sorprendido.png';
  static const sleeping = 'assets/images/pin/pin_10_dormido.png';

  static String forHearts(int hearts) {
    if (hearts <= 1) return sad;
    if (hearts == 2) return worried;
    if (hearts == 3) return neutral;
    if (hearts == 4) return determined;
    return happy;
  }
}

class PinHomeAssets {
  static const basicHouse =
      'assets/images/pin_casa/pin_casa_01_casita_basica.png';
  static const upgradedHouse =
      'assets/images/pin_casa/pin_casa_02_casa_mejorada.png';
  static const premiumHouse =
      'assets/images/pin_casa/pin_casa_03_casa_premium.png';
  static const bed = 'assets/images/pin_casa/pin_objeto_01_cama.png';
  static const foodBowl =
      'assets/images/pin_casa/pin_objeto_06_bowl_comida_nuevo.png';
  static const toy = 'assets/images/pin_casa/pin_objeto_07_juguete_varita.png';
  static const lamp = 'assets/images/pin_casa/pin_objeto_04_lampara.png';
  static const rug = 'assets/images/pin_casa/pin_objeto_05_alfombra.png';

  static String houseForHearts(int hearts) {
    if (hearts >= 5) return premiumHouse;
    if (hearts >= 3) return upgradedHouse;
    return basicHouse;
  }
}

class PinActionAssets {
  static const eating =
      'assets/images/pin_accion/pin_accion_12_comiendo_bowl.png';
  static const sleepingAtHome =
      'assets/images/pin_accion/pin_accion_11_durmiendo_luna.png';
  static const celebratingReward =
      'assets/images/pin_accion/pin_accion_03_celebrando_recompensa.png';
  static const neglectedSad =
      'assets/images/pin_accion/pin_accion_04_triste_cuando_no_lo_cuidas.png';
  static const walkingWithGrapa =
      'assets/images/pin_accion/pin_accion_05_caminando_acompanando_a_grapa.png';
  static const receivingUpgrade =
      'assets/images/pin_accion/pin_accion_06_recibiendo_una_mejora.png';
  static const inBackpack =
      'assets/images/pin_accion/pin_accion_07_dentro_de_una_mochila.png';
  static const waitingSnack =
      'assets/images/pin_accion/pin_accion_08_esperando_merienda.png';
  static const widgetGreeting =
      'assets/images/pin_accion/pin_accion_09_saludando_en_widget.png';
  static const missionFailedReaction =
      'assets/images/pin_accion/pin_accion_10_reaccionando_a_mision_fallida.png';

  static String forMood({required int hearts, required bool justFed}) {
    if (justFed) return eating;
    if (hearts <= 1) return neglectedSad;
    if (hearts >= 5) return celebratingReward;
    return waitingSnack;
  }
}

class ScenarioAssets {
  static const grapaRoom =
      'assets/images/escenarios/escenario_01_habitacion_de_grapa.png';
  static const pinHouseEmpty =
      'assets/images/escenarios/escenario_02_casita_de_pin_vacia.png';
  static const pinHouseLevel1 =
      'assets/images/escenarios/escenario_03_casita_de_pin_mejorada_nivel_1.png';
  static const pinHouseLevel2 =
      'assets/images/escenarios/escenario_04_casita_de_pin_mejorada_nivel_2.png';
  static const focusForest =
      'assets/images/escenarios/escenario_05_bosque_del_enfoque.png';
  static const disciplineMountain =
      'assets/images/escenarios/escenario_06_montana_de_la_disciplina.png';
  static const procrastinationSwamp =
      'assets/images/escenarios/escenario_07_pantano_de_la_procrastinacion.png';
  static const rewardShop =
      'assets/images/escenarios/escenario_08_tienda_de_recompensas.png';
  static const upgradeWorkshop =
      'assets/images/escenarios/escenario_09_taller_de_mejoras.png';
  static const failureScreen =
      'assets/images/escenarios/escenario_10_fondo_pantalla_de_fallo.png';
  static const cleanPinRoom =
      'assets/images/escenarios/escenario_11_habitacion_pin_limpia.png';
  static const cleanRewardShop =
      'assets/images/escenarios/escenario_12_tienda_limpia.png';
  static const cleanMissionPath =
      'assets/images/escenarios/escenario_13_misiones_camino_limpio.png';
  static const cleanRewardsPath =
      'assets/images/escenarios/escenario_14_progreso_recompensas_limpio.png';
  static const sunsetFailurePath =
      'assets/images/escenarios/escenario_15_fallo_atardecer.png';

  static String adventureForProgress(double progress) {
    if (progress == 0) return sunsetFailurePath;
    if (progress < 1) return cleanMissionPath;
    return cleanRewardsPath;
  }

  static String pinHomeForHearts(int hearts) {
    if (hearts >= 5) return pinHouseLevel2;
    if (hearts >= 3) return cleanPinRoom;
    return pinHouseEmpty;
  }
}

class UiBrandingAssets {
  static const appIcon = 'assets/images/ui_branding/ui_01_icono_app_grapa.png';
  static const splash =
      'assets/images/ui_branding/ui_02_splash_screen_grapa.png';
  static const horizontalLogo =
      'assets/images/ui_branding/ui_03_logo_horizontal_grapa.png';
  static const symbolLogo =
      'assets/images/ui_branding/ui_04_logo_simbolo_grapa.png';
  static const completeButton =
      'assets/images/ui_branding/ui_05_boton_completar_mision.png';
  static const streakBadge = 'assets/images/ui_branding/ui_06_badge_racha.png';
  static const levelBadge = 'assets/images/ui_branding/ui_07_badge_nivel.png';
  static const rewardCard =
      'assets/images/ui_branding/ui_08_card_recompensa.png';
  static const grapaAvatarFrame =
      'assets/images/ui_branding/ui_09_marco_avatar_grapa.png';
  static const pinAvatarFrame =
      'assets/images/ui_branding/ui_10_marco_avatar_pin.png';
  static const emptyMissionCard =
      'assets/images/ui_branding/ui_11_tarjeta_mision_vacia.png';
  static const fantasyPanel =
      'assets/images/ui_branding/ui_12_panel_grande_fantasia.png';
  static const emptyGreenButton =
      'assets/images/ui_branding/ui_13_boton_verde_vacio.png';
  static const emptyBlueButton =
      'assets/images/ui_branding/ui_14_boton_azul_vacio.png';
  static const emptyProgressBar =
      'assets/images/ui_branding/ui_15_barra_progreso_vacia.png';
  static const emptyPurpleBanner =
      'assets/images/ui_branding/ui_16_banner_morado_vacio.png';
}

class SacaGrapaAssets {
  static const mocking = 'assets/images/sacagrapa/sacagrapa_01_burlon.png';
  static const laughing = 'assets/images/sacagrapa/sacagrapa_02_risa.png';
  static const villain = 'assets/images/sacagrapa/sacagrapa_03_villano.png';
  static const confused = 'assets/images/sacagrapa/sacagrapa_04_confundido.png';
  static const crying = 'assets/images/sacagrapa/sacagrapa_05_llorando.png';
  static const proud = 'assets/images/sacagrapa/sacagrapa_06_orgulloso.png';
  static const angry = 'assets/images/sacagrapa/sacagrapa_07_enojado.png';
  static const enamored = 'assets/images/sacagrapa/sacagrapa_08_enamorado.png';
  static const dizzy = 'assets/images/sacagrapa/sacagrapa_09_mareado.png';
  static const surprised =
      'assets/images/sacagrapa/sacagrapa_10_sorprendido.png';
  static const stealingCoins =
      'assets/images/sacagrapa_villano/sacagrapa_villano_01_robando_monedas.png';
  static const blockingMission =
      'assets/images/sacagrapa_villano/sacagrapa_villano_12_bloqueando_cartel.png';
  static const hiddenInBackground =
      'assets/images/sacagrapa_villano/sacagrapa_villano_03_escondido_en_el_fondo.png';
  static const laughingBehindSadGrapa =
      'assets/images/sacagrapa_villano/sacagrapa_villano_04_riendose_detras_de_grapa_triste.png';
  static const defeated =
      'assets/images/sacagrapa_villano/sacagrapa_villano_11_derrotado_mareado.png';
  static const dizzyByVictory =
      'assets/images/sacagrapa_villano/sacagrapa_villano_06_mareado_por_victoria.png';
  static const breakingStreak =
      'assets/images/sacagrapa_villano/sacagrapa_villano_07_rompiendo_racha.png';
  static const temptingProcrastination =
      'assets/images/sacagrapa_villano/sacagrapa_villano_08_tentando_a_procrastinar.png';
  static const escaping =
      'assets/images/sacagrapa_villano/sacagrapa_villano_09_escapando.png';
  static const shadowSilhouette =
      'assets/images/sacagrapa_villano/sacagrapa_villano_10_silueta_sombra.png';
  static const laughFrames = [
    'assets/images/sacagrapa_risa/sacagrapa_risa_01.png',
    'assets/images/sacagrapa_risa/sacagrapa_risa_02.png',
    'assets/images/sacagrapa_risa/sacagrapa_risa_03.png',
    'assets/images/sacagrapa_risa/sacagrapa_risa_04.png',
    'assets/images/sacagrapa_risa/sacagrapa_risa_05.png',
    'assets/images/sacagrapa_risa/sacagrapa_risa_06.png',
    'assets/images/sacagrapa_risa/sacagrapa_risa_07.png',
    'assets/images/sacagrapa_risa/sacagrapa_risa_08.png',
  ];

  static String forProgress(double progress) {
    if (progress == 0) return temptingProcrastination;
    if (progress < 1) return hiddenInBackground;
    return dizzyByVictory;
  }
}

class EconomyAssets {
  static const coin =
      'assets/images/economia/economia_11_moneda_grapa_nueva.png';
  static const gem = 'assets/images/economia/economia_12_gema_morada_nueva.png';
  static const xpStar =
      'assets/images/economia/economia_13_estrella_xp_nueva.png';
  static const energy = 'assets/images/economia/economia_04_energia_rayo.png';
  static const streak =
      'assets/images/economia/economia_16_racha_fuego_nueva.png';
  static const sleepMoon = 'assets/images/economia/economia_17_sueno_luna.png';
  static const commonChest =
      'assets/images/economia/economia_14_cofre_comun_nuevo.png';
  static const rareChest = 'assets/images/economia/economia_07_cofre_raro.png';
  static const legendaryChest =
      'assets/images/economia/economia_15_cofre_epico_nuevo.png';
  static const missionTicket =
      'assets/images/economia/economia_09_ticket_mision.png';
  static const levelBadge =
      'assets/images/economia/economia_10_insignia_nivel.png';
}

class MissionCategoryAssets {
  static const study =
      'assets/images/mision_categoria/mision_categoria_01_estudio.png';
  static const exercise =
      'assets/images/mision_categoria/mision_categoria_02_ejercicio.png';
  static const cleaning =
      'assets/images/mision_categoria/mision_categoria_03_limpieza.png';
  static const work =
      'assets/images/mision_categoria/mision_categoria_04_trabajo.png';
  static const health =
      'assets/images/mision_categoria/mision_categoria_05_salud.png';
  static const rest =
      'assets/images/mision_categoria/mision_categoria_06_descanso.png';
  static const personalProject =
      'assets/images/mision_categoria/mision_categoria_07_proyecto_personal.png';
  static const socialFamily =
      'assets/images/mision_categoria/mision_categoria_08_social_familia.png';

  static String inferFromText(String text) {
    final value = text.toLowerCase();
    if (_hasAny(value, ['estudi', 'leer', 'libro', 'clase', 'curso'])) {
      return study;
    }
    if (_hasAny(value, ['ejercicio', 'caminar', 'correr', 'gym', 'entren'])) {
      return exercise;
    }
    if (_hasAny(value, ['limpi', 'ordenar', 'lavar', 'cocina', 'casa'])) {
      return cleaning;
    }
    if (_hasAny(value, ['trabajo', 'presentaci', 'reuni', 'correo'])) {
      return work;
    }
    if (_hasAny(value, ['salud', 'medic', 'agua', 'doctor', 'terapia'])) {
      return health;
    }
    if (_hasAny(value, ['descanso', 'dormir', 'siesta', 'pausa', 'meditar'])) {
      return rest;
    }
    if (_hasAny(value, ['familia', 'amigo', 'llamar', 'social', 'visitar'])) {
      return socialFamily;
    }
    return personalProject;
  }

  static bool _hasAny(String value, List<String> tokens) =>
      tokens.any((token) => value.contains(token));
}

class MissionStateAssets {
  static const pending =
      'assets/images/mision_estado/mision_estado_01_pendiente.png';
  static const inProgress =
      'assets/images/mision_estado/mision_estado_02_en_progreso.png';
  static const completed =
      'assets/images/mision_estado/mision_estado_03_completada.png';
  static const overdue =
      'assets/images/mision_estado/mision_estado_04_vencida.png';
  static const blockedBySacaGrapa =
      'assets/images/mision_estado/mision_estado_05_bloqueada_por_sacagrapa.png';
  static const epic = 'assets/images/mision_estado/mision_estado_06_epica.png';

  static String forMission(Mission mission) {
    if (mission.done) return completed;
    if (mission.title.length > 28) return epic;
    return pending;
  }
}

class MissionButtonAssets {
  static const start =
      'assets/images/boton_mision/boton_mision_01_iniciar_mision.png';
  static const claimReward =
      'assets/images/boton_mision/boton_mision_02_reclamar_recompensa.png';
  static const postpone =
      'assets/images/boton_mision/boton_mision_03_posponer.png';
  static const fail =
      'assets/images/boton_mision/boton_mision_04_fallar_mision.png';
  static const rematch =
      'assets/images/boton_mision/boton_mision_05_revancha.png';

  static String primaryForMission(Mission mission) =>
      mission.done ? claimReward : start;
}

class FailureRematchAssets {
  static const softFailureBackground =
      'assets/images/fallo_revancha/d_01_fondo_fallo_suave.png';
  static const strongFailureBackground =
      'assets/images/fallo_revancha/d_02_fondo_fallo_fuerte.png';
  static const sadGrapa = 'assets/images/fallo_revancha/d_03_grapa_triste.png';
  static const worriedPin =
      'assets/images/fallo_revancha/d_04_pin_preocupado.png';
  static const laughingSacaGrapa =
      'assets/images/fallo_revancha/d_05_sacagrapa_riendose.png';
  static const importantMissionFailed =
      'assets/images/fallo_revancha/d_06_escena_mision_fallida_importante.png';
  static const stillCanFixIt =
      'assets/images/fallo_revancha/d_07_escena_todavia_podemos_arreglarlo.png';
  static const rematchAvailable =
      'assets/images/fallo_revancha/d_08_escena_revancha_disponible.png';
  static const rematchMessagePanel =
      'assets/images/fallo_revancha/d_09_panel_mensaje_revancha.png';
  static const rematchRewardBar =
      'assets/images/fallo_revancha/d_10_barra_recompensas_revancha.png';
}

class ShopItemAssets {
  static const grapaDress = 'assets/images/tienda/tienda_01_vestido_grapa.png';
  static const grapaBow = 'assets/images/tienda/tienda_02_lazo_grapa.png';
  static const grapaHat = 'assets/images/tienda/tienda_03_sombrero_grapa.png';
  static const grapaBackpack =
      'assets/images/tienda/tienda_04_mochila_grapa.png';
  static const pinPremiumBed =
      'assets/images/tienda/tienda_05_cama_premium_pin.png';
  static const pinPremiumPlate =
      'assets/images/tienda/tienda_06_plato_premium_pin.png';
  static const pinToy = 'assets/images/tienda/tienda_07_juguete_pin.png';
  static const pinLamp = 'assets/images/tienda/tienda_08_lampara_pin.png';
  static const epicRarityFrame =
      'assets/images/tienda/tienda_09_marco_rareza_epica.png';
  static const legendaryRarityFrame =
      'assets/images/tienda/tienda_10_marco_rareza_legendaria.png';
}

class EffectAssets {
  static const flyingCoins =
      'assets/images/efectos/efecto_01_monedas_volando.png';
  static const rewardGlow =
      'assets/images/efectos/efecto_02_brillo_recompensa.png';
  static const levelUp = 'assets/images/efectos/efecto_03_subida_de_nivel.png';
  static const openingChest =
      'assets/images/efectos/efecto_04_cofre_abriendose.png';
  static const streakLit =
      'assets/images/efectos/efecto_05_racha_encendida.png';
  static const missionFailed =
      'assets/images/efectos/efecto_06_mision_fallida.png';
  static const missionCompleted =
      'assets/images/efectos/efecto_07_mision_completada.png';
  static const brokenHeart = 'assets/images/efectos/efecto_08_corazon_roto.png';
}

class GrapaActionAssets {
  static const takingNotes =
      'assets/images/grapa_accion/grapa_accion_12_checklist.png';
  static const showingMission =
      'assets/images/grapa_accion/grapa_accion_02_mostrando_mision.png';
  static const missionCompleted =
      'assets/images/grapa_accion/grapa_accion_13_celebrando_confeti.png';
  static const waitingReminder =
      'assets/images/grapa_accion/grapa_accion_04_esperando_recordatorio.png';
  static const pointingButton =
      'assets/images/grapa_accion/grapa_accion_11_apuntando_derecha.png';
  static const givingCoins =
      'assets/images/grapa_accion/grapa_accion_06_entregando_monedas.png';
  static const resting =
      'assets/images/grapa_accion/grapa_accion_07_descansando.png';
  static const caringForPin =
      'assets/images/grapa_accion/grapa_accion_08_cuidando_a_pin.png';
  static const workingDesk =
      'assets/images/grapa_accion/grapa_accion_09_trabajando_escritorio.png';
  static const overdueAlert =
      'assets/images/grapa_accion/grapa_accion_10_alerta_tarea_vencida.png';

  static String forProgress(double progress) {
    if (progress == 0) return takingNotes;
    if (progress < 1) return givingCoins;
    return missionCompleted;
  }
}

class GrapaHome extends StatefulWidget {
  const GrapaHome({super.key});

  @override
  State<GrapaHome> createState() => _GrapaHomeState();
}

class _GrapaHomeState extends State<GrapaHome> {
  int _tab = 0;
  int _coins = 120;
  final int _streak = 7;
  int _pinHearts = 3;
  bool _pinJustFed = false;
  final _missions = <Mission>[
    Mission(
      'Preparar presentación',
      'Trabajo · 30 min',
      MissionCategoryAssets.work,
      const Color(0xFFFFB765),
    ),
    Mission(
      'Caminar 20 minutos',
      'Salud · Antes de las 6:00 p. m.',
      MissionCategoryAssets.exercise,
      const Color(0xFF73CBB0),
    ),
    Mission(
      'Leer 10 páginas',
      'Crecimiento · 15 min',
      MissionCategoryAssets.study,
      const Color(0xFF92A5E8),
    ),
  ];

  int get _completed => _missions.where((mission) => mission.done).length;

  Future<void> _addMission() async {
    final controller = TextEditingController();
    final title = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
          decoration: const BoxDecoration(
            color: Color(0xFFFFFCF6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDAD3C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Nueva misión',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text('¿Qué vamos a conquistar ahora?'),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ej. Ordenar mi escritorio',
                  filled: true,
                  fillColor: const Color(0xFFF2EDE3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) => Navigator.pop(context, value.trim()),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () =>
                      Navigator.pop(context, controller.text.trim()),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Crear misión',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    if (title == null || title.isEmpty) return;
    setState(() {
      _missions.add(
        Mission(
          title,
          'Personal · Para hoy',
          MissionCategoryAssets.inferFromText(title),
          const Color(0xFFE58BA5),
        ),
      );
      _pinJustFed = false;
    });
  }

  void _toggleMission(int index) {
    final mission = _missions[index];
    setState(() {
      mission.done = !mission.done;
      _coins += mission.done ? 15 : -15;
      _pinJustFed = false;
    });
    if (mission.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2E493E),
          content: const _RewardSnackContent(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _tab,
          children: [
            _TodayView(
              missions: _missions,
              completed: _completed,
              coins: _coins,
              streak: _streak,
              onToggle: _toggleMission,
              onAdd: _addMission,
            ),
            _AdventureView(
              coins: _coins,
              completed: _completed,
              total: _missions.length,
            ),
            _PinView(
              hearts: _pinHearts,
              justFed: _pinJustFed,
              onFeed: _feedPin,
            ),
            _ProfileView(streak: _streak, coins: _coins),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (value) => setState(() => _tab = value),
        backgroundColor: const Color(0xFFFFFCF6),
        indicatorColor: const Color(0xFFE7DDFC),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline_rounded),
            selectedIcon: Icon(Icons.check_circle_rounded),
            label: 'Hoy',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Aventura',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets_rounded),
            label: 'Pin',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  void _feedPin() {
    if (_coins < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Necesitas 10 monedas para alimentar a Pin'),
        ),
      );
      return;
    }
    setState(() {
      _coins -= 10;
      _pinHearts = math.min(5, _pinHearts + 1);
      _pinJustFed = true;
    });
  }
}

class _TodayView extends StatelessWidget {
  const _TodayView({
    required this.missions,
    required this.completed,
    required this.coins,
    required this.streak,
    required this.onToggle,
    required this.onAdd,
  });

  final List<Mission> missions;
  final int completed;
  final int coins;
  final int streak;
  final ValueChanged<int> onToggle;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final progress = missions.isEmpty ? 0.0 : completed / missions.length;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'JUEVES, 30 DE JULIO',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF81786C),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Image.asset(
                          UiBrandingAssets.horizontalLogo,
                          height: 54,
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Tu aventura de hoy',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF5C5148),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _Pill(
                    assetPath: UiBrandingAssets.streakBadge,
                    text: '$streak',
                  ),
                  const SizedBox(width: 8),
                  _Pill(assetPath: EconomyAssets.coin, text: '$coins'),
                ],
              ),
              const SizedBox(height: 20),
              _HeroCard(progress: progress, completed: completed),
              const SizedBox(height: 26),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Misiones de hoy',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '$completed/${missions.length} listas',
                    style: const TextStyle(
                      color: Color(0xFF81786C),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: missions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _MissionTile(
              mission: missions[index],
              onTap: () => onToggle(index),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          sliver: SliverToBoxAdapter(
            child: OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Añadir una misión'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: const BorderSide(color: Color(0xFFD7D0C4)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.progress, required this.completed});

  final double progress;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final isFailureState = completed == 0;
    final message = isFailureState
        ? 'Todavía podemos arreglarlo.\nRevancha disponible.'
        : completed < 3
        ? '¡Así se hace!\nCada misión nos hace más fuertes.'
        : '¡Día conquistado!\nSaca Grapas no tuvo oportunidad.';
    return Container(
      height: 215,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFE9DFFC),
        image: DecorationImage(
          image: AssetImage(
            isFailureState
                ? FailureRematchAssets.importantMissionFailed
                : ScenarioAssets.grapaRoom,
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withValues(alpha: isFailureState ? .08 : .36),
            BlendMode.srcATop,
          ),
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -45,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                color: Color(0x337656D6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -22,
            bottom: -28,
            child: isFailureState
                ? Image.asset(
                    FailureRematchAssets.rematchRewardBar,
                    width: 210,
                    height: 90,
                    fit: BoxFit.contain,
                  )
                : _GrapaActionScene(progress: progress),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(22, 22, isFailureState ? 22 : 128, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .65),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'GRAPA DICE',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF684CB5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                if (isFailureState) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      MissionButtonAssets.rematch,
                      width: 128,
                      height: 52,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: .7),
                    color: const Color(0xFF7656D6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GrapaActionScene extends StatelessWidget {
  const _GrapaActionScene({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 178,
      height: 205,
      child: Opacity(
        opacity: progress == 0 ? .9 : 1,
        child: Image.asset(
          GrapaActionAssets.forProgress(progress),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _SacaGrapaLaughAnimation extends StatefulWidget {
  const _SacaGrapaLaughAnimation({required this.size});

  final double size;

  @override
  State<_SacaGrapaLaughAnimation> createState() =>
      _SacaGrapaLaughAnimationState();
}

class _SacaGrapaLaughAnimationState extends State<_SacaGrapaLaughAnimation> {
  Timer? _timer;
  int _frame = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 110), (_) {
      if (!mounted) return;
      setState(() {
        _frame = (_frame + 1) % SacaGrapaAssets.laughFrames.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      SacaGrapaAssets.laughFrames[_frame],
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
    );
  }
}

class _RewardSnackContent extends StatelessWidget {
  const _RewardSnackContent();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 42,
          height: 42,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(EffectAssets.missionCompleted, fit: BoxFit.cover),
              Image.asset(
                EconomyAssets.coin,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            '¡Misión completada!  +15 monedas',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _MissionTile extends StatelessWidget {
  const _MissionTile({required this.mission, required this.onTap});

  final Mission mission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: mission.done ? const Color(0xFFF0ECE4) : const Color(0xFFFFFCF6),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: mission.done
                      ? const Color(0xFF7656D6)
                      : mission.color.withValues(alpha: .22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: mission.done
                    ? const Icon(Icons.check_rounded, color: Colors.white)
                    : Padding(
                        padding: const EdgeInsets.all(5),
                        child: Image.asset(
                          mission.categoryAsset,
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        decoration: mission.done
                            ? TextDecoration.lineThrough
                            : null,
                        color: mission.done ? const Color(0xFF8A8378) : null,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      mission.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8A8378),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: Image.asset(
                      MissionStateAssets.forMission(mission),
                      fit: BoxFit.contain,
                      opacity: AlwaysStoppedAnimation(mission.done ? .95 : .62),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 62,
                    height: 30,
                    child: Image.asset(
                      MissionButtonAssets.primaryForMission(mission),
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.assetPath, required this.text});
  final String assetPath;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isBrandBadge = assetPath == UiBrandingAssets.streakBadge;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isBrandBadge ? 6 : 10,
        vertical: isBrandBadge ? 4 : 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE2DBD0)),
      ),
      child: Row(
        children: [
          Image.asset(
            assetPath,
            width: isBrandBadge ? 28 : 18,
            height: isBrandBadge ? 28 : 18,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _AdventureView extends StatelessWidget {
  const _AdventureView({
    required this.coins,
    required this.completed,
    required this.total,
  });
  final int coins;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        const Text(
          'Tu aventura',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const Text(
          'Convierte cada día en una nueva región.',
          style: TextStyle(color: Color(0xFF81786C)),
        ),
        const SizedBox(height: 24),
        Container(
          height: 350,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(ScenarioAssets.adventureForProgress(progress)),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: .10),
                BlendMode.darken,
              ),
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 26,
                child: Text(
                  'SENDERO DE LA CONSTANCIA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              CustomPaint(size: const Size(230, 250), painter: _PathPainter()),
              Positioned(
                bottom: 42,
                left: 55,
                child: _MapNode(icon: Icons.home_rounded, unlocked: true),
              ),
              Positioned(
                bottom: 120,
                right: 58,
                child: _MapNode(
                  icon: Icons.flag_rounded,
                  unlocked: completed >= 1,
                ),
              ),
              Positioned(
                top: 70,
                left: 62,
                child: _MapNode(
                  icon: Icons.castle_rounded,
                  unlocked: completed >= total,
                ),
              ),
              Positioned(
                right: 12,
                bottom: 10,
                child: Opacity(
                  opacity: completed >= total ? .78 : .58,
                  child: Image.asset(
                    SacaGrapaAssets.forProgress(progress),
                    width: completed >= total ? 96 : 82,
                    height: completed >= total ? 96 : 82,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _InfoCard(
          assetPath: completed == total
              ? EconomyAssets.legendaryChest
              : EconomyAssets.commonChest,
          color: const Color(0xFF7656D6),
          title: completed == total
              ? '¡Región conquistada!'
              : 'Próxima recompensa',
          subtitle: completed == total
              ? 'El Bosque del Enfoque ya es tuyo.'
              : 'Completa las misiones de hoy para abrir el cofre.',
        ),
      ],
    );
  }
}

class _PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .75)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(35, 225)
      ..cubicTo(190, 210, 190, 145, 115, 132)
      ..cubicTo(35, 115, 65, 60, 180, 28);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapNode extends StatelessWidget {
  const _MapNode({required this.icon, required this.unlocked});
  final IconData icon;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: unlocked ? const Color(0xFFFFFCF6) : const Color(0xFFBBB6AD),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        unlocked ? icon : Icons.lock_rounded,
        color: unlocked ? const Color(0xFF7656D6) : Colors.white,
      ),
    );
  }
}

class _PinView extends StatelessWidget {
  const _PinView({
    required this.hearts,
    required this.justFed,
    required this.onFeed,
  });

  final int hearts;
  final bool justFed;
  final VoidCallback onFeed;

  @override
  Widget build(BuildContext context) {
    final pinScene = PinActionAssets.forMood(hearts: hearts, justFed: justFed);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        const Text(
          'El rincón de Pin',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const Text(
          'Tu pequeño compañero crece con tu constancia.',
          style: TextStyle(color: Color(0xFF81786C)),
        ),
        const SizedBox(height: 24),
        Container(
          height: 330,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE7B8),
            image: DecorationImage(
              image: AssetImage(ScenarioAssets.pinHomeForHearts(hearts)),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.white.withValues(alpha: .30),
                BlendMode.srcATop,
              ),
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 24,
                right: 22,
                child: Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < hearts
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: const Color(0xFFF06B72),
                      size: 20,
                    ),
                  ),
                ),
              ),
              Image.asset(
                pinScene,
                key: ValueKey(pinScene),
                width: 230,
                height: 230,
                fit: BoxFit.contain,
              ),
              const Positioned(
                bottom: 24,
                child: Text(
                  'Pin está esperando su merienda',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onFeed,
          icon: Image.asset(PinHomeAssets.foodBowl, width: 24, height: 24),
          label: const Text('Dar merienda · 10 monedas'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 16),
        _PinHomePreview(hearts: hearts),
      ],
    );
  }
}

class _PinHomePreview extends StatelessWidget {
  const _PinHomePreview({required this.hearts});

  final int hearts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: -4,
                  child: Image.asset(
                    PinHomeAssets.rug,
                    width: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                Image.asset(
                  PinHomeAssets.houseForHearts(hearts),
                  width: 92,
                  fit: BoxFit.contain,
                ),
                if (hearts >= 4)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Image.asset(
                      PinHomeAssets.foodBowl,
                      width: 34,
                      fit: BoxFit.contain,
                    ),
                  ),
                if (hearts >= 5)
                  Positioned(
                    left: 0,
                    bottom: 2,
                    child: Image.asset(
                      PinHomeAssets.lamp,
                      width: 34,
                      fit: BoxFit.contain,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'La casita de Pin',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 3),
                Text(
                  'Mejora el hogar de Pin con rachas y recompensas.',
                  style: TextStyle(color: Color(0xFF81786C), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.streak, required this.coins});
  final int streak;
  final int coins;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        const Text(
          'Tu progreso',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF2F2940),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 98,
                height: 98,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      UiBrandingAssets.grapaAvatarFrame,
                      fit: BoxFit.contain,
                    ),
                    Image.asset(
                      GrapaAssets.neutral,
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Aventurero constante',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _Stat(value: '$streak', label: 'días de racha'),
                  ),
                  Expanded(
                    child: _Stat(value: '$coins', label: 'monedas'),
                  ),
                  const Expanded(
                    child: _Stat(value: 'Nvl. 4', label: 'explorador'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _InfoCard(
          assetPath: UiBrandingAssets.levelBadge,
          color: Color(0xFFF0A445),
          title: 'Una semana imparable',
          subtitle: 'Has mantenido tu aventura durante 7 días seguidos.',
        ),
        const SizedBox(height: 10),
        const _InfoCard(
          icon: Icons.shield_rounded,
          color: Color(0xFF73B597),
          title: '3 victorias sobre Saca Grapas',
          subtitle: 'Tu disciplina está protegiendo el reino.',
        ),
        const SizedBox(height: 10),
        const _ScenarioCard(
          assetPath: ScenarioAssets.rewardShop,
          title: 'Tienda de recompensas',
          subtitle: 'Base para vestidos, decoraciones y premios.',
        ),
        const SizedBox(height: 10),
        const _ShopPreviewSection(),
        const SizedBox(height: 10),
        const _ScenarioCard(
          assetPath: ScenarioAssets.upgradeWorkshop,
          title: 'Taller de mejoras',
          subtitle: 'Base para mejorar la casita de Pin y el equipo.',
        ),
      ],
    );
  }
}

class _ShopPreviewSection extends StatelessWidget {
  const _ShopPreviewSection();

  static const items = [
    _ShopPreviewItem(
      name: 'Vestido',
      price: 120,
      assetPath: ShopItemAssets.grapaDress,
    ),
    _ShopPreviewItem(
      name: 'Lazo',
      price: 80,
      assetPath: ShopItemAssets.grapaBow,
    ),
    _ShopPreviewItem(
      name: 'Sombrero',
      price: 95,
      assetPath: ShopItemAssets.grapaHat,
    ),
    _ShopPreviewItem(
      name: 'Mochila',
      price: 140,
      assetPath: ShopItemAssets.grapaBackpack,
    ),
    _ShopPreviewItem(
      name: 'Cama Pin',
      price: 160,
      assetPath: ShopItemAssets.pinPremiumBed,
    ),
    _ShopPreviewItem(
      name: 'Juguete',
      price: 70,
      assetPath: ShopItemAssets.pinToy,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7D8F4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C3AA8).withValues(alpha: .08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.storefront_rounded, color: Color(0xFF6D49B6)),
              SizedBox(width: 8),
              Text(
                'Objetos disponibles',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 128,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return _ShopItemCard(item: item);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  const _ShopItemCard({required this.item});

  final _ShopPreviewItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 106,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F3FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD8C2EF)),
      ),
      child: Column(
        children: [
          Expanded(child: Image.asset(item.assetPath, fit: BoxFit.contain)),
          const SizedBox(height: 8),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                EconomyAssets.coin,
                width: 16,
                height: 16,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 4),
              Text(
                '${item.price}',
                style: const TextStyle(
                  color: Color(0xFF8B5A11),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShopPreviewItem {
  const _ShopPreviewItem({
    required this.name,
    required this.price,
    required this.assetPath,
  });

  final String name;
  final int price;
  final String assetPath;
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.assetPath,
    required this.title,
    required this.subtitle,
  });

  final String assetPath;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: AssetImage(assetPath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: .24),
            BlendMode.darken,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFFEDE7F7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFC6BDCF), fontSize: 10),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.color,
    required this.title,
    required this.subtitle,
    this.icon,
    this.assetPath,
  });
  final IconData? icon;
  final String? assetPath;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: assetPath == null
                  ? Icon(icon, color: color)
                  : Image.asset(
                      assetPath!,
                      width: 34,
                      height: 34,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF81786C),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
