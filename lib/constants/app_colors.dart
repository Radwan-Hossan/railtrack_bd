import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Inspired by Bangladesh Railway & Modern Emerald Dark Theme
  static const Color emeraldPrimary = Color(0xFF006C4C);
  static const Color emeraldLight = Color(0xFF008960);
  static const Color emeraldDark = Color(0xFF004D36);
  static const Color emeraldAccent = Color(0xFF00D18F);

  static const Color goldAccent = Color(0xFFFFB300);
  static const Color goldLight = Color(0xFFFFC107);

  // Status Indicator Colors (Live, Demo, Stale, Offline)
  static const Color statusLive = Color(0xFF00C853);      // Green pulse
  static const Color statusDemo = Color(0xFFFF9100);      // Amber/Orange for GPS simulation
  static const Color statusStale = Color(0xFFFFAB00);     // Warning yellow/amber
  static const Color statusOffline = Color(0xFF9E9E9E);   // Slate grey

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF0D1418);
  static const Color darkSurface = Color(0xFF152026);
  static const Color darkCard = Color(0xFF1C2C34);
  static const Color darkBorder = Color(0xFF283B46);
  static const Color darkTextPrimary = Color(0xFFE2EBF0);
  static const Color darkTextSecondary = Color(0xFF96A7B2);

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF4F7F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE0E6EA);
  static const Color lightTextPrimary = Color(0xFF131D24);
  static const Color lightTextSecondary = Color(0xFF5A6E7B);

  // Railway Map Colors
  static const Color trackBed = Color(0xFF334651);
  static const Color trackActive = Color(0xFF00D18F);
  static const Color trackUpcoming = Color(0xFF4A6572);
  static const Color stationMarker = Color(0xFFFFB300);
  static const Color trainMarker = Color(0xFF00E676);
}
