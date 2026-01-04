import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/app_colors.dart';
import '../providers/analysis_provider.dart';
import 'detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AnalysisProvider>(context);
    final history = provider.recentIngredients;
    final items = context.watch<AnalysisProvider>().history;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Son Görüntülenenler"),
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: "Geçmişi Temizle",
            onPressed: () {
              provider.clearHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Geçmiş temizlendi.")),
              );
            },
          ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  const Text("Henüz bir inceleme yapmadınız.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final ingredient = history[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: Icon(Icons.history, color: Colors.grey[600]),
                    ),
                    title: Text(ingredient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(ingredient.riskLevel),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DetailScreen(ingredient: ingredient)),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}