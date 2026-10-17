import 'package:flutter/material.dart';

/// Centralized color palette for the "Performance Studio" design system.
/// Combines OLED deep graphite surfaces with high-energy athletic accents.
class AppColors {
  AppColors._();

  // Athletic High-Energy Accents
  static const Color volt = Color(0xFFD4FF00); // Electric Volt / Neon Lime
  static const Color voltGlow = Color(0x33D4FF00);
  static const Color hyperOrange = Color(0xFFFF5722); // Kinetic Energy Orange
  static const Color cyanPulse = Color(0xFF00E5FF); // Speed / Interval Cyan
  static const Color amber = Color(0xFFFF9F0A); // Caution / Approaching Limit
  static const Color crimson = Color(0xFFFF3B30); // Due / Retirement Red

  // Dark Theme: Velvety OLED Graphite
  static const Color darkBg = Color(0xFF0C0D12);
  static const Color darkCard = Color(0xFF141720);
  static const Color darkCardElevated = Color(0xFF1C202C);
  static const Color darkCardHighlight = Color(0xFF242938);
  static const Color darkBorder = Color(0xFF282D3D);
  static const Color darkBorderSubtle = Color(0x33FFFFFF);
  static const Color darkTextPrimary = Color(0xFFF5F6FA);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextMuted = Color(0xFF6B7280);

  // Light Theme: Crisp Clean Studio Neutral
  static const Color lightBg = Color(0xFFF6F7FB);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFF1F3F9);
  static const Color lightCardHighlight = Color(0xFFE8ECF5);
  static const Color lightBorder = Color(0xFFE2E6F0);
  static const Color lightBorderSubtle = Color(0x1F000000);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF4B5563);
  static const Color lightTextMuted = Color(0xFF9CA3AF);

  /// Helper to get background color depending on brightness.
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkBg : lightBg;
  }

  /// Helper to get card color depending on brightness.
  static Color card(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkCard : lightCard;
  }

  /// Helper to get elevated card surface color depending on brightness.
  static Color cardElevated(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkCardElevated : lightCardElevated;
  }

  /// Helper to get border color depending on brightness.
  static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkBorder : lightBorder;
  }

  /// Helper to get secondary text color.
  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;
  }
}
