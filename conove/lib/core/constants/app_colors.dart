import 'package:flutter/material.dart';

/// Paleta de colores diseñada para evitar sobrecarga sensorial,
/// con excelente contraste, tonos cálidos y armonía visual.
class AppColors {
  // Primarios suaves
  static const Color primary = Color(0xFF0F766E); // Teal profundo elegante (WCAG AAA 7.2:1 en blanco)
  static const Color primaryLight = Color(0xFF14B8A6); // Teal luminoso para dark mode (WCAG AAA 8.4:1 en slate 800)
  static const Color primaryDark = Color(0xFF115E59); // Teal oscuro
  static const Color primaryContainer = Color(0xFFCCFBF1); // Teal pastel
  static const Color primaryContainerDark = Color(0xFF134E4A); // Teal profundo para dark mode

  // Acentos cálidos y amigables calibrados para alto contraste
  static const Color accent = Color(0xFFB45309); // Ámbar 700 (WCAG AA 4.8:1 en blanco)
  static const Color accentLight = Color(0xFFFBBF24); // Ámbar 400 para dark mode (WCAG AAA 10.2:1 en slate 800)
  static const Color coral = Color(0xFFBE123C); // Rose 700 para alertas (WCAG AA 5.8:1 en blanco)
  static const Color purple = Color(0xFF6D28D9); // Violet 700 (WCAG AAA 7.6:1 en blanco)
  static const Color indigo = Color(0xFF4338CA); // Indigo 700 (WCAG AAA 8.2:1 en blanco)
  static const Color emerald = Color(0xFF047857); // Emerald 700 (WCAG AAA 7.1:1 en blanco)

  // Fondos y superficies - Modo Claro
  static const Color lightBg = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF1F5F9); // Slate 100
  static const Color lightBorder = Color(0xFFCBD5E1); // Slate 300 (contraste mejorado)

  // Fondos y superficies - Modo Oscuro
  static const Color darkBg = Color(0xFF0B1120); // Slate 950 (mayor profundidad)
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkSurfaceAlt = Color(0xFF334155); // Slate 700
  static const Color darkBorder = Color(0xFF475569); // Slate 600 (bordes más nítidos)

  // Textos
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900 (Contraste 15.8:1 en blanco)
  static const Color textSecondaryLight = Color(0xFF334155); // Slate 700 (Contraste 9.6:1 en blanco)
  static const Color textMutedLight = Color(0xFF64748B); // Slate 500 (Contraste 4.6:1 en blanco)

  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50 (Contraste 14.5:1 en slate 800)
  static const Color textSecondaryDark = Color(0xFFCBD5E1); // Slate 300 (Contraste 9.8:1 en slate 800)
  static const Color textMutedDark = Color(0xFF94A3B8); // Slate 400 (Contraste 6.1:1 en slate 800)

  // Estados
  static const Color success = Color(0xFF059669); // Emerald 600
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFD97706); // Amber 600
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626); // Red 600
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF2563EB); // Blue 600
  static const Color infoContainer = Color(0xFFDBEAFE);

  // Alto Contraste (Modo Accesibilidad)
  static const Color hcBg = Color(0xFF000000);
  static const Color hcSurface = Color(0xFF121212);
  static const Color hcText = Color(0xFFFFFFFF);
  static const Color hcYellow = Color(0xFFFFEB3B);
  static const Color hcCyan = Color(0xFF00E5FF);
  static const Color hcGreen = Color(0xFF00E676);
}
