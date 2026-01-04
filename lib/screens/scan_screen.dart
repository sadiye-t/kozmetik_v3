import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:provider/provider.dart';
import '../common/app_colors.dart';
import '../providers/analysis_provider.dart';
import 'detail_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _image;
  bool _isScanning = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isScanning = true;
        });
        _scanTextFromImage();
      }
    } catch (e) {
      debugPrint("Hata: $e");
    }
  }

  Future<void> _scanTextFromImage() async {
    if (_image == null) return;
    try {
      final inputImage = InputImage.fromFile(_image!);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      if (!mounted) return;
      // Analiz başlat
      Provider.of<AnalysisProvider>(context, listen: false).analyzeProductText(recognizedText.text);

      setState(() {
        _isScanning = false;
      });
      textRecognizer.close();
    } catch (e) {
      setState(() => _isScanning = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Okuma hatası oluştu.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AnalysisProvider>(context);
    final results = provider.foundIngredients;
    
    // --- PUAN HESAPLAMA ---
    final int score = provider.calculateScore();
    final Color scoreColor = provider.getScoreColor(score);

    return Scaffold(
      appBar: AppBar(
        title: const Text("İçerik Analizi"),
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // FOTOĞRAF ALANI
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[200],
            child: _image != null
                ? Image.file(_image!, fit: BoxFit.cover)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 50, color: Colors.grey[400]),
                      const SizedBox(height: 10),
                      const Text("Ürün arkasını çekin", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
          ),

          // BUTONLAR
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera),
                    label: const Text("Kamera"),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.blueDark, foregroundColor: Colors.white),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo),
                    label: const Text("Galeri"),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.blueMedium, foregroundColor: Colors.white),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // SONUÇLAR
          Expanded(
            child: _isScanning
                ? const Center(child: CircularProgressIndicator())
                : results.isEmpty
                    ? Center(
                        child: Text(
                          _image == null ? "" : "Tanımlı içerik bulunamadı.",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : Column(
                        children: [
                          // --- PUAN KARTI (YENİ) ---
                          Container(
                            margin: const EdgeInsets.all(15),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                              ],
                              border: Border.all(color: scoreColor.withOpacity(0.3), width: 2),
                            ),
                            child: Row(
                              children: [
                                // Puan Dairesi
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: scoreColor.withOpacity(0.1),
                                  ),
                                  child: Text(
                                    "$score",
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: scoreColor),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Yazılar
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        score >= 80 ? "Temiz İçerik 🌿" : score >= 50 ? "Orta Riskli ⚠️" : "Zararlı İçerik ☠️",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: scoreColor),
                                      ),
                                      Text(
                                        "${results.length} madde tespit edildi.",
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // LİSTE
                          Expanded(
                            child: ListView.builder(
                              itemCount: results.length,
                              itemBuilder: (context, index) {
                                final ingredient = results[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: ingredient.riskColor,
                                    radius: 15,
                                    child: const Icon(Icons.check, size: 15, color: Colors.white),
                                  ),
                                  title: Text(ingredient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(ingredient.riskLevel, style: TextStyle(color: ingredient.riskColor)),
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(ingredient: ingredient)));
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}