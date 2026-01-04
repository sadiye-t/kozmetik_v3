import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ingredient_model.dart';
import '../models/beauty_product.dart';
import '../services/open_beauty_facts_service.dart';


class AnalysisProvider extends ChangeNotifier {
    // ✅ VERİTABANI (ASSET JSON)
  List<Ingredient> _database = [];
  List<Ingredient> get database => _database;


  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _lastError;
  String? get lastError => _lastError;

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  BeautyProduct? _lastProduct;
  BeautyProduct? get lastProduct => _lastProduct;

  String? _skinType; // Profil ekranından gelir
  String? get skinType => _skinType;

  // Arama sonuçları (HomeScreen listesi)

  List<Ingredient> _foundIngredients = [];
  List<Ingredient> get foundIngredients => _foundIngredients;

  /// Bulunan içeriklere göre 0-100 arası basit bir puan üretir.
  /// - Düşük risk: 0 puan kırar
  /// - Orta risk: 10 puan kırar
  /// - Yüksek risk: 25 puan kırar
  /// - Komedojenik puan (0-5): her 1 puan = 2 puan kırar
  /// - Seçili cilt tipi ile uyumsuzsa: +8 puan kırar
  int calculateScore() {
    int score = 100;

    for (final ing in _foundIngredients) {
      switch (ing.riskLevel) {
        case 'Yüksek':
          score -= 25;
          break;
        case 'Orta':
          score -= 10;
          break;
        case 'Düşük':
        default:
          break;
      }

      // komedojenik 0-5
      final com = (ing.comedogenicRating).clamp(0, 5);
      score -= (com * 2);

      if (isIncompatibleForProfile(ing)) {
        score -= 8;
      }
    }

    if (score < 0) score = 0;
    if (score > 100) score = 100;
    return score;
  }

