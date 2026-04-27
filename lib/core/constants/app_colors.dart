import 'package:flutter/material.dart';

/// Enhanced color palette with modern professional design system
/// Based on Material Design 3 principles with Arabic retail POS context
class AppColors {
  // ===== Primary Brand Colors =====
  /// Green primary - professional, trustworthy, growth-oriented
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);

  /// Surface variant for cards and elevated elements
  static const Color primarySurface = Color(0xFFF1F8E9);

  /// Light version for backgrounds and subtle highlights
  static const Color primaryLightSurface = Color(0xFFE8F5E9);

  /// Pressed/dark state for interactions
  static const Color primaryPressed = Color(0xFF1B5E20);

  // ===== Secondary Colors =====
  /// Blue secondary - information, trust, stability
  static const Color secondary = Color(0xFF1565C0);
  static const Color secondaryLight = Color(0xFF42A5F5);
  static const Color secondarySurface = Color(0xFFE3F2FD);

  // ===== Semantic Colors (Enhanced) =====
  /// Error/Danger - critical actions, warnings
  static const Color danger = Color(0xFFD32F2F);
  static const Color dangerLight = Color(0xFFEF5350);
  static const Color dangerSurface = Color(0xFFFFEBEE);

  /// Warning - attention needed, pending states
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningSurface = Color(0xFFFFF3E0);

  /// Success - completed, positive actions
  static const Color success = Color(0xFF388E3C);
  static const Color successLight = Color(0xFF66BB6A);
  static const Color successSurface = Color(0xFFE8F5E9);

  /// Info - neutral information
  static const Color info = Color(0xFF1976D2);
  static const Color infoSurface = Color(0xFFE3F2FD);

  // ===== Neutral Colors (Enhanced Grayscale) =====
  /// Darkest - primary text, high emphasis
  static const Color textPrimary = Color(0xFF1A2332);

  /// Medium - secondary text, medium emphasis
  static const Color textSecondary = Color(0xFF4A5568);

  /// Light - placeholder, hint text, disabled
  static const Color textTertiary = Color(0xFF718096);

  /// Disabled state
  static const Color textDisabled = Color(0xFFCBD5E0);

  // ===== Background Colors =====
  /// Main app background
  static const Color background = Color(0xFFF7F8FA);

  /// Card/panel backgrounds
  static const Color surface = Color(0xFFFFFFFF);

  /// Surface variants for subtle contrast
  static const Color surfaceVariant = Color(0xFFF8F9FA);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // ===== Border Colors =====
  /// Primary border color
  static const Color border = Color(0xFFE2E8F0);

  /// Subtle borders for dividers
  static const Color borderLight = Color(0xFFEDF2F7);

  /// Focus borders
  static const Color borderFocus = Color(0xFF2E7D32);

  // ===== Sidebar & Layout =====
  /// Sidebar background - dark theme
  static const Color sidebar = Color(0xFF1A2332);
  static const Color sidebarHover = Color(0xFF2D3748);
  static const Color sidebarActive = Color(0xFF2E7D32);

  // ===== Overlay & Shadow =====
  /// Modal/dialog overlay
  static const Color overlay = Color(0x66000000);

  /// Card shadows
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowDark = Color(0x1F000000);

  // ===== Gradient (Optional for embellishments) =====
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [primaryLight, primary],
  );

  // ===== For backwards compatibility =====
  static const Color error = danger;
}
