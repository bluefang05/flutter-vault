import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa AdMob. El banner espera a que esta inicialización termine.
  unawaited(MobileAds.instance.initialize());

  await SystemChrome.setPreferredOrientations(
    const <DeviceOrientation>[DeviceOrientation.landscapeLeft],
  );
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const VoxelAnacondaApp());
}

class AppSettings {
  bool hapticsEnabled = true;
  bool soundsEnabled = true;
  bool musicEnabled = true;
  double gameSpeed = 2.0;
  String? languageOverride;
}

class _LanguageOption {
  const _LanguageOption(this.code, this.name);
  final String code;
  final String name;
}

const List<_LanguageOption> _supportedLanguages = <_LanguageOption>[
  _LanguageOption('en', 'English'),
  _LanguageOption('es', 'Español'),
  _LanguageOption('pt', 'Português'),
  _LanguageOption('fr', 'Français'),
  _LanguageOption('de', 'Deutsch'),
  _LanguageOption('it', 'Italiano'),
  _LanguageOption('nl', 'Nederlands'),
  _LanguageOption('pl', 'Polski'),
  _LanguageOption('ru', 'Русский'),
  _LanguageOption('tr', 'Türkçe'),
  _LanguageOption('id', 'Bahasa Indonesia'),
  _LanguageOption('vi', 'Tiếng Việt'),
  _LanguageOption('ja', '日本語'),
  _LanguageOption('ko', '한국어'),
  _LanguageOption('zh', '中文'),
  _LanguageOption('cs', 'Čeština'),
  _LanguageOption('uk', 'Українська'),
  _LanguageOption('ro', 'Română'),
];

