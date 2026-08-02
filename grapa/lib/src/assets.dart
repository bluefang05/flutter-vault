part of '../main.dart';

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
  static const eatingInRoom =
      'assets/images/pin_accion/pin_accion_13_comiendo_en_habitacion.webp';
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
      'assets/images/escenarios/escenario_01_habitacion_de_grapa.webp';
  static const pinHouseEmpty =
      'assets/images/escenarios/escenario_02_casita_de_pin_vacia.webp';
  static const pinHouseLevel1 =
      'assets/images/escenarios/escenario_03_casita_de_pin_mejorada_nivel_1.webp';
  static const pinHouseLevel2 =
      'assets/images/escenarios/escenario_04_casita_de_pin_mejorada_nivel_2.webp';
  static const focusForest =
      'assets/images/escenarios/escenario_05_bosque_del_enfoque.webp';
  static const disciplineMountain =
      'assets/images/escenarios/escenario_06_montana_de_la_disciplina.webp';
  static const procrastinationSwamp =
      'assets/images/escenarios/escenario_07_pantano_de_la_procrastinacion.webp';
  static const rewardShop =
      'assets/images/escenarios/escenario_08_tienda_de_recompensas.webp';
  static const upgradeWorkshop =
      'assets/images/escenarios/escenario_09_taller_de_mejoras.webp';
  static const failureScreen =
      'assets/images/escenarios/escenario_10_fondo_pantalla_de_fallo.webp';
  static const cleanPinRoom =
      'assets/images/escenarios/escenario_11_habitacion_pin_limpia.webp';
  static const cleanRewardShop =
      'assets/images/escenarios/escenario_12_tienda_limpia.webp';
  static const cleanMissionPath =
      'assets/images/escenarios/escenario_13_misiones_camino_limpio.webp';
  static const cleanRewardsPath =
      'assets/images/escenarios/escenario_14_progreso_recompensas_limpio.webp';
  static const sunsetFailurePath =
      'assets/images/escenarios/escenario_15_fallo_atardecer.webp';

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
  static const grapaDressPremium =
      'assets/images/tienda/tienda_01_vestido_grapa.png';
  static const grapaBowPremium =
      'assets/images/tienda/tienda_11_lazo_grapa_morado.png';
  static const grapaHatPremium =
      'assets/images/tienda/tienda_12_sombrero_grapa_premium.png';
  static const grapaBackpackPremium =
      'assets/images/tienda/tienda_13_mochila_grapa_premium.png';
  static const dressCasual =
      'assets/images/tienda/tienda_14_vestido_casual.png';
  static const dressElegant =
      'assets/images/tienda/tienda_15_vestido_elegante.png';
  static const cozyJacket = 'assets/images/tienda/tienda_16_chaqueta_cozy.png';
  static const winterScarf =
      'assets/images/tienda/tienda_17_bufanda_invernal.png';
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

class GrapaEquippedAssets {
  static const dressPremium =
      'assets/images/grapa_equipped/grapa_equipped_dress_premium_01.png';
  static const dressCasual =
      'assets/images/grapa_equipped/grapa_equipped_dress_casual_01.png';
  static const dressElegant =
      'assets/images/grapa_equipped/grapa_equipped_dress_elegant_01.png';
  static const jacketCozy =
      'assets/images/grapa_equipped/grapa_equipped_jacket_cozy_01.png';
  static const scarfWinter =
      'assets/images/grapa_equipped/grapa_equipped_scarf_winter_01.png';
  static const bowPremium =
      'assets/images/grapa_equipped/grapa_equipped_bow_premium_01.png';
  static const hatPremium =
      'assets/images/grapa_equipped/grapa_equipped_hat_premium_01.png';
  static const backpackPremium =
      'assets/images/grapa_equipped/grapa_equipped_backpack_premium_01.png';

  static bool isKnown(String assetPath) => all.contains(assetPath);

  static const all = [
    dressPremium,
    dressCasual,
    dressElegant,
    jacketCozy,
    scarfWinter,
    bowPremium,
    hatPremium,
    backpackPremium,
  ];
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
