import 'dart:convert';
import 'package:flutter/services.dart';

class BirdInfoService {
  static Future<Map<String, dynamic>?> getInfo(String species) async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/BirdInfo.json');

      final Map<String, dynamic> data = json.decode(jsonString);

      return data[species.toLowerCase()];
    } catch (e) {
      return null;
    }
  }
}
