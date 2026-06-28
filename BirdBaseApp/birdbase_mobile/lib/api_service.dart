import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService 
{
  // 🚀 CANLI SUNUCU BAĞLANTISI (Localhost iptal)
  static const String baseUrl = "https://pianabol-birdbase.hf.space/predict";

  static Future<http.Response> uploadImage(File imageFile) async {
    var request = http.MultipartRequest("POST", Uri.parse(baseUrl));

    // FastAPI'nin beklediği anahtar: 'image'
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ),
    );

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  // --------------------------
  // CHATBOT İLETİŞİMİ
  // --------------------------
  static Future<String> sendMessage(String message) async {
    // 🚀 CHATBOT İÇİN CANLI SUNUCU BAĞLANTISI
    final url = Uri.parse("https://pianabol-birdbase.hf.space/chat"); 
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": message}),
      );

      if (response.statusCode == 200) {
        // Türkçe karakterlerin bozulmaması için utf8.decode kullanıyoruz
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['reply'] ?? "Cevap alınamadı.";
      } else {
        return "Sunucu Hatası: ${response.statusCode}";
      }
    } catch (e) {
      return "Bağlantı Hatası: $e";
    }
  }
}