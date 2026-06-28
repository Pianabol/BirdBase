import 'package:flutter/material.dart';
import 'theme/brand_colors.dart';

class CommunityFeedScreen extends StatelessWidget {
  const CommunityFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.bgCream,
      body: SafeArea(
        child: Column(
          children: [
            // Tepe Başlığı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: const Text(
                "Community", // Başlığı "Home" yerine "Community" yaptık
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: BrandColors.forestGreen
                ),
              ),
            ),
            
            // Ana İçerik (Ortalanmış)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Şık bir topluluk ikonu
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: BrandColors.sageGreen.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.groups_rounded, 
                        size: 80, 
                        color: BrandColors.forestGreen
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Başlık
                    const Text(
                      "Community is Growing!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold, 
                        color: BrandColors.forestGreen
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Metin
                    const Text(
                      "We are currently developing a dedicated community platform where you can connect with fellow avian enthusiasts, exchange insights, and share your incredible bird photography.\n\nStay tuned for updates—an interactive BirdBase community is just around the corner!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16, 
                        color: BrandColors.textDark, 
                        height: 1.6
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Şık bir "Yakında" (Coming Soon) etiketi
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: BrandColors.sageGreen.withValues(alpha: 0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05), 
                            blurRadius: 10, 
                            offset: const Offset(0, 5)
                          )
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.rocket_launch_rounded, color: BrandColors.sageGreen, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Coming Soon", 
                            style: TextStyle(
                              color: BrandColors.forestGreen, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 16
                            )
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}