const Map<String, Map<String, String>> _uiText = <String, Map<String, String>>{
  'en': <String, String>{
    'tagline': 'Orthogonal Snake in three dimensions',
    'start': 'START GAME',
    'settings': 'SETTINGS',
    'howToPlay': 'HOW TO PLAY',
    'howToPlayTitle': 'HOW TO PLAY',
    'goalTitle': 'Goal',
    'goalHelp': 'Eat orbs, grow the anaconda and survive as long as possible.',
    'controlsTitle': 'Controls',
    'controlsHelp': 'Left pad moves on the floor. Right pad moves up and down.',
    'pauseTitle': 'Pause and zoom',
    'pauseHelpFull':
        'Tap two fingers in the center to pause. While paused, pinch or use the zoom buttons.',
    'itemsTitle': 'Orbs and hazards',
    'itemsHelp':
        'Blessings help, curses punish and temporary obstacles change the route.',
    'modeLine': 'Classic · blessings, curses and temporary obstacles',
    'back': 'Back',
    'language': 'Language',
    'automatic': 'Automatic (device)',
    'languageHelp':
        'Uses the device language by default. You can override it here.',
    'fixedCamera': 'Fixed camera',
    'fixedCameraHelp':
        'Rotation is disabled to make spatial orientation easier to read.',
    'haptics': 'Vibration on controls',
    'sounds': 'Game sounds',
    'soundsHelp': 'Orbs, blessings, curses and new record.',
    'music': 'Background music',
    'musicHelp': 'Ambient music during gameplay.',
    'speed': 'Speed: {value} cells/s',
    'done': 'DONE',
    'pauseHint': '2 fingers in the center = pause',
    'continue': 'CONTINUE',
    'gameOver': 'GAME OVER',
    'newRecord': '★  NEW RECORD  ★',
    'scoreLine': 'Score: {score}     Length: {length}     Best: {best}',
    'restart': 'RESTART',
    'menu': 'MENU',
    'tacticalPause': 'TACTICAL PAUSE',
    'pauseHelp': 'Fixed camera · pinch to zoom',
    'movesDebug': 'Moves: {moves} · head {head}',
    'ad': 'AD',
    'testAd': 'TEST AD',
  },
  'es': <String, String>{
    'tagline': 'Snake ortogonal en tres dimensiones',
    'start': 'INICIAR JUEGO',
    'settings': 'AJUSTES',
    'howToPlay': 'COMO JUGAR',
    'howToPlayTitle': 'COMO JUGAR',
    'goalTitle': 'Objetivo',
    'goalHelp':
        'Come orbes, haz crecer la anaconda y sobrevive el mayor tiempo posible.',
    'controlsTitle': 'Controles',
    'controlsHelp':
        'El pad izquierdo mueve en el suelo. El pad derecho sube y baja.',
    'pauseTitle': 'Pausa y zoom',
    'pauseHelpFull':
        'Toca con dos dedos en el centro para pausar. En pausa, pellizca o usa los botones de zoom.',
    'itemsTitle': 'Orbes y peligros',
    'itemsHelp':
        'Las bendiciones ayudan, las maldiciones castigan y los obstaculos temporales cambian la ruta.',
    'modeLine': 'Clásico · bendiciones, maldiciones y obstáculos temporales',
    'back': 'Volver',
    'language': 'Idioma',
    'automatic': 'Automático (dispositivo)',
    'languageHelp':
        'Usa el idioma del dispositivo por defecto. Puedes cambiarlo aquí.',
    'fixedCamera': 'Cámara fija',
    'fixedCameraHelp':
        'La rotación está desactivada para facilitar la orientación espacial.',
    'haptics': 'Vibración al tocar controles',
    'sounds': 'Sonidos del juego',
    'soundsHelp': 'Orbes, bendiciones, maldiciones y nuevo récord.',
    'music': 'Música de fondo',
    'musicHelp': 'Música ambiental durante la partida.',
    'speed': 'Velocidad: {value} celdas/s',
    'done': 'LISTO',
    'pauseHint': '2 dedos en el centro = pausa',
    'continue': 'CONTINUAR',
    'gameOver': 'FIN DE LA PARTIDA',
    'newRecord': '★  NUEVO RÉCORD  ★',
    'scoreLine': 'Puntos: {score}     Longitud: {length}     Récord: {best}',
    'restart': 'REINICIAR',
    'menu': 'MENÚ',
    'tacticalPause': 'PAUSA TÁCTICA',
    'pauseHelp': 'Cámara fija · pellizca para zoom',
    'movesDebug': 'Movimientos: {moves} · cabeza {head}',
    'ad': 'ANUNCIO',
    'testAd': 'ANUNCIO DE PRUEBA',
  },
  'pt': <String, String>{
    'tagline': 'Snake ortogonal em três dimensões',
    'start': 'INICIAR JOGO',
    'settings': 'AJUSTES',
    'modeLine': 'Clássico · bênçãos, maldições e obstáculos temporários',
    'back': 'Voltar',
    'language': 'Idioma',
    'automatic': 'Automático (dispositivo)',
    'languageHelp':
        'Usa o idioma do dispositivo por padrão. Você pode alterá-lo aqui.',
    'fixedCamera': 'Câmera fixa',
    'fixedCameraHelp':
        'A rotação está desativada para facilitar a orientação espacial.',
    'haptics': 'Vibração nos controles',
    'sounds': 'Sons do jogo',
    'soundsHelp': 'Orbes, bênçãos, maldições e novo recorde.',
    'music': 'Música de fundo',
    'musicHelp': 'Música ambiente durante a partida.',
    'speed': 'Velocidade: {value} células/s',
    'done': 'PRONTO',
    'pauseHint': '2 dedos no centro = pausa',
    'continue': 'CONTINUAR',
    'gameOver': 'FIM DE JOGO',
    'newRecord': '★  NOVO RECORDE  ★',
    'scoreLine':
        'Pontos: {score}     Comprimento: {length}     Recorde: {best}',
    'restart': 'REINICIAR',
    'menu': 'MENU',
    'tacticalPause': 'PAUSA TÁTICA',
    'pauseHelp': 'Câmera fixa · belisque para zoom',
    'movesDebug': 'Movimentos: {moves} · cabeça {head}',
    'ad': 'ANÚNCIO',
    'testAd': 'ANÚNCIO DE TESTE',
  },
  'fr': <String, String>{
    'tagline': 'Snake orthogonal en trois dimensions',
    'start': 'JOUER',
    'settings': 'PARAMÈTRES',
    'modeLine':
        'Classique · bénédictions, malédictions et obstacles temporaires',
    'back': 'Retour',
    'language': 'Langue',
    'automatic': 'Automatique (appareil)',
    'languageHelp':
        'Utilise la langue de l’appareil par défaut. Vous pouvez la modifier ici.',
    'fixedCamera': 'Caméra fixe',
    'fixedCameraHelp':
        'La rotation est désactivée pour mieux lire l’orientation spatiale.',
    'haptics': 'Vibration des commandes',
    'sounds': 'Sons du jeu',
    'soundsHelp': 'Orbes, bénédictions, malédictions et nouveau record.',
    'music': 'Musique de fond',
    'musicHelp': 'Musique d’ambiance pendant la partie.',
    'speed': 'Vitesse : {value} cases/s',
    'done': 'TERMINÉ',
    'pauseHint': '2 doigts au centre = pause',
    'continue': 'CONTINUER',
    'gameOver': 'FIN DE PARTIE',
    'newRecord': '★  NOUVEAU RECORD  ★',
    'scoreLine': 'Score : {score}     Longueur : {length}     Record : {best}',
    'restart': 'RECOMMENCER',
    'menu': 'MENU',
    'tacticalPause': 'PAUSE TACTIQUE',
    'pauseHelp': 'Caméra fixe · pincez pour zoomer',
    'movesDebug': 'Mouvements : {moves} · tête {head}',
    'ad': 'PUB',
    'testAd': 'PUB TEST',
  },
  'de': <String, String>{
    'tagline': 'Orthogonales Snake in drei Dimensionen',
    'start': 'SPIEL STARTEN',
    'settings': 'EINSTELLUNGEN',
    'modeLine': 'Klassisch · Segen, Flüche und temporäre Hindernisse',
    'back': 'Zurück',
    'language': 'Sprache',
    'automatic': 'Automatisch (Gerät)',
    'languageHelp':
        'Standardmäßig wird die Gerätesprache verwendet. Hier kannst du sie ändern.',
    'fixedCamera': 'Feste Kamera',
    'fixedCameraHelp':
        'Die Rotation ist deaktiviert, damit die räumliche Orientierung klarer bleibt.',
    'haptics': 'Vibration bei Steuerung',
    'sounds': 'Spielgeräusche',
    'soundsHelp': 'Orbs, Segen, Flüche und neuer Rekord.',
    'music': 'Hintergrundmusik',
    'musicHelp': 'Atmosphärische Musik während des Spiels.',
    'speed': 'Geschwindigkeit: {value} Felder/s',
    'done': 'FERTIG',
    'pauseHint': '2 Finger in der Mitte = Pause',
    'continue': 'WEITER',
    'gameOver': 'SPIEL VORBEI',
    'newRecord': '★  NEUER REKORD  ★',
    'scoreLine': 'Punkte: {score}     Länge: {length}     Rekord: {best}',
    'restart': 'NEUSTART',
    'menu': 'MENÜ',
    'tacticalPause': 'TAKTISCHE PAUSE',
    'pauseHelp': 'Feste Kamera · zum Zoomen kneifen',
    'movesDebug': 'Züge: {moves} · Kopf {head}',
    'ad': 'ANZEIGE',
    'testAd': 'TESTANZEIGE',
  },
  'it': <String, String>{
    'tagline': 'Snake ortogonale in tre dimensioni',
    'start': 'INIZIA GIOCO',
    'settings': 'IMPOSTAZIONI',
    'modeLine': 'Classico · benedizioni, maledizioni e ostacoli temporanei',
    'back': 'Indietro',
    'language': 'Lingua',
    'automatic': 'Automatico (dispositivo)',
    'languageHelp':
        'Usa la lingua del dispositivo per impostazione predefinita. Puoi cambiarla qui.',
    'fixedCamera': 'Camera fissa',
    'fixedCameraHelp':
        'La rotazione è disattivata per rendere più chiaro l’orientamento spaziale.',
    'haptics': 'Vibrazione sui controlli',
    'sounds': 'Suoni di gioco',
    'soundsHelp': 'Sfere, benedizioni, maledizioni e nuovo record.',
    'music': 'Musica di sottofondo',
    'musicHelp': 'Musica ambientale durante la partita.',
    'speed': 'Velocità: {value} celle/s',
    'done': 'FATTO',
    'pauseHint': '2 dita al centro = pausa',
    'continue': 'CONTINUA',
    'gameOver': 'FINE PARTITA',
    'newRecord': '★  NUOVO RECORD  ★',
    'scoreLine': 'Punti: {score}     Lunghezza: {length}     Record: {best}',
    'restart': 'RICOMINCIA',
    'menu': 'MENU',
    'tacticalPause': 'PAUSA TATTICA',
    'pauseHelp': 'Camera fissa · pizzica per zoom',
    'movesDebug': 'Mosse: {moves} · testa {head}',
    'ad': 'ANNUNCIO',
    'testAd': 'ANNUNCIO DI TEST',
  },
  'nl': <String, String>{
    'tagline': 'Orthogonale Snake in drie dimensies',
    'start': 'START SPEL',
    'settings': 'INSTELLINGEN',
    'modeLine': 'Klassiek · zegeningen, vloeken en tijdelijke obstakels',
    'back': 'Terug',
    'language': 'Taal',
    'automatic': 'Automatisch (apparaat)',
    'languageHelp':
        'Gebruikt standaard de taal van het apparaat. Je kunt die hier wijzigen.',
    'fixedCamera': 'Vaste camera',
    'fixedCameraHelp':
        'Rotatie is uitgeschakeld om ruimtelijke oriëntatie duidelijker te maken.',
    'haptics': 'Trillen bij bediening',
    'sounds': 'Spelgeluiden',
    'soundsHelp': 'Orbs, zegeningen, vloeken en nieuw record.',
    'music': 'Achtergrondmuziek',
    'musicHelp': 'Sfeermuziek tijdens het spelen.',
    'speed': 'Snelheid: {value} cellen/s',
    'done': 'KLAAR',
    'pauseHint': '2 vingers in het midden = pauze',
    'continue': 'DOORGAAN',
    'gameOver': 'SPEL VOORBIJ',
    'newRecord': '★  NIEUW RECORD  ★',
    'scoreLine': 'Score: {score}     Lengte: {length}     Record: {best}',
    'restart': 'OPNIEUW',
    'menu': 'MENU',
    'tacticalPause': 'TACTISCHE PAUZE',
    'pauseHelp': 'Vaste camera · knijp om te zoomen',
    'movesDebug': 'Zetten: {moves} · kop {head}',
    'ad': 'ADVERTENTIE',
    'testAd': 'TESTADVERTENTIE',
  },
  'pl': <String, String>{
    'tagline': 'Ortogonalny Snake w trzech wymiarach',
    'start': 'ROZPOCZNIJ GRĘ',
    'settings': 'USTAWIENIA',
    'modeLine': 'Klasyczny · błogosławieństwa, klątwy i tymczasowe przeszkody',
    'back': 'Wstecz',
    'language': 'Język',
    'automatic': 'Automatycznie (urządzenie)',
    'languageHelp':
        'Domyślnie używa języka urządzenia. Możesz go tutaj zmienić.',
    'fixedCamera': 'Stała kamera',
    'fixedCameraHelp':
        'Obrót jest wyłączony, aby ułatwić orientację przestrzenną.',
    'haptics': 'Wibracje sterowania',
    'sounds': 'Dźwięki gry',
    'soundsHelp': 'Kule, błogosławieństwa, klątwy i nowy rekord.',
    'music': 'Muzyka w tle',
    'musicHelp': 'Muzyka ambientowa podczas gry.',
    'speed': 'Prędkość: {value} pól/s',
    'done': 'GOTOWE',
    'pauseHint': '2 palce na środku = pauza',
    'continue': 'KONTYNUUJ',
    'gameOver': 'KONIEC GRY',
    'newRecord': '★  NOWY REKORD  ★',
    'scoreLine': 'Punkty: {score}     Długość: {length}     Rekord: {best}',
    'restart': 'RESTART',
    'menu': 'MENU',
    'tacticalPause': 'PAUZA TAKTYCZNA',
    'pauseHelp': 'Stała kamera · uszczypnij, aby powiększyć',
    'movesDebug': 'Ruchy: {moves} · głowa {head}',
    'ad': 'REKLAMA',
    'testAd': 'REKLAMA TESTOWA',
  },
  'ru': <String, String>{
    'tagline': 'Ортогональная Snake в трёх измерениях',
    'start': 'НАЧАТЬ ИГРУ',
    'settings': 'НАСТРОЙКИ',
    'modeLine': 'Классика · благословения, проклятия и временные препятствия',
    'back': 'Назад',
    'language': 'Язык',
    'automatic': 'Авто (устройство)',
    'languageHelp':
        'По умолчанию используется язык устройства. Здесь его можно изменить.',
    'fixedCamera': 'Фиксированная камера',
    'fixedCameraHelp':
        'Вращение отключено для более понятной пространственной ориентации.',
    'haptics': 'Вибрация управления',
    'sounds': 'Звуки игры',
    'soundsHelp': 'Сферы, благословения, проклятия и новый рекорд.',
    'music': 'Фоновая музыка',
    'musicHelp': 'Атмосферная музыка во время игры.',
    'speed': 'Скорость: {value} клеток/с',
    'done': 'ГОТОВО',
    'pauseHint': '2 пальца в центре = пауза',
    'continue': 'ПРОДОЛЖИТЬ',
    'gameOver': 'КОНЕЦ ИГРЫ',
    'newRecord': '★  НОВЫЙ РЕКОРД  ★',
    'scoreLine': 'Очки: {score}     Длина: {length}     Рекорд: {best}',
    'restart': 'ЗАНОВО',
    'menu': 'МЕНЮ',
    'tacticalPause': 'ТАКТИЧЕСКАЯ ПАУЗА',
    'pauseHelp': 'Фиксированная камера · щипок для масштаба',
    'movesDebug': 'Ходы: {moves} · голова {head}',
    'ad': 'РЕКЛАМА',
    'testAd': 'ТЕСТОВАЯ РЕКЛАМА',
  },
  'tr': <String, String>{
    'tagline': 'Üç boyutlu ortogonal Snake',
    'start': 'OYUNU BAŞLAT',
    'settings': 'AYARLAR',
    'modeLine': 'Klasik · kutsamalar, lanetler ve geçici engeller',
    'back': 'Geri',
    'language': 'Dil',
    'automatic': 'Otomatik (cihaz)',
    'languageHelp':
        'Varsayılan olarak cihaz dilini kullanır. Buradan değiştirebilirsiniz.',
    'fixedCamera': 'Sabit kamera',
    'fixedCameraHelp':
        'Mekânsal yönü daha kolay okumak için döndürme kapalıdır.',
    'haptics': 'Kontrol titreşimi',
    'sounds': 'Oyun sesleri',
    'soundsHelp': 'Küreler, kutsamalar, lanetler ve yeni rekor.',
    'music': 'Arka plan müziği',
    'musicHelp': 'Oyun sırasında ortam müziği.',
    'speed': 'Hız: {value} hücre/sn',
    'done': 'TAMAM',
    'pauseHint': 'Ortada 2 parmak = duraklat',
    'continue': 'DEVAM',
    'gameOver': 'OYUN BİTTİ',
    'newRecord': '★  YENİ REKOR  ★',
    'scoreLine': 'Puan: {score}     Uzunluk: {length}     Rekor: {best}',
    'restart': 'YENİDEN',
    'menu': 'MENÜ',
    'tacticalPause': 'TAKTİK DURAKLATMA',
    'pauseHelp': 'Sabit kamera · yakınlaştırmak için sıkıştır',
    'movesDebug': 'Hamle: {moves} · baş {head}',
    'ad': 'REKLAM',
    'testAd': 'TEST REKLAMI',
  },
  'id': <String, String>{
    'tagline': 'Snake ortogonal dalam tiga dimensi',
    'start': 'MULAI GAME',
    'settings': 'PENGATURAN',
    'modeLine': 'Klasik · berkah, kutukan, dan rintangan sementara',
    'back': 'Kembali',
    'language': 'Bahasa',
    'automatic': 'Otomatis (perangkat)',
    'languageHelp':
        'Secara default menggunakan bahasa perangkat. Anda dapat mengubahnya di sini.',
    'fixedCamera': 'Kamera tetap',
    'fixedCameraHelp':
        'Rotasi dinonaktifkan agar orientasi ruang lebih mudah dibaca.',
    'haptics': 'Getaran kontrol',
    'sounds': 'Suara game',
    'soundsHelp': 'Orb, berkah, kutukan, dan rekor baru.',
    'music': 'Musik latar',
    'musicHelp': 'Musik atmosfer selama bermain.',
    'speed': 'Kecepatan: {value} sel/dtk',
    'done': 'SELESAI',
    'pauseHint': '2 jari di tengah = jeda',
    'continue': 'LANJUT',
    'gameOver': 'GAME SELESAI',
    'newRecord': '★  REKOR BARU  ★',
    'scoreLine': 'Poin: {score}     Panjang: {length}     Rekor: {best}',
    'restart': 'ULANG',
    'menu': 'MENU',
    'tacticalPause': 'JEDA TAKTIS',
    'pauseHelp': 'Kamera tetap · cubit untuk zoom',
    'movesDebug': 'Langkah: {moves} · kepala {head}',
    'ad': 'IKLAN',
    'testAd': 'IKLAN UJI',
  },
  'vi': <String, String>{
    'tagline': 'Snake trực giao trong không gian ba chiều',
    'start': 'BẮT ĐẦU',
    'settings': 'CÀI ĐẶT',
    'modeLine': 'Cổ điển · phước lành, lời nguyền và chướng ngại tạm thời',
    'back': 'Quay lại',
    'language': 'Ngôn ngữ',
    'automatic': 'Tự động (thiết bị)',
    'languageHelp':
        'Mặc định dùng ngôn ngữ thiết bị. Bạn có thể thay đổi tại đây.',
    'fixedCamera': 'Camera cố định',
    'fixedCameraHelp': 'Đã tắt xoay để dễ định hướng không gian hơn.',
    'haptics': 'Rung khi điều khiển',
    'sounds': 'Âm thanh trò chơi',
    'soundsHelp': 'Quả cầu, phước lành, lời nguyền và kỷ lục mới.',
    'music': 'Nhạc nền',
    'musicHelp': 'Nhạc không khí trong khi chơi.',
    'speed': 'Tốc độ: {value} ô/giây',
    'done': 'XONG',
    'pauseHint': '2 ngón ở giữa = tạm dừng',
    'continue': 'TIẾP TỤC',
    'gameOver': 'KẾT THÚC',
    'newRecord': '★  KỶ LỤC MỚI  ★',
    'scoreLine': 'Điểm: {score}     Độ dài: {length}     Kỷ lục: {best}',
    'restart': 'CHƠI LẠI',
    'menu': 'MENU',
    'tacticalPause': 'TẠM DỪNG CHIẾN THUẬT',
    'pauseHelp': 'Camera cố định · chụm để thu phóng',
    'movesDebug': 'Bước: {moves} · đầu {head}',
    'ad': 'QUẢNG CÁO',
    'testAd': 'QUẢNG CÁO THỬ',
  },
  'ja': <String, String>{
    'tagline': '3次元の直交スネーク',
    'start': 'ゲーム開始',
    'settings': '設定',
    'modeLine': 'クラシック · 祝福、呪い、一時的な障害物',
    'back': '戻る',
    'language': '言語',
    'automatic': '自動（端末）',
    'languageHelp': '既定では端末の言語を使用します。ここで変更できます。',
    'fixedCamera': '固定カメラ',
    'fixedCameraHelp': '空間位置を読みやすくするため回転を無効にしています。',
    'haptics': '操作時の振動',
    'sounds': 'ゲーム効果音',
    'soundsHelp': 'オーブ、祝福、呪い、新記録。',
    'music': 'BGM',
    'musicHelp': 'プレイ中のアンビエント音楽。',
    'speed': '速度: {value} マス/秒',
    'done': '完了',
    'pauseHint': '中央を2本指 = ポーズ',
    'continue': '続ける',
    'gameOver': 'ゲームオーバー',
    'newRecord': '★  新記録  ★',
    'scoreLine': 'スコア: {score}     長さ: {length}     ベスト: {best}',
    'restart': 'リスタート',
    'menu': 'メニュー',
    'tacticalPause': '戦術ポーズ',
    'pauseHelp': '固定カメラ · ピンチでズーム',
    'movesDebug': '移動: {moves} · 頭 {head}',
    'ad': '広告',
    'testAd': 'テスト広告',
  },
  'ko': <String, String>{
    'tagline': '3차원 직교 스네이크',
    'start': '게임 시작',
    'settings': '설정',
    'modeLine': '클래식 · 축복, 저주, 임시 장애물',
    'back': '뒤로',
    'language': '언어',
    'automatic': '자동 (기기)',
    'languageHelp': '기본적으로 기기 언어를 사용합니다. 여기서 변경할 수 있습니다.',
    'fixedCamera': '고정 카메라',
    'fixedCameraHelp': '공간 방향을 더 쉽게 읽도록 회전을 비활성화했습니다.',
    'haptics': '조작 진동',
    'sounds': '게임 사운드',
    'soundsHelp': '오브, 축복, 저주, 새 기록.',
    'music': '배경 음악',
    'musicHelp': '플레이 중 앰비언트 음악.',
    'speed': '속도: {value} 칸/초',
    'done': '완료',
    'pauseHint': '중앙에서 두 손가락 = 일시정지',
    'continue': '계속',
    'gameOver': '게임 오버',
    'newRecord': '★  새 기록  ★',
    'scoreLine': '점수: {score}     길이: {length}     최고: {best}',
    'restart': '다시 시작',
    'menu': '메뉴',
    'tacticalPause': '전술 일시정지',
    'pauseHelp': '고정 카메라 · 핀치로 확대',
    'movesDebug': '이동: {moves} · 머리 {head}',
    'ad': '광고',
    'testAd': '테스트 광고',
  },
  'zh': <String, String>{
    'tagline': '三维正交贪吃蛇',
    'start': '开始游戏',
    'settings': '设置',
    'modeLine': '经典 · 祝福、诅咒与临时障碍',
    'back': '返回',
    'language': '语言',
    'automatic': '自动（设备）',
    'languageHelp': '默认使用设备语言，也可以在这里手动更改。',
    'fixedCamera': '固定镜头',
    'fixedCameraHelp': '关闭旋转，让空间位置更容易判断。',
    'haptics': '控制振动',
    'sounds': '游戏音效',
    'soundsHelp': '光球、祝福、诅咒和新纪录。',
    'music': '背景音乐',
    'musicHelp': '游戏中的氛围音乐。',
    'speed': '速度：{value} 格/秒',
    'done': '完成',
    'pauseHint': '中央双指 = 暂停',
    'continue': '继续',
    'gameOver': '游戏结束',
    'newRecord': '★  新纪录  ★',
    'scoreLine': '分数：{score}     长度：{length}     纪录：{best}',
    'restart': '重新开始',
    'menu': '菜单',
    'tacticalPause': '战术暂停',
    'pauseHelp': '固定镜头 · 双指缩放',
    'movesDebug': '移动：{moves} · 头部 {head}',
    'ad': '广告',
    'testAd': '测试广告',
  },
  'cs': <String, String>{
    'tagline': 'Ortogonální Snake ve třech rozměrech',
    'start': 'SPUSTIT HRU',
    'settings': 'NASTAVENÍ',
    'modeLine': 'Klasika · požehnání, kletby a dočasné překážky',
    'back': 'Zpět',
    'language': 'Jazyk',
    'automatic': 'Automaticky (zařízení)',
    'languageHelp':
        'Ve výchozím nastavení používá jazyk zařízení. Zde jej můžete změnit.',
    'fixedCamera': 'Pevná kamera',
    'fixedCameraHelp':
        'Rotace je vypnutá, aby byla prostorová orientace čitelnější.',
    'haptics': 'Vibrace ovládání',
    'sounds': 'Zvuky hry',
    'soundsHelp': 'Orby, požehnání, kletby a nový rekord.',
    'music': 'Hudba na pozadí',
    'musicHelp': 'Ambientní hudba během hry.',
    'speed': 'Rychlost: {value} polí/s',
    'done': 'HOTOVO',
    'pauseHint': '2 prsty uprostřed = pauza',
    'continue': 'POKRAČOVAT',
    'gameOver': 'KONEC HRY',
    'newRecord': '★  NOVÝ REKORD  ★',
    'scoreLine': 'Skóre: {score}     Délka: {length}     Rekord: {best}',
    'restart': 'RESTART',
    'menu': 'MENU',
    'tacticalPause': 'TAKTICKÁ PAUZA',
    'pauseHelp': 'Pevná kamera · sevřením přiblížit',
    'movesDebug': 'Tahy: {moves} · hlava {head}',
    'ad': 'REKLAMA',
    'testAd': 'TESTOVACÍ REKLAMA',
  },
  'uk': <String, String>{
    'tagline': 'Ортогональна Snake у трьох вимірах',
    'start': 'ПОЧАТИ ГРУ',
    'settings': 'НАЛАШТУВАННЯ',
    'modeLine': 'Класика · благословення, прокляття й тимчасові перешкоди',
    'back': 'Назад',
    'language': 'Мова',
    'automatic': 'Автоматично (пристрій)',
    'languageHelp':
        'Типово використовується мова пристрою. Тут її можна змінити.',
    'fixedCamera': 'Фіксована камера',
    'fixedCameraHelp':
        'Обертання вимкнено, щоб просторову орієнтацію було легше читати.',
    'haptics': 'Вібрація керування',
    'sounds': 'Звуки гри',
    'soundsHelp': 'Сфери, благословення, прокляття та новий рекорд.',
    'music': 'Фонова музика',
    'musicHelp': 'Атмосферна музика під час гри.',
    'speed': 'Швидкість: {value} клітин/с',
    'done': 'ГОТОВО',
    'pauseHint': '2 пальці в центрі = пауза',
    'continue': 'ПРОДОВЖИТИ',
    'gameOver': 'КІНЕЦЬ ГРИ',
    'newRecord': '★  НОВИЙ РЕКОРД  ★',
    'scoreLine': 'Очки: {score}     Довжина: {length}     Рекорд: {best}',
    'restart': 'ЗНОВУ',
    'menu': 'МЕНЮ',
    'tacticalPause': 'ТАКТИЧНА ПАУЗА',
    'pauseHelp': 'Фіксована камера · щипок для масштабу',
    'movesDebug': 'Ходи: {moves} · голова {head}',
    'ad': 'РЕКЛАМА',
    'testAd': 'ТЕСТОВА РЕКЛАМА',
  },
  'ro': <String, String>{
    'tagline': 'Snake ortogonal în trei dimensiuni',
    'start': 'PORNEȘTE JOCUL',
    'settings': 'SETĂRI',
    'modeLine': 'Clasic · binecuvântări, blesteme și obstacole temporare',
    'back': 'Înapoi',
    'language': 'Limbă',
    'automatic': 'Automat (dispozitiv)',
    'languageHelp':
        'Folosește implicit limba dispozitivului. O poți schimba aici.',
    'fixedCamera': 'Cameră fixă',
    'fixedCameraHelp':
        'Rotirea este dezactivată pentru o orientare spațială mai clară.',
    'haptics': 'Vibrații la comenzi',
    'sounds': 'Sunete joc',
    'soundsHelp': 'Orbe, binecuvântări, blesteme și record nou.',
    'music': 'Muzică de fundal',
    'musicHelp': 'Muzică ambientală în timpul jocului.',
    'speed': 'Viteză: {value} celule/s',
    'done': 'GATA',
    'pauseHint': '2 degete în centru = pauză',
    'continue': 'CONTINUĂ',
    'gameOver': 'SFÂRȘITUL JOCULUI',
    'newRecord': '★  RECORD NOU  ★',
    'scoreLine': 'Puncte: {score}     Lungime: {length}     Record: {best}',
    'restart': 'REÎNCEPE',
    'menu': 'MENIU',
    'tacticalPause': 'PAUZĂ TACTICĂ',
    'pauseHelp': 'Cameră fixă · ciupește pentru zoom',
    'movesDebug': 'Mișcări: {moves} · cap {head}',
    'ad': 'RECLAMĂ',
    'testAd': 'RECLAMĂ TEST',
  },
};

