import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/brand_colors.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<dynamic> exploreData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExploreData();
  }

  Future<void> _loadExploreData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/data/ExploreInfo.json');
      setState(() {
        exploreData = jsonDecode(jsonString);
        isLoading = false;
      });
    } catch (e) {
      print("Error loading Explore Data: $e");
      setState(() { isLoading = false; });
    }
  }

  // Alttan kayarak açılan Detay Paneli (BottomSheet)
  void _openDetailSheet(Map<String, dynamic> biome) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85, 
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: BrandColors.bgCream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ListView(
                controller: controller, 
                padding: EdgeInsets.zero,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                      width: 50, height: 5,
                      decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    // ⚠️ DEĞİŞİKLİK: Image.network yerine Image.asset kullanıyoruz
                    child: Image.asset(
                      biome['img'],
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(biome['title'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: BrandColors.forestGreen)),
                        const SizedBox(height: 20),
                        
                        const Text("About the Biome", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: BrandColors.forestGreen)),
                        const SizedBox(height: 8),
                        Text(biome['desc'], style: const TextStyle(fontSize: 15, color: BrandColors.textDark, height: 1.5)),
                        
                        const SizedBox(height: 20),
                        const Divider(color: BrandColors.sageGreen),
                        const SizedBox(height: 20),
                        
                        const Text("Featured Birds", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: BrandColors.forestGreen)),
                        const SizedBox(height: 8),
                        Text(biome['birds'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: BrandColors.sageGreen)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardSize = screenWidth - 32; 

    return Scaffold(
      backgroundColor: BrandColors.bgCream,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: const Column(
                children: [
                  Text("Explore", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: BrandColors.forestGreen)),
                  SizedBox(height: 5),
                  Text("Geographic Biomes", style: TextStyle(fontSize: 16, color: BrandColors.sageGreen)),
                ],
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: BrandColors.forestGreen))
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(), 
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: exploreData.length,
                      itemBuilder: (context, index) {
                        final biome = exploreData[index];
                        
                        return GestureDetector(
                          onTap: () => _openDetailSheet(biome),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 24), 
                            width: cardSize,
                            height: cardSize, 
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15), 
                                  blurRadius: 10, 
                                  offset: const Offset(0, 5)
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // ⚠️ DEĞİŞİKLİK: Image.network yerine Image.asset kullanıyoruz
                                  Image.asset(biome['img'], fit: BoxFit.cover),
                                  
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent, 
                                          Colors.black.withValues(alpha: 0.3),
                                          Colors.black.withValues(alpha: 0.8)
                                        ],
                                        stops: const [0.5, 0.8, 1.0], 
                                      ),
                                    ),
                                  ),
                                  
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Text(
                                        biome['title'],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white, 
                                          fontSize: 24, 
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}