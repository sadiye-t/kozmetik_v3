import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/analysis_provider.dart';
import 'barcode_scanner_screen.dart';
import 'detail_screen.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  // 🔎 FİLTRELER (EKLENDİ)
  String _selectedRisk = "Hepsi";
  int _maxComedogenic = 5;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openBarcode() async {
    final code = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );

    if (!mounted) return;
    if (code == null || code.trim().isEmpty || code == '-1') return;

    // Provider'da barkod analizi metodu
    await context.read<AnalysisProvider>().analyzeByBarcode(code.trim());

    if (!mounted) return;

    final p = context.read<AnalysisProvider>();
    if (p.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(p.errorMessage!)),
      );
    }
  }

  Future<void> _openScan() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
  }

  Widget _bigAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AnalysisProvider>();

    // ✅ SONUÇLAR ARTIK FİLTRELİ (EKLENDİ)
    final results = p.foundIngredients.where((ing) {
      final riskOk = _selectedRisk == "Hepsi" || ing.riskLevel == _selectedRisk;
      final comedoOk = ing.comedogenicRating <= _maxComedogenic;
      return riskOk && comedoOk;
    }).toList();

    final score = p.calculateScore(); // sende yoksa kaldırırız
    final scoreColor = p.getScoreColor(score);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("İçerik Analiz"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        children: [
          // ÜST KARŞILAMA KARTI
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade500,
                  Colors.indigo.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.spa, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hoş geldin 👋",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Cilt tipi: ${p.skinType}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    "Skor: $score/100",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 2 BÜYÜK AKSİYON BUTONU
          Row(
            children: [
              _bigAction(
                icon: Icons.qr_code_scanner,
                title: "Barkod Tara",
                subtitle: "Ürünü bul ve analiz et",
                onTap: _openBarcode,
                color: Colors.deepPurple,
              ),
              const SizedBox(width: 12),
              _bigAction(
                icon: Icons.document_scanner,
                title: "Fotoğraftan Oku",
                subtitle: "İçerik listesini tara",
                onTap: _openScan,
                color: Colors.indigo,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // SKOR + DURUM KARTI
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.health_and_safety, color: scoreColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    score >= 70
                        ? "İyi görünüyor ✅\nRisk düşük."
                        : score >= 40
                            ? "Dikkat ⚠️\nOrta riskli içerikler olabilir."
                            : "Risk yüksek ❗\nAlternatif ürün önerilir.",
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ARAMA
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: "İçerik ara (ör: Paraben, SLS, Alcohol...)",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) => p.searchIngredient(v), // sende varsa
          ),

          const SizedBox(height: 12),

          // ✅ FİLTRE KARTI (EKLENDİ)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Filtreler",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),

                // RİSK
                DropdownButtonFormField<String>(
                  value: _selectedRisk,
                  decoration: const InputDecoration(
                    labelText: "Risk Seviyesi",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Hepsi", child: Text("Hepsi")),
                    DropdownMenuItem(value: "Düşük", child: Text("Düşük")),
                    DropdownMenuItem(value: "Orta", child: Text("Orta")),
                    DropdownMenuItem(value: "Yüksek", child: Text("Yüksek")),
                  ],
                  onChanged: (v) => setState(() => _selectedRisk = v ?? "Hepsi"),
                ),

                const SizedBox(height: 12),

                // KOMEDOJENLİK
                Text("Komedojenlik ≤ $_maxComedogenic"),
                Slider(
                  value: _maxComedogenic.toDouble(),
                  min: 0,
                  max: 5,
                  divisions: 5,
                  label: "$_maxComedogenic",
                  onChanged: (v) => setState(() => _maxComedogenic = v.toInt()),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // SONUÇLAR
          Row(
            children: [
              const Text(
                "Sonuçlar",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              Text(
                "${results.length} adet",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (p.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (results.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  "Henüz içerik yok.\nBarkod tara veya fotoğraftan oku.\n\nFiltreler sonucu daraltmış olabilir.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ...results.map((ing) {
              final fav = p.isFavorite(ing); // bizim favori yapısına göre
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: ing.riskColor,
                    child: const Icon(Icons.science, color: Colors.white),
                  ),
                  title: Text(
                    ing.name,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),

                  // ✅ KOMEDOJENLİK GÖSTERİMİ (EKLENDİ)
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ing.riskLevel,
                        style: TextStyle(
                          color: ing.riskColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (i) {
                          final filled = i < ing.comedogenicRating;
                          return Icon(
                            filled ? Icons.circle : Icons.circle_outlined,
                            size: 10,
                            color: filled ? Colors.orange : Colors.grey,
                          );
                        }),
                      ),
                    ],
                  ),

                  trailing: IconButton(
                    icon: Icon(
                      fav ? Icons.favorite : Icons.favorite_border,
                      color: fav ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => p.toggleFavorite(ing),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(ingredient: ing),
                      ),
                    );
                  },
                ),
              );
            }),
        ],
      ),
    );
  }
}