bool _isSupportedLanguage(String code) =>
    _supportedLanguages.any((_LanguageOption item) => item.code == code);

String _deviceLanguageCode() {
  final String code = WidgetsBinding
      .instance.platformDispatcher.locale.languageCode
      .toLowerCase();
  return _isSupportedLanguage(code) ? code : 'en';
}

String _effectiveLanguageCode(AppSettings settings) {
  final String? override = settings.languageOverride;
  if (override != null && _isSupportedLanguage(override)) return override;
  return _deviceLanguageCode();
}

String _trCode(String code, String key) {
  return _uiText[code]?[key] ?? _uiText['en']![key] ?? key;
}

String _tr(AppSettings settings, String key) =>
    _trCode(_effectiveLanguageCode(settings), key);

String _fill(String value, Map<String, Object> replacements) {
  String out = value;
  replacements.forEach((String key, Object replacement) {
    out = out.replaceAll('{$key}', replacement.toString());
  });
  return out;
}

String _languageName(String code) {
  for (final _LanguageOption item in _supportedLanguages) {
    if (item.code == code) return item.name;
  }
  return code;
}

class VoxelAnacondaApp extends StatefulWidget {
  const VoxelAnacondaApp({super.key});

  @override
  State<VoxelAnacondaApp> createState() => _VoxelAnacondaAppState();
}

