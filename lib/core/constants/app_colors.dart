import 'package:flutter/material.dart';

class AppColors {
  // Primary Theme Colors
  static const Color primary = Color(0xFF4f46e5);      // Indigo blue
  static const Color dark = Color(0xFF0f172a);         // Dark slate
  static const Color white = Colors.white;             // Pure white
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0f172a);  // Dark slate for primary text
  static const Color textLight = Colors.white;         // White text on dark backgrounds
  static const Color textSecondary = Color(0xFF7F8AA3); // Muted gray-blue
  static const Color textMuted = Color(0xFF7F8AA3);    // Same as secondary
  
  // Background Colors
  static const Color background = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color darkCard = Color(0xFF0f172a);
  
  // Status Colors
  static const Color pending = Color(0xFFFF9800);      // Orange
  static const Color approved = Color(0xFF4f46e5);     // Primary indigo
  static const Color approvedBg = Color(0xFFE9EDFF);   // Light indigo background
  static const Color checkedIn = Color(0xFF4CAF50);    // Green
  static const Color overstay = Color(0xFFF44336);     // Red
  
  // Accent Colors
  static const Color accent = Color(0xFF4f46e5);       // Same as primary
  static const Color highlight = Color(0xFFE9EDFF);    // Light indigo
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4f46e5), Color(0xFF4f46e5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Border Colors
  static const Color border = Color(0xFFEEF2F7);       // Light gray border
}