import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400
  static const Color primaryDark = Color(0xFF3730A3); // Indigo 800

  // Secondary Accent Colors
  static const Color secondary = Color(0xFF0D9488); // Teal 600
  static const Color accent = Color(0xFFF97316); // Orange 500

  // Neutral / Background Colors
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Border & Divider
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color divider = Color(0xFFF1F5F9); // Slate 100

  // State & Status Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successBackground = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningBackground = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorBackground = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF3B82F6); // Blue 500
  static const Color infoBackground = Color(0xFFEFF6FF);

  // Status Badges
  static const Color statusVacant = Color(0xFF10B981);
  static const Color statusReserved = Color(0xFFF59E0B);
  static const Color statusOccupied = Color(0xFF94A3B8);
}
