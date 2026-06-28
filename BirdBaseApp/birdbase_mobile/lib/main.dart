import 'package:flutter/material.dart';
import 'theme/brand_colors.dart';
import 'splash_screen.dart';

void main() {
  runApp(const BirdBaseApp());
}

class BirdBaseApp extends StatelessWidget {
  const BirdBaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bird Base',
      theme: ThemeData(
        scaffoldBackgroundColor: BrandColors.bgCream,
        colorScheme: ColorScheme.fromSeed(seedColor: BrandColors.forestGreen),
        fontFamily: 'Roboto', // iOS'taki .rounded hissiyatı için dilersen font ekleyebilirsin
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}


/*sadsda
 cd android
 ./gradlew --stop
 cd ..

 rm -rf android/.gradle

 flutter clean
 flutter pub get
* */