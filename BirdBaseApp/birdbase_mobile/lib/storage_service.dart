import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Cihaz hafızasında verileri tutacağımız gizli kasa adımız
  static const String _storageKey = 'saved_chats';

  // --------------------------
  // 1. MESAJI KAYDETME (WRITE)
  // --------------------------
  static Future<void> saveChat(String question, String answer) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Kasadaki mevcut verileri al
    final String? dataString = prefs.getString(_storageKey);
    List<dynamic> savedData = [];

    if (dataString != null) {
      savedData = jsonDecode(dataString);
    }

    // Yeni mesajı gelecekteki veritabanımıza uygun JSON formatında oluştur
    final newChat = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(), // Benzersiz ID
      "user_id": "prototip123", // İleride giriş yapan kullanıcının ID'si gelecek
      "question": question,
      "answer": answer,
      "date": DateTime.now().toIso8601String(), // Kayıt tarihi
    };

    // Yeni mesajı listeye ekle ve kasaya geri koy
    savedData.add(newChat);
    await prefs.setString(_storageKey, jsonEncode(savedData));
  }

  // --------------------------
  // 2. MESAJLARI OKUMA (READ)
  // --------------------------
  static Future<List<Map<String, dynamic>>> getSavedChats() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString(_storageKey);

    if (dataString == null) {
      return []; // Kasa boşsa boş liste dön
    }

    List<dynamic> decodedData = jsonDecode(dataString);

    // Sadece mevcut kullanıcıya (prototip123) ait olan mesajları filtrele
    List<Map<String, dynamic>> userChats = decodedData
        .map((e) => e as Map<String, dynamic>)
        .where((chat) => chat["user_id"] == "prototip123")
        .toList();

    // En son kaydedilen mesaj en üstte görünsün diye listeyi tersine çeviriyoruz
    return userChats.reversed.toList();
  }

  // --------------------------
  // 3. MESAJI SİLME (DELETE)
  // --------------------------
  static Future<void> deleteChat(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString(_storageKey);

    if (dataString != null) {
      List<dynamic> decodedData = jsonDecode(dataString);
      
      // Gönderdiğimiz ID'ye sahip olmayanları filtrele (Yani o ID'yi sil)
      decodedData.removeWhere((item) => item["id"] == id);
      
      // Güncel listeyi tekrar kasaya kaydet
      await prefs.setString(_storageKey, jsonEncode(decodedData));
    }
  }
}