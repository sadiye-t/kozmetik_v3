import 'package:flutter/material.dart';

class AppColors {
  // Ana Tema Renkleri
  static const Color primaryPurple = Color(0xFF6A11CB);
  static const Color primaryBlue = Color(0xFF2575FC);
  
  // Arka Plan ve Kartlar
  static const Color background = Color(0xFFF4F6F9);
  static const Color cardColor = Colors.white;
  static const Color textDark = Color(0xFF2D3436);
  static const Color textLight = Color(0xFF636E72);

  // --- HATA VERMEMESİ İÇİN ESKİ RENKLERİ YÖNLENDİRDİK ---
  static const Color blueDark = primaryPurple;   // blueDark artık Mor
  static const Color blueMedium = primaryBlue;   // blueMedium artık Mavi
  // -----------------------------------------------------

  // Risk Renkleri
  static const Color riskHigh = Color(0xFFFF7675);
  static const Color riskMedium = Color(0xFFFAB1A0);
  static const Color riskLow = Color(0xFF55EFC4);
  static const Color riskUnknown = Color(0xFFA29BFE);
  static const Color greenDark = Color(0xFF2ECC71);

  static Color getRiskColor(String level) {
    switch (level) {
      case 'Düşük': return riskLow;
      case 'Orta': return riskMedium;
      case 'Yüksek': return riskHigh;
      default: return riskUnknown;
    }
  }
}