  /// Puan rengine karar ver.
  /// 80+: yeşil, 50-79: turuncu, <50: kırmızı
  Color getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF2ECC71);
    if (score >= 50) return const Color(0xFFF39C12);
    return const Color(0xFFE74C3C);
  }

  // Favoriler / Geçmiş
  final Set<String> _favoriteIds = {};
  List<Ingredient> _favoriteIngredients = [];
  List<Ingredient> get favoriteIngredients => _favoriteIngredients;

  final List<Ingredient> _recentIngredients = [];
  List<Ingredient> get recentIngredients => List.unmodifiable(_recentIngredients);

  /// Yerel "veritabanı"
  /// (Senin zip’teki listeyi baz aldım; burayı büyütebilirsin.)
    final List<Ingredient> _database = [
    // --- RİSKLİLER ---
    Ingredient(id: "1", name: "Parabens", description: "Raf ömrünü uzatan koruyucu. Hassas ciltte iritasyon yapabilir.", riskLevel: "Yüksek", functions: "Koruyucu", comedogenicRating: 0, incompatibleSkinTypes: ["Hassas", "Hamile"]),
    Ingredient(id: "2", name: "Sodium Lauryl Sulfate (SLS)", description: "Köpürtücü. Kuruluk ve tahrişe sebep olabilir.", riskLevel: "Yüksek", functions: "Temizleyici", comedogenicRating: 5, incompatibleSkinTypes: ["Kuru", "Hassas"]),
    Ingredient(id: "3", name: "Fragrance (Parfum)", description: "Koku verici. Alerji ve hassasiyet tetikleyebilir.", riskLevel: "Orta", functions: "Koku", comedogenicRating: 0, incompatibleSkinTypes: ["Hassas", "Alerjik"]),
    Ingredient(id: "4", name: "Alcohol Denat", description: "Yağlı his bırakmamak için kullanılır. Kurutabilir.", riskLevel: "Orta", functions: "Çözücü", comedogenicRating: 0, incompatibleSkinTypes: ["Kuru", "Hassas"]),
    Ingredient(id: "5", name: "Formaldehyde", description: "Bazı ürünlerde koruyucu. İritan/alerjen olabilir.", riskLevel: "Yüksek", functions: "Koruyucu", comedogenicRating: 0, incompatibleSkinTypes: ["Tüm Tipler"]),
    Ingredient(id: "6", name: "Oxybenzone", description: "Güneş filtresi. Hassasiyeti tetikleyebilir.", riskLevel: "Orta", functions: "UV Filtresi", comedogenicRating: 0, incompatibleSkinTypes: ["Hassas", "Hamile"]),
    Ingredient(id: "7", name: "Triclosan", description: "Antibakteriyel madde. Bazı ülkelerde kısıtlıdır.", riskLevel: "Yüksek", functions: "Antibakteriyel", comedogenicRating: 0, incompatibleSkinTypes: ["Hamile"]),
    Ingredient(id: "8", name: "Isopropyl Myristate", description: "Yumuşatıcı. Komedojenik olabilir.", riskLevel: "Orta", functions: "Emollient", comedogenicRating: 5, incompatibleSkinTypes: ["Yağlı", "Akneye Meyilli"]),

    // --- GÜVENLİ & YARARLILAR ---
    Ingredient(id: "10", name: "Glycerin", description: "Nemi cilde hapseder.", riskLevel: "Düşük", functions: "Nemlendirici", comedogenicRating: 0, incompatibleSkinTypes: []),
    Ingredient(id: "11", name: "Hyaluronic Acid", description: "Su tutucu nemlendirici.", riskLevel: "Düşük", functions: "Nemlendirici", comedogenicRating: 0, incompatibleSkinTypes: []),
    Ingredient(id: "12", name: "Niacinamide", description: "Gözenek, leke ve bariyer için destek.", riskLevel: "Düşük", functions: "Leke Karşıtı", comedogenicRating: 0, incompatibleSkinTypes: []),
    Ingredient(id: "13", name: "Salicylic Acid (BHA)", description: "Siyah nokta ve akneye iyi gelir (kurularda dikkat).", riskLevel: "Orta", functions: "Eksfolyan", comedogenicRating: 0, incompatibleSkinTypes: ["Kuru", "Hassas"]),
    Ingredient(id: "14", name: "Retinol", description: "Yaşlanma karşıtı / akne. Tahriş yapabilir.", riskLevel: "Orta", functions: "Anti-Aging", comedogenicRating: 0, incompatibleSkinTypes: ["Hamile", "Çok Hassas"]),
    Ingredient(id: "15", name: "Ceramides", description: "Cilt bariyerini onarır.", riskLevel: "Düşük", functions: "Bariyer Onarıcı", comedogenicRating: 0, incompatibleSkinTypes: []),
    Ingredient(id: "16", name: "Panthenol (B5)", description: "Yatıştırır, nem verir.", riskLevel: "Düşük", functions: "Yatıştırıcı", comedogenicRating: 0, incompatibleSkinTypes: []),
    Ingredient(id: "17", name: "Zinc Oxide", description: "Mineral UV filtresi (hassaslar için iyi).", riskLevel: "Düşük", functions: "UV Filtresi", comedogenicRating: 1, incompatibleSkinTypes: []),
    Ingredient(id: "18", name: "Titanium Dioxide", description: "Mineral UV filtresi.", riskLevel: "Düşük", functions: "UV Filtresi", comedogenicRating: 0, incompatibleSkinTypes: []),
    Ingredient(id: "19", name: "Lactic Acid", description: "Nazik AHA. Nem ve parlaklık.", riskLevel: "Düşük", functions: "Eksfolyan", comedogenicRating: 0, incompatibleSkinTypes: []),
    Ingredient(id: "20", name: "Glycolic Acid", description: "AHA. Hassas ciltte dikkat.", riskLevel: "Orta", functions: "Eksfolyan", comedogenicRating: 0, incompatibleSkinTypes: ["Hassas"]),
    Ingredient(id: "21", name: "Vitamin C", description: "Aydınlatma/antioksidan.", riskLevel: "Orta", functions: "Antioksidan", comedogenicRating: 0, incompatibleSkinTypes: ["Çok Hassas"]),
    Ingredient(id: "22", name: "Aloe Vera", description: "Yatıştırıcı.", riskLevel: "Düşük", functions: "Yatıştırıcı", comedogenicRating: 0, incompatibleSkinTypes: []),
    Ingredient(id: "23", name: "Centella Asiatica", description: "Onarıcı/yatıştırıcı.", riskLevel: "Düşük", functions: "Onarıcı", comedogenicRating: 0, incompatibleSkinTypes: []),
    Ingredient(id: "24", name: "Squalane", description: "Hafif yağ, nem ve bariyer desteği.", riskLevel: "Düşük", functions: "Nemlendirici", comedogenicRating: 1, incompatibleSkinTypes: []),

    // --- YAĞLAR ---
    Ingredient(id: "25", name: "Coconut Oil", description: "Besleyici, fakat komedojenik olabilir.", riskLevel: "Orta", functions: "Emollient", comedogenicRating: 4, incompatibleSkinTypes: ["Yağlı", "Akneye Meyilli"]),
    Ingredient(id: "26", name: "Shea Butter", description: "Yoğun nem, bazı ciltlerde ağır gelebilir.", riskLevel: "Düşük", functions: "Emollient", comedogenicRating: 2, incompatibleSkinTypes: ["Çok Yağlı"]),
    Ingredient(id: "27", name: "Jojoba Oil", description: "Sebuma benzer, dengeler.", riskLevel: "Düşük", functions: "Emollient", comedogenicRating: 2, incompatibleSkinTypes: []),
    Ingredient(id: "28", name: "Argan Oil", description: "E vitamini, besleyici.", riskLevel: "Düşük", functions: "Emollient", comedogenicRating: 0, incompatibleSkinTypes: []),
  ];

  /// Uygulama açılışında profil + favori + geçmişi yükle
  Future<void> init() async {
        await loadIngredientsFromAssets();
    _foundIngredients = List.from(_database); // başlangıçta hepsini göster

    final prefs = await SharedPreferences.getInstance();
    _skinType = prefs.getString('profile.skinType');

    final favIds = prefs.getStringList('favorites.ids') ?? const [];
    _favoriteIds
      ..clear()
      ..addAll(favIds);

    _favoriteIngredients = _database.where((i) => _favoriteIds.contains(i.id)).toList();

    final historyJson = prefs.getStringList('history.ingredients') ?? const [];
    _recentIngredients
      ..clear()
      ..addAll(_decodeIngredients(historyJson));

    notifyListeners();
  }

  // -------------------------
  // Profil
  // -------------------------
  Future<void> setSkinType(String? value) async {
    _skinType = value;
    final prefs = await SharedPreferences.getInstance();
    if (value == null || value.isEmpty) {
      await prefs.remove('profile.skinType');
    } else {
      await prefs.setString('profile.skinType', value);
    }
    notifyListeners();
  }

  bool isIncompatibleForProfile(Ingredient ing) {
    final st = _skinType;
    if (st == null || st.isEmpty) return false;
    return ing.incompatibleSkinTypes.map((e) => e.toLowerCase()).contains(st.toLowerCase());
  }

  // -------------------------
  // Arama
  // -------------------------
  void searchIngredient(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      _foundIngredients = [];
      notifyListeners();
      return;
    }
    _foundIngredients = _database.where((ing) => ing.name.toLowerCase().contains(q)).toList();
    notifyListeners();
  }

  // -------------------------
  // Analiz (OCR / manuel)
  // -------------------------
  Future<void> analyzeProductText(String text) async {
    _lastError = null;
    _lastProduct = null;

    final cleaned = text.trim();
    if (cleaned.isEmpty) {
      _foundIngredients = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // küçük bir gecikme (UI geçişi için)
      await Future.delayed(const Duration(milliseconds: 200));

      final lower = cleaned.toLowerCase();

      // 1) Veritabanı eşleşmeleri
      final matched = _database.where((ing) => lower.contains(ing.name.toLowerCase())).toList();

      // 2) İstersen: Tanınmayanları da gösterebilirsin (şimdilik göstermiyoruz)
      _foundIngredients = matched;

      // geçmişe ekle (listeyi tek tek)
      for (final ing in matched) {
        _pushHistory(ing);
      }
    } catch (e) {
      _lastError = 'Analiz sırasında hata: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------
  // Barkod ile analiz
  // -------------------------
  Future<void> analyzeByBarcode(String barcode) async {
    _lastError = null;
    _lastProduct = null;

    final code = barcode.trim();
    if (code.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final product = await OpenBeautyFactsService.fetchByBarcode(code);
      if (product == null) {
        _lastError = 'Ürün bulunamadı (Open Beauty Facts). Barkodu doğru okuttuğuna emin ol.';
        _foundIngredients = [];
        return;
      }

      _lastProduct = product;

      final ingredients = product.ingredientsText;
      if (ingredients == null || ingredients.trim().isEmpty) {
        _lastError = 'Ürün bulundu ama içerik listesi yok. Etiket fotoğrafından OCR ile deneyebilirsin.';
        _foundIngredients = [];
        return;
      }

      await analyzeProductText(ingredients);
    } catch (e) {
      _lastError = 'Barkod analizi hata: $e';
      _foundIngredients = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// ===============================
// Favoriler
// ===============================
final List<Ingredient> _favorites = [];

List<Ingredient> get favorites => _favorites;

bool isFavorite(Ingredient ingredient) {
  return _favorites.any((i) => i.id == ingredient.id);
}

void toggleFavorite(Ingredient ingredient) {
  final exists = _favorites.any((i) => i.id == ingredient.id);

  if (exists) {
    _favorites.removeWhere((i) => i.id == ingredient.id);
  } else {
    _favorites.add(ingredient);
  }

  notifyListeners();
}

 
  // -------------------------
  // Geçmiş
  // -------------------------
  Future<void> clearHistory() async {
    _recentIngredients.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('history.ingredients');
    notifyListeners();
  }

  void _pushHistory(Ingredient ing) {
    // en üstte aynı varsa tekrar ekleme
    if (_recentIngredients.isNotEmpty && _recentIngredients.first.id == ing.id) return;

    // listede varsa kaldırıp en üste al
    _recentIngredients.removeWhere((x) => x.id == ing.id);
    _recentIngredients.insert(0, ing);

    // max 30
    if (_recentIngredients.length > 30) {
      _recentIngredients.removeRange(30, _recentIngredients.length);
    }

    _persistHistory();
  }

  Future<void> _persistHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _recentIngredients.map((e) => json.encode(_ingredientToMap(e))).toList();
    await prefs.setStringList('history.ingredients', encoded);
  }

  List<Ingredient> _decodeIngredients(List<String> encodedList) {
    final out = <Ingredient>[];
    for (final s in encodedList) {
      try {
        final m = (json.decode(s) as Map).cast<String, dynamic>();
        out.add(_ingredientFromMap(m));
      } catch (_) {}
    }
    return out;
  }

  Map<String, dynamic> _ingredientToMap(Ingredient i) => {
        'id': i.id,
        'name': i.name,
        'description': i.description,
        'riskLevel': i.riskLevel,
        'functions': i.functions,
        'comedogenicRating': i.comedogenicRating,
        'incompatibleSkinTypes': i.incompatibleSkinTypes,
        'isDatabase': i.isDatabase,
      };

  Ingredient _ingredientFromMap(Map<String, dynamic> m) => Ingredient(
        id: (m['id'] ?? '').toString(),
        name: (m['name'] ?? '').toString(),
        description: (m['description'] ?? '').toString(),
        riskLevel: (m['riskLevel'] ?? 'Bilinmiyor').toString(),
        functions: (m['functions'] ?? '').toString(),
        comedogenicRating: (m['comedogenicRating'] ?? 0) is int ? (m['comedogenicRating'] ?? 0) : int.tryParse('${m['comedogenicRating']}') ?? 0,
        incompatibleSkinTypes: (m['incompatibleSkinTypes'] is List)
            ? (m['incompatibleSkinTypes'] as List).map((e) => e.toString()).toList()
            : const [],
        isDatabase: (m['isDatabase'] ?? true) == true,
      );
      // ===============================
// Geçmiş (History)
// ===============================
final List<Ingredient> _history = [];

List<Ingredient> get history => _history;

void addToHistory(Ingredient ingredient) {
  _history.removeWhere((i) => i.id == ingredient.id);
  _history.insert(0, ingredient);

  if (_history.length > 20) {
    _history.removeLast();
  }

  notifyListeners();
}
  void searchIngredient(String query) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      _foundIngredients = List.from(_database);
    } else {
      _foundIngredients = _database.where((x) {
        return x.name.toLowerCase().contains(q) ||
            x.description.toLowerCase().contains(q) ||
            x.functions.toLowerCase().contains(q) ||
            x.riskLevel.toLowerCase().contains(q);
      }).toList();
    }

    notifyListeners();
  }

  Future<void> loadIngredientsFromAssets() async {
    final raw = await rootBundle.loadString('assets/ingredients.json');
    final decoded = jsonDecode(raw) as List;

    _database = decoded
        .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
        .toList();

    notifyListeners();
  }

}
