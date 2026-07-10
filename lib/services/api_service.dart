import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/models/recipe.dart';
import 'package:flutter_application_1/models/ingredient.dart';

/// Service untuk menghubungkan aplikasi kita dengan TheMealDB API.
/// Kita menggunakan API gratis ini untuk mencari resep secara online.
class ApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  /// Mencari resep berdasarkan nama dari TheMealDB API.
  /// Mengembalikan list objek [Recipe] yang sudah di-parse.
  Future<List<Recipe>> searchRecipes(String query) async {
    final url = Uri.parse('$_baseUrl/search.php?s=$query');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic>? meals = data['meals'];

        if (meals == null) {
          return []; // Jika tidak ada resep yang cocok, kembalikan list kosong
        }

        // Konversi setiap item meal dari API menjadi model Recipe kita
        return meals.map((meal) => _parseRecipe(meal)).toList();
      } else {
        throw Exception('Gagal memuat resep dari API (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi internet: $e');
    }
  }

  /// Mengambil detail lengkap resep berdasarkan ID makanan (idMeal).
  /// Ini berguna jika kita menggunakan endpoint filter yang hanya mengembalikan data terbatas.
  Future<Recipe?> getRecipeById(String id) async {
    final url = Uri.parse('$_baseUrl/lookup.php?i=$id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic>? meals = data['meals'];

        if (meals != null && meals.isNotEmpty) {
          return _parseRecipe(meals[0]);
        }
        return null;
      } else {
        throw Exception('Gagal memuat detail resep (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi saat memuat detail: $e');
    }
  }

  /// Fungsi helper untuk mem-parse JSON meal dari TheMealDB menjadi objek Recipe kita.
  /// Format TheMealDB menyimpan bahan dalam 20 field terpisah (strIngredient1 - strIngredient20).
  Recipe _parseRecipe(Map<String, dynamic> json) {
    final List<Ingredient> ingredients = [];

    // Lakukan perulangan 1 sampai 20 karena TheMealDB menyediakan maksimal 20 bahan terpisah
    for (int i = 1; i <= 20; i++) {
      final String? ingredientName = json['strIngredient$i'];
      final String? ingredientMeasure = json['strMeasure$i'];

      // Jika nama bahan tidak null, tidak kosong, dan bukan spasi kosong saja
      if (ingredientName != null && ingredientName.trim().isNotEmpty) {
        ingredients.add(
          Ingredient(
            name: ingredientName.trim(),
            quantity: (ingredientMeasure != null && ingredientMeasure.trim().isNotEmpty)
                ? ingredientMeasure.trim()
                : 'secukupnya', // Beri default jika jumlah/takaran kosong
          ),
        );
      }
    }

    return Recipe(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      imageUrl: json['strMealThumb'] ?? '',
      instructions: json['strInstructions'] ?? 'Tidak ada instruksi memasak.',
      ingredients: ingredients,
      isFavorite: false, // Default false, nanti bisa difavoritkan oleh user ke lokal
      notes: json['strCategory'] != null ? 'Kategori: ${json['strCategory']}' : null,
      isLocal: false, // Tambahan: karena ini dari API, bukan resep lokal
    );
  }
}
