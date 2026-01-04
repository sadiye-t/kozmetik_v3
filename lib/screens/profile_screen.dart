import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/app_colors.dart';
import '../services/auth_service.dart';
import 'favorites_screen.dart'; 
import 'history_screen.dart';
import 'settings_screen.dart'; // YENİ: Ayarlar ekranını ekledik
import 'login_page.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _selectedSkinType;

  final List<String> _skinTypes = [
    "Normal", "Kuru", "Yağlı", "Karma", 
    "Hassas", "Akneye Meyilli", "Hamile", "Alerjik"
  ];

  @override
  void initState() {
    super.initState();
    _loadSkinType();
  }

  Future<void> _loadSkinType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSkinType = prefs.getString('profile.skinType');
    });
  }

  Future<void> _saveSkinType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile.skinType', type);
    setState(() {
      _selectedSkinType = type;
    });
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Cilt tipi '$type' olarak güncellendi.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();

DropdownButton<ThemeMode>(
  value: tp.mode,
  items: const [
    DropdownMenuItem(value: ThemeMode.system, child: Text("Sistem")),
    DropdownMenuItem(value: ThemeMode.light, child: Text("Açık")),
    DropdownMenuItem(value: ThemeMode.dark, child: Text("Karanlık")),
  ],
  onChanged: (m) {
    if (m == null) return;
    context.read<ThemeProvider>().setMode(m);
  },
);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profilim"),
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // BAŞLIK
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.blueMedium,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 15),
                FutureBuilder(
                  future: Future.wait([
                    AuthService.currentName(),
                    AuthService.currentEmail(),
                  ]),
                  builder: (context, snapshot) {
                    final name = (snapshot.data is List && (snapshot.data as List).isNotEmpty)
                        ? (snapshot.data as List)[0] as String?
                        : null;
                    final email = (snapshot.data is List && (snapshot.data as List).length > 1)
                        ? (snapshot.data as List)[1] as String?
                        : null;

                    return Column(
                      children: [
                        Text(
                          name ?? "Kullanıcı",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        if (email != null)
                          Text(
                            email,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        const SizedBox(height: 6),
                        Text(
                          "Analizleri size özel yapmamız için cilt tipini seçin.",
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),

          // 1. FAVORİLER BUTONU
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.favorite, color: Colors.red),
              title: const Text("Favorilerim", style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()));
              },
            ),
          ),

          const SizedBox(height: 10),

          // 2. GEÇMİŞ BUTONU
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.history, color: Colors.deepPurple),
              title: const Text("Son Görüntülenenler", style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
              },
            ),
          ),

           const SizedBox(height: 10),

          // 3. AYARLAR BUTONU (YENİ)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text("Ayarlar", style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
          ),

          const SizedBox(height: 30),
          const Text("Cilt Tipi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // CİLT TİPLERİ LİSTESİ
          ..._skinTypes.map((type) {
            final isSelected = _selectedSkinType == type;
            return Card(
              color: isSelected ? AppColors.blueDark.withOpacity(0.1) : Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: isSelected ? const BorderSide(color: AppColors.blueDark, width: 2) : BorderSide.none,
              ),
              child: ListTile(
                title: Text(
                  type,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.blueDark : Colors.black,
                  ),
                ),
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? AppColors.blueDark : Colors.grey,
                ),
                onTap: () => _saveSkinType(type),
              ),
            );
          }).toList(),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                await AuthService.logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text("Çıkış Yap", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}