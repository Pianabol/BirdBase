import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';

class TFLiteService {
  static late FlutterVision vision;
  static bool isLoaded = false;

  // 1. Yapay Zekayı Başlat
  static Future<void> initialize() async {
    vision = FlutterVision();
    await loadModel();
  }

  // 2. Modeli RAM'e Yükle
  static Future<void> loadModel() async {
    try {
      await vision.loadYoloModel(
        labels: 'assets/models/labels.txt',
        modelPath: 'assets/models/bird_model.tflite',
        modelVersion: "yolov8", 
        quantization: false, // Float32 model kullandığımız için false yapıyoruz
        numThreads: 2, 
        useGpu: true, 
      );
      isLoaded = true;
      print("🚀 Offline Model Başarıyla Yüklendi!");
    } catch (e) {
      print("❌ Model yüklenirken hata: $e");
    }
  }

  // 3. ⚠️ YENİ: Fotoğrafı Analiz Eden Ana Fonksiyon
  static Future<List<Map<String, dynamic>>> analyzeImage(File imageFile) async {
    if (!isLoaded) {
      print("Model henüz yüklenmedi!");
      return [];
    }

    // Fotoğrafı telefonun anlayacağı byte (rakam) dizisine çeviriyoruz
    Uint8List imageBytes = await imageFile.readAsBytes();
    
    // Fotoğrafın genişlik ve yüksekliğini alıyoruz (Model bunu bilmek zorunda)
    var decodedImage = await decodeImageFromList(imageBytes);
    int height = decodedImage.height;
    int width = decodedImage.width;

    // Modeli ateşliyoruz!
    final result = await vision.yoloOnImage(
      bytesList: imageBytes,
      imageHeight: height,
      imageWidth: width,
      iouThreshold: 0.4,
      confThreshold: 0.4, // %40'ın altındaki emin olmadığı sonuçları gizle
    );

    return result; // Bulduğu sonuçları geri yolluyor
  }

  // 4. Modeli Kapat
  static Future<void> close() async {
    if (isLoaded) {
      await vision.closeYoloModel();
      isLoaded = false;
    }
  }
}