import 'package:flutter/material.dart';
import '../common/app_colors.dart';
import 'login_page.dart'; // Çıkış yapınca buraya döneceğiz

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  // Çıkış Yapma Fonksiyonu
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Çıkış Yap"),
        content: const Text("Hesabınızdan çıkmak istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // İptal
            child: const Text("İptal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              // Tüm ekranları kapat ve Login sayfasına git
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text("Çıkış Yap"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ayarlar"),
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Genel", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          
          // --- KARANLIK MOD (Görsel Simülasyon) ---
          SwitchListTile(
            title: const Text("Karanlık Mod"),
            subtitle: const Text("Göz yormayan tema"),
            secondary: Icon(Icons.dark_mode, color: _isDarkMode ? Colors.deepPurple : Colors.grey),
            value: _isDarkMode,
            activeColor: AppColors.blueDark,
            onChanged: (val) {
              setState(() {
                _isDarkMode = val;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tema ayarı kaydedildi (Simülasyon)")),
              );
            },
          ),
          
          // --- BİLDİRİMLER ---
          SwitchListTile(
            title: const Text("Bildirimler"),
            subtitle: const Text("Yeni analizlerden haberdar ol"),
            secondary: Icon(Icons.notifications, color: _notificationsEnabled ? Colors.deepPurple : Colors.grey),
            value: _notificationsEnabled,
            activeColor: AppColors.blueDark,
            onChanged: (val) {
              setState(() {
                _notificationsEnabled = val;
              });
            },
          ),

          const Divider(height: 40),
          const Text("Uygulama", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),

          // --- HAKKINDA ---
          ListTile(
            leading: const Icon(Icons.info, color: Colors.blue),
            title: const Text("Hakkında"),
            subtitle: const Text("Sürüm 1.0.0"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Kozmetik Analiz",
                applicationVersion: "1.0.0",
                applicationIcon: const Icon(Icons.science, size: 50, color: AppColors.blueDark),
                children: [
                  const Text("Bu uygulama cildiniz için zararlı maddeleri tespit etmenize yardımcı olur."),
                ],
              );
            },
          ),

          // --- GİZLİLİK POLİTİKASI ---
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.green),
            title: const Text("Gizlilik Politikası"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          const Divider(height: 40),

          // --- ÇIKIŞ YAP BUTONU ---
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Çıkış Yap", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}