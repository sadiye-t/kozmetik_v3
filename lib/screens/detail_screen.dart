import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Web araması için
import '../models/ingredient_model.dart';
import '../providers/analysis_provider.dart';
import '../common/app_colors.dart';

Future<void> openGoogleSearch(String query) async {
  // ✅ Daha sağlam arama metodu (EKLENDİ)
  final url = Uri.parse(
    "https://www.google.com/search?q=${Uri.encodeComponent(query)}",
  );

  try {
    // Önce kontrol et
    final can = await canLaunchUrl(url);
    if (can) {
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok) {
        // Alternatif: in-app açmayı dene
        await launchUrl(url, mode: LaunchMode.inAppBrowserView);
      }
    } else {
      // canLaunch false ise yine dene (bazı cihazlar burada false döndürüp yine açabiliyor)
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok) {
        await launchUrl(url, mode: LaunchMode.inAppBrowserView);
      }
    }
  } catch (_) {
    // Sessiz geç (istersen snackbar da koyabiliriz)
  }
}

class DetailScreen extends StatefulWidget {
  final Ingredient ingredient;
  const DetailScreen({super.key, required this.ingredient});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // ✅ history iki kere eklenmesin diye koruma (EKLENDİ)
  bool _historyAdded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ Senin satırların kaybolmadı ama 2 kez eklenmesin diye koruma eklendi
      if (_historyAdded) return;
      _historyAdded = true;

      context.read<AnalysisProvider>().addToHistory(widget.ingredient);
      Provider.of<AnalysisProvider>(context, listen: false).addToHistory(widget.ingredient);
    });
  }

  // Google'da Ara Fonksiyonu
  Future<void> _searchOnline() async {
    final query =
        Uri.encodeComponent("${widget.ingredient.name} skincare ingredient safety");
    final url = Uri.parse("https://www.google.com/search?q=$query");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ing = widget.ingredient;

    // ✅ Dark mode uyumu için (EKLENDİ)
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = theme.scaffoldBackgroundColor; // Karanlık modda otomatik koyu olur

    return Scaffold(
      // ❗ Eskiden Colors.white idi, bu dark mode’u bozuyordu.
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: ing.riskColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                ing.name,
                style: const TextStyle(
                  fontSize: 16,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [ing.riskColor, ing.riskColor.withOpacity(0.7)],
                  ),
                ),
                child: Center(
                  child: Icon(
                    ing.isDatabase ? Icons.science : Icons.auto_awesome,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!ing.isDatabase)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          // ✅ Dark mode’da daha iyi görünüm (EKLENDİ)
                          color: isDark ? Colors.purple.withOpacity(0.15) : Colors.purple[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? Colors.purple.withOpacity(0.35)
                                : Colors.purple[100]!,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.purple),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Bu madde veritabanında yok. Yapay zeka ismine göre tahmin yürüttü.",
                              ),
                            ),
                          ],
                        ),
                      ),

                    _buildInfoCard("Risk Seviyesi", ing.riskLevel, ing.riskColor,
                        Icons.security, context),
                    const SizedBox(height: 15),
                    _buildInfoCard("Fonksiyon", ing.functions, Colors.blueGrey,
                        Icons.settings, context),
                    const SizedBox(height: 15),

                    // ✅ KOMEDOJENLİK KARTI (EKLENDİ)
                    _buildInfoCard(
                      "Komedojenlik",
                      "${ing.comedogenicRating}/5",
                      Colors.orange,
                      Icons.bubble_chart,
                      context,
                    ),
                    const SizedBox(height: 10),

                    // ✅ KOMEDOJENLİK GÖSTERGELERİ (EKLENDİ)
                    Row(
                      children: List.generate(5, (i) {
                        final filled = i < ing.comedogenicRating;
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            filled ? Icons.circle : Icons.circle_outlined,
                            size: 12,
                            color: filled ? Colors.orange : Colors.grey,
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    const Text("Açıklama",
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      ing.description,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // WEBDE ARA BUTONU
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.public),
                        label: const Text("Google'da Detaylı Ara"),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryBlue),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () => openGoogleSearch(widget.ingredient.name),
                      ),
                    ),

                    // ✅ İstersen eski _searchOnline da dursun (EKLENDİ)
                    // TextButton(
                    //   onPressed: _searchOnline,
                    //   child: const Text("Alternatif arama (test)"),
                    // ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    Color color,
    IconData icon,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        // ✅ Dark mode uyumu (EKLENDİ)
        color: isDark ? color.withOpacity(0.18) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? color.withOpacity(0.45) : color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value.isEmpty ? "-" : value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