class _VoxelAnacondaAppState extends State<VoxelAnacondaApp> {
  final AppSettings settings = AppSettings();

  void _changeLanguage(String? code) {
    setState(() {
      settings.languageOverride = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voxel Anaconda',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF050812),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE18A2E),
          brightness: Brightness.dark,
        ),
      ),
      home: MainMenuScreen(
          settings: settings, onLanguageChanged: _changeLanguage),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({
    super.key,
    required this.settings,
    required this.onLanguageChanged,
  });

  final AppSettings settings;
  final ValueChanged<String?> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    String t(String key) => _tr(settings, key);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const _MenuBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        'VOXEL',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 11,
                          color: Color(0xFFBAC7E5),
                        ),
                      ),
                      const Text(
                        'ANACONDA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 50,
                          height: 0.95,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        t('tagline'),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.62),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _MenuButton(
                        icon: Icons.play_arrow_rounded,
                        label: t('start'),
                        emphasized: true,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => GameScreen(settings: settings),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _MenuButton(
                        icon: Icons.help_outline_rounded,
                        label: t('howToPlay'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => HelpScreen(settings: settings),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _MenuButton(
                        icon: Icons.tune_rounded,
                        label: t('settings'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => SettingsScreen(
                                  settings: settings,
                                  onLanguageChanged: onLanguageChanged),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({
    super.key,
    required this.settings,
  });

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    String t(String key) => _tr(settings, key);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const _MenuBackground(),
          SafeArea(
            child: Row(
              children: <Widget>[
                IconButton(
                  tooltip: t('back'),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(26, 20, 52, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              t('howToPlayTitle'),
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              t('modeLine'),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.58),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _SettingsCard(
                              child: Column(
                                children: <Widget>[
                                  _HelpRow(
                                    icon: Icons.track_changes_rounded,
                                    title: t('goalTitle'),
                                    body: t('goalHelp'),
                                  ),
                                  const Divider(height: 1),
                                  _HelpRow(
                                    icon: Icons.gamepad_rounded,
                                    title: t('controlsTitle'),
                                    body: t('controlsHelp'),
                                  ),
                                  const Divider(height: 1),
                                  _HelpRow(
                                    icon: Icons.zoom_in_rounded,
                                    title: t('pauseTitle'),
                                    body: t('pauseHelpFull'),
                                  ),
                                  const Divider(height: 1),
                                  _HelpRow(
                                    icon: Icons.auto_awesome_rounded,
                                    title: t('itemsTitle'),
                                    body: t('itemsHelp'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.check_rounded),
                              label: Text(t('done')),
                            ),
                          ],
                        ),
                      ),
                    ),
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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onLanguageChanged,
  });

  final AppSettings settings;
  final ValueChanged<String?> onLanguageChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppSettings get s => widget.settings;

  @override
  Widget build(BuildContext context) {
    String t(String key) => _tr(s, key);
    final String deviceCode = _deviceLanguageCode();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const _MenuBackground(),
          SafeArea(
            child: Row(
              children: <Widget>[
                IconButton(
                  tooltip: t('back'),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(26, 20, 52, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              t('settings'),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _SettingsCard(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 12, 16, 14),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text(
                                      t('language'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      t('languageHelp'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white
                                            .withValues(alpha: 0.62),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    DropdownButtonFormField<String>(
                                      initialValue:
                                          s.languageOverride ?? '__auto__',
                                      isExpanded: true,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      items: <DropdownMenuItem<String>>[
                                        DropdownMenuItem<String>(
                                          value: '__auto__',
                                          child: Text(
                                            '${t('automatic')} · ${_languageName(deviceCode)}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        ..._supportedLanguages.map(
                                          (_LanguageOption item) =>
                                              DropdownMenuItem<String>(
                                            value: item.code,
                                            child: Text(item.name),
                                          ),
                                        ),
                                      ],
                                      onChanged: (String? value) {
                                        final String? code =
                                            value == '__auto__' ? null : value;
                                        setState(
                                            () => s.languageOverride = code);
                                        widget.onLanguageChanged(code);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _SettingsCard(
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    leading:
                                        const Icon(Icons.visibility_rounded),
                                    title: Text(t('fixedCamera')),
                                    subtitle: Text(t('fixedCameraHelp')),
                                  ),
                                  const Divider(height: 1),
                                  SwitchListTile(
                                    title: Text(t('haptics')),
                                    value: s.hapticsEnabled,
                                    onChanged: (bool value) {
                                      setState(() => s.hapticsEnabled = value);
                                    },
                                  ),
                                  const Divider(height: 1),
                                  SwitchListTile(
                                    title: Text(t('sounds')),
                                    subtitle: Text(t('soundsHelp')),
                                    value: s.soundsEnabled,
                                    onChanged: (bool value) {
                                      setState(() => s.soundsEnabled = value);
                                    },
                                  ),
                                  const Divider(height: 1),
                                  SwitchListTile(
                                    title: Text(t('music')),
                                    subtitle: Text(t('musicHelp')),
                                    value: s.musicEnabled,
                                    onChanged: (bool value) {
                                      setState(() => s.musicEnabled = value);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _SettingsCard(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text(
                                      _fill(t('speed'), <String, Object>{
                                        'value': s.gameSpeed.toStringAsFixed(1)
                                      }),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Slider(
                                      value: s.gameSpeed,
                                      min: 1.0,
                                      max: 8.0,
                                      divisions: 14,
                                      onChanged: (double value) {
                                        setState(() => s.gameSpeed = value);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.check_rounded),
                              label: Text(t('done')),
                            ),
                          ],
                        ),
                      ),
                    ),
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

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.settings,
  });

  final AppSettings settings;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final WebViewController _web;

  bool _webReady = false;
  bool _paused = false;
  bool _gameOver = false;
  int _finalScore = 0;
  int _finalLength = 2;
  int _finalMoves = 0;
  int _bestScore = 0;
  bool _newRecord = false;
  String _deathReason = '';
  String _deathDebug = '';
  double _zoom = 2.0;

  final Map<int, Offset> _centerPointers = <int, Offset>{};
  Map<int, Offset> _tapStartPositions = <int, Offset>{};
  DateTime? _twoFingerStartedAt;
  bool _twoFingerTapCandidate = false;
  double? _pinchStartDistance;
  double _pinchStartZoom = 1.0;

  @override
  void initState() {
    super.initState();

    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF050812))
      ..enableZoom(false)
      ..addJavaScriptChannel(
        'FlutterGame',
        onMessageReceived: _onGameMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            _webReady = true;
            _sendZoom();
            _sendPauseState();
            _sendSpeed();
            _sendSoundState();
            _sendMusicState();
            _sendLanguage();
          },
        ),
      )
      ..loadFlutterAsset('assets/web/index.html');

    if (_web.platform is AndroidWebViewController) {
      unawaited(
        (_web.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false),
      );
    }
  }

  void _onGameMessage(JavaScriptMessage message) {
    try {
      final dynamic decoded = jsonDecode(message.message);
      if (decoded is! Map<String, dynamic>) return;

      if (decoded['type'] == 'gameOver') {
        setState(() {
          _gameOver = true;
          _paused = false;
          _finalScore = (decoded['score'] as num?)?.toInt() ?? 0;
          _finalLength = (decoded['length'] as num?)?.toInt() ?? 2;
          _finalMoves = (decoded['moves'] as num?)?.toInt() ?? 0;
          _bestScore = (decoded['best'] as num?)?.toInt() ?? _finalScore;
          _newRecord = decoded['newRecord'] == true;
          _deathReason = decoded['message']?.toString() ?? '';
          final dynamic head = decoded['head'];
          final dynamic attempted = decoded['attempted'];
          final String debugBase = _fill(
            _tr(widget.settings, 'movesDebug'),
            <String, Object>{
              'moves': _finalMoves,
              'head': head,
            },
          );
          _deathDebug =
              attempted != null ? '$debugBase → $attempted' : debugBase;
        });
      }
    } catch (_) {}
  }

  Future<void> _js(String code) async {
    if (!_webReady) return;
    try {
      await _web.runJavaScript(code);
    } catch (_) {}
  }

  void _move(String key) {
    if (_paused || _gameOver) return;
    _js("window.VoxelAnaconda.move('$key');");
  }

  void _setPaused(bool value) {
    if (_gameOver || _paused == value) return;
    setState(() => _paused = value);
    _sendPauseState();
  }

  void _sendPauseState() {
    _js('window.VoxelAnaconda.setPaused(${_paused ? 'true' : 'false'});');
  }

  void _sendZoom() {
    _js('window.VoxelAnaconda.setZoom(${_zoom.toStringAsFixed(3)});');
  }

  void _sendSpeed() {
    _js(
      'window.VoxelAnaconda.setSpeed('
      '${widget.settings.gameSpeed.toStringAsFixed(2)});',
    );
  }

  void _sendSoundState() {
    _js(
      'window.VoxelAnaconda.setSoundEnabled('
      '${widget.settings.soundsEnabled ? 'true' : 'false'});',
    );
  }

  void _sendMusicState() {
    _js(
      'window.VoxelAnaconda.setMusicEnabled('
      '${widget.settings.musicEnabled ? 'true' : 'false'});',
    );
  }

  void _sendLanguage() {
    final String code = _effectiveLanguageCode(widget.settings);
    _js("window.VoxelAnaconda.setLanguage('$code');");
  }

  void _changeZoom(double delta) {
    if (!_paused) return;
    setState(() {
      _zoom = (_zoom + delta).clamp(0.60, 2.20);
    });
    _sendZoom();
  }

  void _restart() {
    setState(() {
      _gameOver = false;
      _paused = false;
      _finalScore = 0;
      _finalLength = 2;
      _finalMoves = 0;
      _bestScore = 0;
      _newRecord = false;
      _deathReason = '';
      _deathDebug = '';
      _zoom = 2.0;
    });
    _js('window.VoxelAnaconda.reset();');
    _sendZoom();
    _sendSpeed();
    _sendSoundState();
    _sendMusicState();
    _sendLanguage();
    _sendPauseState();
  }

  void _goToMenu() {
    Navigator.of(context).pop();
  }

  double _distanceBetweenTwoPointers() {
    if (_centerPointers.length < 2) return 0;
    final List<Offset> p = _centerPointers.values.take(2).toList();
    return (p[0] - p[1]).distance;
  }

  void _onCenterPointerDown(PointerDownEvent event) {
    if (_gameOver) return;

    _centerPointers[event.pointer] = event.localPosition;

    if (_centerPointers.length == 2) {
      _twoFingerStartedAt = DateTime.now();
      _twoFingerTapCandidate = true;
      _tapStartPositions = Map<int, Offset>.from(_centerPointers);
      _pinchStartDistance = _distanceBetweenTwoPointers();
      _pinchStartZoom = _zoom;
    } else if (_centerPointers.length > 2) {
      _twoFingerTapCandidate = false;
    }
  }

  void _onCenterPointerMove(PointerMoveEvent event) {
    if (!_centerPointers.containsKey(event.pointer) || _gameOver) return;
    _centerPointers[event.pointer] = event.localPosition;

    if (_centerPointers.length >= 2) {
      for (final MapEntry<int, Offset> entry in _centerPointers.entries) {
        final Offset? start = _tapStartPositions[entry.key];
        if (start != null && (entry.value - start).distance > 18.0) {
          _twoFingerTapCandidate = false;
        }
      }

      if (_paused && _pinchStartDistance != null) {
        final double now = _distanceBetweenTwoPointers();
        final double start = _pinchStartDistance!;

        if (start > 20 && now > 20) {
          final double scale = now / start;
          final double next = (_pinchStartZoom * scale).clamp(0.60, 2.20);

          if ((next - _zoom).abs() > 0.01) {
            setState(() => _zoom = next);
            _sendZoom();
          }
        }
      }
    }
  }

  void _onCenterPointerUp(PointerEvent event) {
    if (_gameOver) {
      _centerPointers.remove(event.pointer);
      return;
    }

    final bool hadTwo = _centerPointers.length == 2;

    if (hadTwo && _twoFingerTapCandidate && _twoFingerStartedAt != null) {
      final Duration elapsed = DateTime.now().difference(_twoFingerStartedAt!);

      if (elapsed.inMilliseconds <= 320) {
        _twoFingerTapCandidate = false;
        _setPaused(!_paused);
      }
    }

    _centerPointers.remove(event.pointer);

    if (_centerPointers.length < 2) {
      _pinchStartDistance = null;
      _twoFingerStartedAt = null;
      _tapStartPositions = <int, Offset>{};
    }
  }

  @override
  Widget build(BuildContext context) {
    final String languageCode = _effectiveLanguageCode(widget.settings);
    String t(String key) => _trCode(languageCode, key);

    return Scaffold(
      backgroundColor: const Color(0xFF050812),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double shortSide =
                math.min(constraints.maxWidth, constraints.maxHeight);

            final double dpadSize = (shortSide * 0.40).clamp(150.0, 210.0);
            final double verticalSize = (shortSide * 0.36).clamp(135.0, 190.0);

            return Stack(
              children: <Widget>[
                Positioned.fill(
                  child: WebViewWidget(controller: _web),
                ),

                // Banner AdMob de 320x50 arriba a la derecha.
                // En pruebas usa siempre el bloque oficial de Google.
                // Para publicación: --dart-define=USE_REAL_ADS=true
                Positioned(
                  top: 8,
                  right: 10,
                  child: _GameBanner(languageCode: languageCode),
                ),

                Positioned(
                  left: dpadSize + 34,
                  right: verticalSize * 0.62 + 44,
                  top: 0,
                  bottom: 0,
                  child: Listener(
                    behavior: HitTestBehavior.translucent,
                    onPointerDown: _onCenterPointerDown,
                    onPointerMove: _onCenterPointerMove,
                    onPointerUp: _onCenterPointerUp,
                    onPointerCancel: _onCenterPointerUp,
                    child: const SizedBox.expand(),
                  ),
                ),

                Positioned(
                  left: 18,
                  bottom: 16,
                  child: Opacity(
                    opacity: (_paused || _gameOver) ? 0.30 : 1.0,
                    child: IgnorePointer(
                      ignoring: _paused || _gameOver,
                      child: _DPad(
                        size: dpadSize,
                        haptics: widget.settings.hapticsEnabled,
                        onUp: () => _move('W'),
                        onDown: () => _move('S'),
                        onLeft: () => _move('A'),
                        onRight: () => _move('D'),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  right: 22,
                  bottom: 18,
                  child: Opacity(
                    opacity: (_paused || _gameOver) ? 0.30 : 1.0,
                    child: IgnorePointer(
                      ignoring: _paused || _gameOver,
                      child: _VerticalPad(
                        height: verticalSize,
                        haptics: widget.settings.hapticsEnabled,
                        onUp: () => _move('J'),
                        onDown: () => _move('K'),
                      ),
                    ),
                  ),
                ),

                if (!_paused && !_gameOver)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 8,
                    child: IgnorePointer(
                      child: Center(
                        child: _HintChip(
                          text: t('pauseHint'),
                        ),
                      ),
                    ),
                  ),

                if (_paused && !_gameOver) ...<Widget>[
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                  Positioned(
                    left: dpadSize + 48,
                    right: verticalSize * 0.62 + 52,
                    top: 14,
                    child: _PausePanel(
                      languageCode: languageCode,
                      zoom: _zoom,
                      onZoomOut: () => _changeZoom(-0.15),
                      onZoomIn: () => _changeZoom(0.15),
                      onRestart: _restart,
                      onMenu: _goToMenu,
                    ),
                  ),
                  Positioned(
                    left: dpadSize + 46,
                    right: verticalSize * 0.62 + 46,
                    bottom: 18,
                    child: Center(
                      child: FilledButton.icon(
                        onPressed: () => _setPaused(false),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(t('continue')),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 13,
                          ),
                          backgroundColor:
                              const Color(0xFFE18A2E).withValues(alpha: 0.94),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],

                if (_gameOver)
                  Positioned.fill(
                    child: _GameOverOverlay(
                      languageCode: languageCode,
                      score: _finalScore,
                      length: _finalLength,
                      best: _bestScore,
                      newRecord: _newRecord,
                      reason: _deathReason,
                      debugText: _deathDebug,
                      onRestart: _restart,
                      onMenu: _goToMenu,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GameBanner extends StatefulWidget {
  const _GameBanner({required this.languageCode});

  final String languageCode;

  @override
  State<_GameBanner> createState() => _GameBannerState();
}

class _GameBannerState extends State<_GameBanner> {
  // flutter run --release seguirá mostrando anuncios de PRUEBA.
  // Solo una compilación hecha expresamente con USE_REAL_ADS=true
  // utilizará el bloque real de Voxel Anaconda.
  static const bool _useRealAds =
      bool.fromEnvironment('USE_REAL_ADS', defaultValue: false);

  static const String _realBannerId = 'ca-app-pub-3322493998376707/1180634544';

  static const String _googleTestBannerId =
      'ca-app-pub-3940256099942544/6300978111';

  BannerAd? _banner;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  Future<void> _loadBanner() async {
    await MobileAds.instance.initialize();
    if (!mounted) return;

    final BannerAd ad = BannerAd(
      size: AdSize.banner,
      adUnitId: _useRealAds ? _realBannerId : _googleTestBannerId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (!mounted) return;
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _banner = null;
            _loaded = false;
          });
        },
      ),
    );

    _banner = ad;
    ad.load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 50,
      child: _loaded && _banner != null
          ? AdWidget(ad: _banner!)
          : Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.34),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.14),
                ),
              ),
              child: Text(
                _useRealAds
                    ? _trCode(widget.languageCode, 'ad')
                    : _trCode(widget.languageCode, 'testAd'),
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.4,
                  color: Color(0xFFB8C3DA),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay({
    required this.languageCode,
    required this.score,
    required this.length,
    required this.best,
    required this.newRecord,
    required this.reason,
    required this.debugText,
    required this.onRestart,
    required this.onMenu,
  });

  final String languageCode;
  final int score;
  final int length;
  final int best;
  final bool newRecord;
  final String reason;
  final String debugText;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    String t(String key) => _trCode(languageCode, key);

    return Container(
      color: Colors.black.withValues(alpha: 0.48),
      child: Center(
        child: Container(
          width: 420,
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
          decoration: BoxDecoration(
            color: const Color(0xFF090F1E).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                t('gameOver'),
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (newRecord) ...<Widget>[
                const SizedBox(height: 7),
                Text(
                  t('newRecord'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFFD66B),
                    letterSpacing: 1.1,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                _fill(
                  t('scoreLine'),
                  <String, Object>{
                    'score': score,
                    'length': length,
                    'best': best,
                  },
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFFC9D3EA),
                ),
              ),
              if (reason.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  reason,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFFC68A),
                  ),
                ),
              ],
              if (debugText.isNotEmpty) ...<Widget>[
                const SizedBox(height: 5),
                Text(
                  debugText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF93A4C7),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onRestart,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(t('restart')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onMenu,
                      icon: const Icon(Icons.home_rounded),
                      label: Text(t('menu')),
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

class _PausePanel extends StatelessWidget {
  const _PausePanel({
    required this.languageCode,
    required this.zoom,
    required this.onZoomOut,
    required this.onZoomIn,
    required this.onRestart,
    required this.onMenu,
  });

  final String languageCode;
  final double zoom;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    String t(String key) => _trCode(languageCode, key);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF090F1E).withValues(alpha: 0.84),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              t('tacticalPause'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              t('pauseHelp'),
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFFBAC6DE),
              ),
            ),
            const SizedBox(height: 7),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton.filledTonal(
                  onPressed: onZoomOut,
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: 9),
                Text(
                  '${zoom.toStringAsFixed(2)}×',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 9),
                IconButton.filledTonal(
                  onPressed: onZoomIn,
                  icon: const Icon(Icons.add),
                ),
                const SizedBox(width: 16),
                IconButton(
                  tooltip: t('restart'),
                  onPressed: onRestart,
                  icon: const Icon(Icons.refresh_rounded),
                ),
                IconButton(
                  tooltip: t('menu'),
                  onPressed: onMenu,
                  icon: const Icon(Icons.home_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DPad extends StatelessWidget {
  const _DPad({
    required this.size,
    required this.haptics,
    required this.onUp,
    required this.onDown,
    required this.onLeft,
    required this.onRight,
  });

  final double size;
  final bool haptics;
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) {
    final double b = size * 0.36;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 0,
            child: _ControlButton(
              size: b,
              haptics: haptics,
              icon: Icons.keyboard_arrow_up,
              onPressed: onUp,
            ),
          ),
          Positioned(
            bottom: 0,
            child: _ControlButton(
              size: b,
              haptics: haptics,
              icon: Icons.keyboard_arrow_down,
              onPressed: onDown,
            ),
          ),
          Positioned(
            left: 0,
            child: _ControlButton(
              size: b,
              haptics: haptics,
              icon: Icons.keyboard_arrow_left,
              onPressed: onLeft,
            ),
          ),
          Positioned(
            right: 0,
            child: _ControlButton(
              size: b,
              haptics: haptics,
              icon: Icons.keyboard_arrow_right,
              onPressed: onRight,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalPad extends StatelessWidget {
  const _VerticalPad({
    required this.height,
    required this.haptics,
    required this.onUp,
    required this.onDown,
  });

  final double height;
  final bool haptics;
  final VoidCallback onUp;
  final VoidCallback onDown;

  @override
  Widget build(BuildContext context) {
    final double button = height * 0.46;

    return SizedBox(
      width: button,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _ControlButton(
            size: button,
            haptics: haptics,
            icon: Icons.vertical_align_top_rounded,
            onPressed: onUp,
          ),
          _ControlButton(
            size: button,
            haptics: haptics,
            icon: Icons.vertical_align_bottom_rounded,
            onPressed: onDown,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatefulWidget {
  const _ControlButton({
    required this.size,
    required this.haptics,
    required this.icon,
    required this.onPressed,
  });

  final double size;
  final bool haptics;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _down = false;

  void _press() {
    if (widget.haptics) {
      HapticFeedback.selectionClick();
    }
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        setState(() => _down = true);
        _press();
      },
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: _down ? 0.28 : 0.14),
          border: Border.all(
            color: Colors.white.withValues(alpha: _down ? 0.58 : 0.28),
            width: 1.4,
          ),
        ),
        child: Icon(
          widget.icon,
          size: widget.size * 0.54,
          color: Colors.white.withValues(alpha: 0.88),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = emphasized
        ? FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            backgroundColor: const Color(0xFFE18A2E),
            foregroundColor: Colors.white,
          )
        : OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            foregroundColor: Colors.white,
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.22),
            ),
          );

    return emphasized
        ? FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
            style: style,
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
            style: style,
          );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C1325).withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: child,
    );
  }
}

class _HelpRow extends StatelessWidget {
  const _HelpRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFE18A2E).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE18A2E).withValues(alpha: 0.28),
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFFFFC16B),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.25,
                    color: Colors.white.withValues(alpha: 0.64),
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

class _HintChip extends StatelessWidget {
  const _HintChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFFC9D3EA),
        ),
      ),
    );
  }
}

class _MenuBackground extends StatelessWidget {
  const _MenuBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridBackgroundPainter(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF111A31),
              Color(0xFF03050B),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1;

    const double gap = 34;

    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }

    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
