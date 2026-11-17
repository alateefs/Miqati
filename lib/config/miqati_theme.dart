import 'package:flutter/material.dart';

class MiqatiPalette {
  final bool isDark;
  final Color scaffoldBg;
  final Color cardBg;
  final Color cardElevated;
  final Color heroStart;
  final Color heroEnd;
  final Color border;
  final Color gold;
  final Color emerald;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  Color get cardAlt => cardElevated;
  Color get danger => isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626);

  const MiqatiPalette({
    required this.isDark,
    required this.scaffoldBg,
    required this.cardBg,
    required this.cardElevated,
    required this.heroStart,
    required this.heroEnd,
    required this.border,
    required this.gold,
    required this.emerald,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
  });

  static MiqatiPalette of(bool isDarkMode) {
    if (isDarkMode) {
      return const MiqatiPalette(
        isDark: true,
        scaffoldBg: Color(0xFF061411),
        cardBg: Color(0xFF0A211C),
        cardElevated: Color(0xFF10312A),
        heroStart: Color(0xFF0E332A),
        heroEnd: Color(0xFF071915),
        border: Color(0xFF154E40),
        gold: Color(0xFFFBBF24),
        emerald: Color(0xFF10B981),
        textPrimary: Color(0xFFF8FAFC),
        textSecondary: Color(0xFFCBD5E1),
        textMuted: Color(0xFF94A3B8),
      );
    } else {
      return const MiqatiPalette(
        isDark: false,
        scaffoldBg: Color(0xFFF0FDF4),
        cardBg: Color(0xFFFFFFFF),
        cardElevated: Color(0xFFECFDF5),
        heroStart: Color(0xFF065F46),
        heroEnd: Color(0xFF047857),
        border: Color(0xFFA7F3D0),
        gold: Color(0xFFB45309),
        emerald: Color(0xFF059669),
        textPrimary: Color(0xFF0F172A),
        textSecondary: Color(0xFF334155),
        textMuted: Color(0xFF64748B),
      );
    }
  }
}
