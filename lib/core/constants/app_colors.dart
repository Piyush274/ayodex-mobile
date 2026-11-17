import 'package:material_ui/material_ui.dart';

/// Design tokens derived from active AYODEX website template `orange_oasis`
class AppColors {
  AppColors._();

  // Brand Base (Vibrant AYODEX Orange - hsl(17, 100%, 60%))
  static const Color base = Color(0xFFFF6033);
  static const Color baseDark = Color(0xFFFF410A);
  static const Color baseLight = Color(0xFFFF825E);

  // Brand Accent (Deep Dark Obsidian / Purple-Navy - hsl(260, 92%, 10%))
  static const Color accent = Color(0xFF110226);
  static const Color accentLight = Color(0xFF260D4D);

  // Typography & Content
  static const Color heading = Color(0xFF353A69); // hsl(232, 33%, 31%)
  static const Color body = Color(0xFF515E80); // hsl(223, 22%, 41%)
  static const Color textMuted = Color(0xFF868E96);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF7F9FC); // hsl(218, 49%, 97%)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF1F4F9);
  static const Color border = Color(0xFFEBEBEB); // hsl(0, 0%, 92%)

  // Functional Status
  static const Color success = Color(0xFF28C76F); // hsl(147, 67%, 47%)
  static const Color danger = Color(0xFFEA5455); // hsl(360, 78%, 62%)
  static const Color warning = Color(0xFFFF9F43); // hsl(29, 100%, 63%)
  static const Color info = Color(0xFF1DA1F2); // hsl(200, 90%, 53%)
}
