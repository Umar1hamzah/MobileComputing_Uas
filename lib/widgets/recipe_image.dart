import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/image_utils.dart';

/// Widget kustom untuk menampilkan gambar resep secara pintar.
class RecipeImage extends StatelessWidget {
  final String imageUrl;
  final String? imageBase64; // Tambahkan field untuk base64
  final double? width;
  final double? height;
  final BoxFit fit;

  const RecipeImage({
    super.key,
    required this.imageUrl,
    this.imageBase64, // Tambahkan parameter
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Prioritas Web: Gunakan Base64 jika ada
    if (kIsWeb && imageBase64 != null && imageBase64!.isNotEmpty) {
      return Image.memory(
        ImageUtils.decodeFromBase64(imageBase64!),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildPlaceholder(errorIcon: Icons.broken_image_outlined),
      );
    }

    // Jika kosong, tampilkan placeholder
    if (imageUrl.trim().isEmpty) {
      return _buildPlaceholder();
    }

    // Cek apakah url berupa tautan internet atau blob URL (untuk Web)
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://') || imageUrl.startsWith('blob:')) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(errorIcon: Icons.broken_image_outlined);
        },
      );
    } else if (imageUrl.startsWith('Asset/')) {
      // Jika berupa asset lokal proyek
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(errorIcon: Icons.broken_image_outlined);
        },
      );
    } else {
      // Jika bukan tautan internet atau asset, maka ini adalah file lokal (dari kamera/galeri)
      if (kIsWeb) {
        // Di Web, jika tidak menggunakan Base64 atau Blob URL
        return _buildPlaceholder(errorIcon: Icons.web);
      }
      
      final file = File(imageUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder(errorIcon: Icons.broken_image_outlined);
          },
        );
      } else {
        // Jika file lokal tidak ditemukan (mungkin terhapus)
        return _buildPlaceholder(errorIcon: Icons.image_not_supported_outlined);
      }
    }
  }

  // Helper untuk membuat placeholder bernuansa Warm & Cozy
  Widget _buildPlaceholder({IconData errorIcon = Icons.restaurant_menu}) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFFF5EBE0), // Krem hangat (warm cream)
      ),
      child: Center(
        child: Icon(
          errorIcon,
          size: width != null ? (width! > 100 ? 48 : 28) : 32,
          color: const Color(0xFFD5BDAF), // Abu-abu kecokelatan hangat
        ),
      ),
    );
  }
}
