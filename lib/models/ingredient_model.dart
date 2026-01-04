import 'package:flutter/material.dart';
import '../common/app_colors.dart';

class Ingredient {
  final String id;
  final String name;
  final String description;
  final String riskLevel; // "Düşük", "Orta", "Yüksek"
  final String functions; // "Nemlendirici", "Koruyucu" vb.
  final int comedogenicRating; // 0-5 arası (0: Tıkamaz, 5: Çok tıkar)
  final List<String> incompatibleSkinTypes; // ["Yağlı", "Hassas"] vb.
  final bool isDatabase; // Veritabanından mı geliyor?

  Ingredient({
    required this.id,
    required this.name,
    required this.description,
    required this.riskLevel,
    this.functions = "",
    this.comedogenicRating = 0,
    this.incompatibleSkinTypes = const [],
    this.isDatabase = true,
  });

  /// JSON -> Ingredient
  /// JSON tarafında önerilen anahtarlar:
  /// id, name, description, riskLevel, functions, comedogenicRating, incompatibleSkinTypes, isDatabase
  ///
  /// Geriye dönük uyum için:
  /// - description yoksa "desc" anahtarını da kabul eder.
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    final dynamic ratingRaw = json["comedogenicRating"];
    
    Row(
  children: List.generate(5, (i) {
    final filled = i < ing.comedogenicRating;
    return Icon(
      filled ? Icons.circle : Icons.circle_outlined,
      size: 10,
      color: filled ? Colors.orange : Colors.grey,
    );
  }),
);


    int parsedRating = 0;
    if (ratingRaw is int) {
      parsedRating = ratingRaw;
    } else if (ratingRaw is String) {
      parsedRating = int.tryParse(ratingRaw) ?? 0;
    }

    return Ingredient(
      id: (json["id"] ?? "").toString(),
      name: (json["name"] ?? "").toString(),
      description: (json["description"] ?? json["desc"] ?? "").toString(),
      riskLevel: (json["riskLevel"] ?? "Bilinmiyor").toString(),
      functions: (json["functions"] ?? "").toString(),
      comedogenicRating: parsedRating,
      incompatibleSkinTypes: (json["incompatibleSkinTypes"] is List)
          ? List<String>.from(json["incompatibleSkinTypes"].map((e) => e.toString()))
          : const [],
      isDatabase: (json["isDatabase"] is bool) ? json["isDatabase"] as bool : true,
    );
  }


  /// Risk Seviyesine Göre Renk Getiren "Getter"
  Color get riskColor => AppColors.getRiskColor(riskLevel);
}
