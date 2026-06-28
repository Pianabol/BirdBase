import 'package:flutter/material.dart';
import 'theme/brand_colors.dart';
import 'profile_screen.dart'; 
import 'analyze_screen.dart';
import 'chat_screen.dart';
import 'explore_screen.dart';
import 'community_feed_screen.dart'; // ⚠️ YENİ: Yorum satırını kaldırdık ve bağladık

class ContentView extends StatefulWidget {
  const ContentView({super.key});

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  bool isLoggedIn = true; 
  int _selectedIndex = 2; // Uygulama açıldığında varsayılan olarak "Analyze" sekmesi (Index 2) gelsin

  // Analizden Chat ekranına fırlatılacak mesajı tutan değişken
  String? _pendingChatMessage;

  // Analiz ekranındaki butona basılınca tetiklenecek "Köprü" fonksiyonu
  void _goToChatWithMessage(String message) {
    setState(() {
      _pendingChatMessage = message; // Mesajı cebe koy
      _selectedIndex = 3;            // Alt menüden 3. sekmeye (Assistant) kaydır
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return const Center(child: Text("Login Screen Placeholder"));
    }

    // Ekranlarımızın listesi
    final List<Widget> screens = [
      const CommunityFeedScreen(),                         // ⚠️ YENİ: "Coming Soon" ekranımız Index 0'a bağlandı
      const ExploreScreen(),                               
      AnalyzeScreen(onAskScientist: _goToChatWithMessage), 
      ChatScreen(initialMessage: _pendingChatMessage),     
      const ProfileScreen(),                               
    ];

    return Scaffold(
      backgroundColor: BrandColors.bgCream,
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ), 
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            // Kullanıcı normal menüden geçerse mesajı sıfırla ki sürekli aynı şeyi sormasın
            if (index != 3) _pendingChatMessage = null; 
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: BrandColors.forestGreen,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.document_scanner_outlined), label: "Analyze"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Assistant"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}