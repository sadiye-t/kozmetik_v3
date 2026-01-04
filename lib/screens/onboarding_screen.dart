import 'package:flutter/material.dart';
import '../common/app_colors.dart';
import 'login_page.dart'; // Tanıtım bitince Giriş sayfasına gidecek

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // Tanıtım Sayfaları Verisi
  final List<Map<String, dynamic>> _pages = [
    {
      "title": "Barkod Tara",
      "desc": "Market raflarındaki ürünlerin barkodunu okutarak anında bilgi al.",
      "icon": Icons.qr_code_scanner,
      "color": Color(0xFF6A11CB),
    },
    {
      "title": "İçerik Analizi",
      "desc": "Kameranla 'İçindekiler' kısmının fotoğrafını çek, yapay zeka analiz etsin.",
      "icon": Icons.document_scanner, // veya Icons.camera_alt
      "color": Color(0xFF2575FC),
    },
    {
      "title": "Cildini Koru",
      "desc": "Cilt tipini seç, sana zararlı olabilecek maddelerden anında haberdar ol.",
      "icon": Icons.health_and_safety,
      "color": AppColors.greenDark,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- KAYDIRILABİLİR SAYFALAR ---
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // İkon Çemberi
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: _pages[index]["color"].withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _pages[index]["icon"],
                        size: 100,
                        color: _pages[index]["color"],
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Başlık
                    Text(
                      _pages[index]["title"],
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _pages[index]["color"],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Açıklama
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _pages[index]["desc"],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // --- ALT KISIM (NOKTALAR VE BUTON) ---
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Sayfa Noktaları (Indicators)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      height: 10,
                      width: _currentPage == index ? 20 : 10,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? _pages[index]["color"]
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // İleri / Başla Butonu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage]["color"],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          // Son sayfadaysa Giriş Sayfasına git
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        } else {
                          // Değilse sonraki sayfaya kaydır
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        _currentPage == _pages.length - 1 ? "BAŞLAYALIM" : "İLERİ",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // --- ATLA BUTONU (SAĞ ÜST) ---
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text("Atla", style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}