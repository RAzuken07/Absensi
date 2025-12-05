import 'package:flutter/material.dart';

/// App-wide color constants for ABSENSI PNL
class AppColors {
  // Prevent instantiation
  AppColors._();

  // Gradient Background Colors
  static const Color gradientStart = Color(0xFF004D7A); // Dark Blue
  static const Color gradientEnd = Color(0xFF008793);   // Cyan

  // Primary Colors
  static const Color primary = Color(0xFF004D7A);
  static const Color primaryLight = Color(0xFF008793);
  static const Color primaryDark = Color(0xFF003952);

  // Status Colors
  static const Color statusHadir = Color(0xFF4CAF50);      // Green
  static const Color statusAlpha = Color(0xFFE53935);      // Red
  static const Color statusIzin = Color(0xFFFDD835);       // Yellow
  static const Color statusSakit = Color(0xFF2196F3);      // Blue
  static const Color statusTerlambat = Color(0xFFEC407A);  // Pink
  static const Color statusLibur = Color(0xFF9E9E9E);      // Gray
  static const Color statusBelumAbsen = Color(0xFFFFFFFF); // White

  // Background Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Border & Divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);

  /// Get status color by status name
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return statusHadir;
      case 'alpha':
        return statusAlpha;
      case 'izin':
        return statusIzin;
      case 'sakit':
        return statusSakit;
      case 'terlambat':
        return statusTerlambat;
      case 'libur':
        return statusLibur;
      default:
        return statusBelumAbsen;
    }
  }

  /// Get status label in Indonesian
  static String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return 'Hadir';
      case 'alpha':
        return 'Alpha';
      case 'izin':
        return 'Izin';
      case 'sakit':
        return 'Sakit';
      case 'terlambat':
        return 'Terlambat';
      case 'libur':
        return 'Libur';
      default:
        return 'Belum Absen';
    }
  }
}
