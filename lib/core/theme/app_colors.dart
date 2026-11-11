import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand background & surface levels
  static const Color background = Color(0xFF101114);
  static const Color surface = Color(0xFF181A20);
  static const Color surfaceLight = Color(0xFF22252D);
  static const Color card = Color(0xFF1B1E26);
  static const Color cardElevated = Color(0xFF242833);

  // Borders & Dividers
  static const Color border = Color(0xFF2D323E);
  static const Color borderSubtle = Color(0xFF222631);

  // Brand Primary (AutoDesk Amber / Orange)
  static const Color primary = Color(0xFFF59E0B);
  static const Color primaryDark = Color(0xFFD97706);
  static const Color primaryLight = Color(0xFFFBBF24);

  // Typography Colors
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color secondary = Color(0xFF9CA3AF);

  // Semantic Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color successBg = Color(0xFF132E22);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFF3B181A);
  static const Color warning = Color(0xFFF97316);
  static const Color warningBg = Color(0xFF3E2211);
  static const Color info = Color(0xFF38BDF8);
  static const Color infoBg = Color(0xFF132736);
}
