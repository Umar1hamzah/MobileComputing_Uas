import 'dart:convert';
import 'dart:typed_data';

class ImageUtils {
  /// Konversi Uint8List ke Base64 String untuk disimpan di Hive
  static String encodeToBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }

  /// Konversi Base64 String kembali ke Uint8List untuk ditampilkan di UI
  static Uint8List decodeFromBase64(String base64String) {
    return base64Decode(base64String);
  }
}
