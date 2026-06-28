import 'package:flutter/material.dart';
import 'content_view.dart';
import 'theme/brand_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return; // Uyarıyı çözen sihirli satır
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ContentView()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.bgCream,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flutter_dash, // Geçici kuş ikonu
              size: 100,
              color: BrandColors.sageGreen,
            ),
            const SizedBox(height: 16),
            const Text(
              "BirdBase",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: BrandColors.forestGreen,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Discover the birds around you.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}