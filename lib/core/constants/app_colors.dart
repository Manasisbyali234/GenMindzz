import 'package:flutter/material.dart';

class AppColors {
  // GateKeeper AI Color Palette
  static const Color primary = Color(0xFF1A237E); // Dark Navy Blue
  static const Color accent = Color(0xFF00BCD4); // Teal/Cyan
  static const Color background = Color(0xFFF8F9FA); // Light Grey
  static const Color cardBackground = Colors.white;
  
  // Status Colors
  static const Color approved = Color(0xFF4CAF50); // Green
  static const Color pending = Color(0xFFFF9800); // Orange
  static const Color rejected = Color(0xFFF44336); // Red
  static const Color checkedIn = Color(0xFF4CAF50);
  static const Color overstay = Color(0xFFF44336);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00BCD4), Color(0xFF26C6DA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}