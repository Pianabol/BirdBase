import 'package:flutter/material.dart';
import 'theme/brand_colors.dart';
import 'storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Gelecekteki listemizi tutacak değişken
  late Future<List<Map<String, dynamic>>> _savedChatsFuture;

  @override
  void initState() {
    super.initState();
    _refreshList(); // Ekran açıldığında verileri çek
  }

  // Verileri yeniden çeken ve ekranı güncelleyen (tetikleyen) fonksiyon
  void _refreshList() {
    setState(() {
      _savedChatsFuture = StorageService.getSavedChats();
    });
  }

  // Çöp kutusuna basınca açılan uyarı penceresi
  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: BrandColors.bgCream,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Are you sure?",
            style: TextStyle(color: BrandColors.forestGreen, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to delete this saved answer?",
            style: TextStyle(color: BrandColors.textDark),
          ),
          actions: [
            // HAYIR BUTONU
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: BrandColors.forestGreen, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0, 
              ),
              onPressed: () => Navigator.pop(context), 
              child: const Text("No", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            
            // EVET BUTONU
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400], 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () async {
                Navigator.pop(context); // 1. Önce uyarı penceresini ANINDA kapat
                await StorageService.deleteChat(id); // 2. Arka planda veriyi sil
                _refreshList(); // 3. Listeyi güncelle
              },
              child: const Text("Yes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.bgCream,
      body: SafeArea(
        child: Column(
          children: [
            // STOPER BAŞLIK (Yenile butonu eklendi)
            Container(
              width: double.infinity,
              color: BrandColors.bgCream,
              padding: const EdgeInsets.only(top: 10, bottom: 20, left: 16, right: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    "My Profile",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: BrandColors.forestGreen),
                  ),
                  // YENİ: Sağ üst köşeye Zarif Yenileme Butonu eklendi
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: BrandColors.forestGreen, size: 28),
                      onPressed: _refreshList, // Basılınca listeyi yenile
                      tooltip: "Refresh List",
                    ),
                  ),
                ],
              ),
            ),

            // PROFİL BÖLÜMÜ (Avatar ve İsim)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: BrandColors.forestGreen, width: 4),
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: const Center(child: Icon(Icons.person_outline, size: 70, color: BrandColors.sageGreen)),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(15)),
                    child: Center(
                      child: Text(
                        "prototip123",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: BrandColors.textDark.withValues(alpha: 0.8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // KAYDEDİLEN BİLGİLER ALANI
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 25, top: 25, bottom: 15),
                      child: Text("Saved Answers", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: BrandColors.forestGreen)),
                    ),

                    Expanded(
                      // YENİ: Aşağı çekerek yenileme mekanizması (RefreshIndicator) eklendi
                      child: RefreshIndicator(
                        onRefresh: () async {
                          _refreshList();
                          // Hafif bir bekleme efekti vermek için
                          await Future.delayed(const Duration(milliseconds: 500));
                        },
                        color: BrandColors.forestGreen,
                        backgroundColor: BrandColors.bgCream,
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: _savedChatsFuture, 
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator(color: BrandColors.sageGreen));
                            }

                            final chats = snapshot.data ?? [];

                            if (chats.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.bookmark_border, size: 70, color: Colors.grey[400]),
                                    const SizedBox(height: 15),
                                    Text("You haven't saved any answers yet.", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                                    const SizedBox(height: 5),
                                    Text(
                                      "Use the 'Save' button under the\nassistant's answers.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // YENİ: Liste boş olmasa bile her zaman kaydırılabilir olması için
                            // physics: AlwaysScrollableScrollPhysics eklendi. (Pull-to-refresh için şart)
                            return ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: chats.length,
                              itemBuilder: (context, index) {
                                final chat = chats[index];
                                
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 0,
                                  color: BrandColors.bgCream,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(color: BrandColors.sageGreen.withValues(alpha: 0.3)),
                                  ),
                                  child: ExpansionTile(
                                    iconColor: BrandColors.forestGreen,
                                    collapsedIconColor: BrandColors.sageGreen,
                                    title: Text(
                                      chat["question"] ?? "Question",
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: BrandColors.forestGreen, fontSize: 15),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 0),
                                        child: Text(
                                          chat["answer"] ?? "",
                                          style: const TextStyle(color: BrandColors.textDark, fontSize: 14, height: 1.4),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          icon: const Icon(Icons.delete_outline, color: BrandColors.forestGreen),
                                          onPressed: () => _showDeleteDialog(chat["id"]), 
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
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
