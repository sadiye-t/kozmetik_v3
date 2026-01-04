import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/app_colors.dart';
import '../providers/analysis_provider.dart';
import 'detail_screen.dart'; 

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider'dan favorileri çekiyoruz
    final provider = Provider.of<AnalysisProvider>(context);
    final favorites = provider.favoriteIngredients;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorilerim"),
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  const Text("Henüz favori eklemediniz.", style: TextStyle(color: Colors.grey, fontSize: 18)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final ingredient = favorites[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: ingredient.riskColor, 
                      child: const Icon(Icons.star, color: Colors.white),
                    ),
                    title: Text(ingredient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(ingredient.functions),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        provider.toggleFavorite(ingredient);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Favorilerden çıkarıldı"), duration: Duration(seconds: 1)),
                        );
                      },
                    ),
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