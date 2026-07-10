import 'package:hive/hive.dart';
import 'package:flutter_application_1/models/ingredient.dart';

part 'recipe.g.dart';

@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String imageUrl;

  @HiveField(3)
  String instructions;

  @HiveField(4)
  List<Ingredient> ingredients;

  @HiveField(5)
  bool isFavorite;

  @HiveField(6)
  String? notes; // Optional field for cooking notes

  @HiveField(7)
  String? localImagePath; // Path untuk foto dari kamera/galeri

  @HiveField(8)
  bool isLocal; // Penanda apakah ini resep buatan sendiri

  @HiveField(9)
  String? assetImagePath; // Path gambar dari folder Asset lokal aplikasi (bukan kamera)

  @HiveField(10)
  String? imageBase64; // Field baru untuk menyimpan data gambar Base64 (khusus Web)

  @HiveField(11)
  String? ownerEmail; // Field baru untuk menyimpan email pemilik resep (multi-user)

  @HiveField(12)
  bool isPublic; // Field baru untuk resep publik

  Recipe({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.instructions,
    required this.ingredients,
    this.isFavorite = false,
    this.notes,
    this.localImagePath,
    this.isLocal = false,
    this.assetImagePath,
    this.imageBase64,
    this.ownerEmail,
    this.isPublic = false,
  });

  // Factory untuk mempermudah mapping data dari JSON (TheMealDB API)
  factory Recipe.fromJson(Map<String, dynamic> json) {
    // TheMealDB memisahkan ingredients ke dalam 20 field (strIngredient1..20 dan strMeasure1..20)
    List<Ingredient> parsedIngredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredientName = json['strIngredient$i'];
      final ingredientMeasure = json['strMeasure$i'];
      if (ingredientName != null && ingredientName.toString().trim().isNotEmpty) {
        parsedIngredients.add(Ingredient(
          name: ingredientName,
          quantity: ingredientMeasure ?? '',
        ));
      }
    }

    return Recipe(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? 'Unknown Recipe',
      imageUrl: json['strMealThumb'] ?? '',
      instructions: json['strInstructions'] ?? 'No instructions provided.',
      ingredients: parsedIngredients,
      isLocal: false,
      isPublic: false,
    );
  }
}