import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/beauty_product.dart';

class OpenBeautyFactsService {
  /// Open Beauty Facts: ürün verisi (barcode ile)
  /// Örn: https://world.openbeautyfacts.org/api/v2/product/3560070791460
  static Future<BeautyProduct?> fetchByBarcode(String barcode) async {
    final uri = Uri.parse(
      'https://world.openbeautyfacts.org/api/v2/product/$barcode'
      '?fields=product_name,brands,ingredients_text,ingredients_text_en,image_url',
    );

    final res = await http.get(
      uri,
      headers: const {
        'Accept': 'application/json',
        'User-Agent': 'kozmetik_analiz_flutter/1.0 (student project)',
      },
    );

    if (res.statusCode != 200) return null;

    final data = json.decode(res.body) as Map<String, dynamic>;
    final status = data['status'];
    if (status != 1) return null;

    final product = (data['product'] as Map?)?.cast<String, dynamic>() ?? {};
    final name = (product['product_name'] ?? '').toString().trim();
    final brands = (product['brands'] ?? '').toString().trim();
    final ingredientsText = ((product['ingredients_text'] ?? product['ingredients_text_en']) ?? '')
        .toString()
        .trim();
    final imageUrl = (product['image_url'] ?? '').toString().trim();

    return BeautyProduct(
      barcode: barcode,
      name: name.isEmpty ? null : name,
      brands: brands.isEmpty ? null : brands,
      ingredientsText: ingredientsText.isEmpty ? null : ingredientsText,
      imageUrl: imageUrl.isEmpty ? null : imageUrl,
    );
  }
}
