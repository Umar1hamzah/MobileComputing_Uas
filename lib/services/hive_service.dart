import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';

class HiveService {
  // Nama box (ibarat nama tabel dalam database)
  static const String _boxName = 'recipesBox';

  // Fungsi untuk menyiapkan Hive, akan kita panggil di main.dart nanti saat aplikasi baru dibuka
  Future<void> init() async {
    await Hive.initFlutter();
    
    // Mendaftarkan "penerjemah" (adapter) agar Hive paham cara membaca/menulis objek Recipe & Ingredient
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RecipeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(IngredientAdapter());
    }
    
    // Membuka box agar siap digunakan
    await Hive.openBox<Recipe>(_boxName);
  }

  // Fungsi untuk mengambil semua resep yang tersimpan
  List<Recipe> getRecipes() {
    final box = Hive.box<Recipe>(_boxName);
    return box.values.toList();
  }

  // Fungsi untuk menyimpan resep baru
  Future<void> addRecipe(Recipe recipe) async {
    final box = Hive.box<Recipe>(_boxName);
    // Kita gunakan ID resep sebagai 'key' penyimpanannya
    await box.put(recipe.id, recipe);
  }

  // Fungsi untuk menghapus resep
  Future<void> deleteRecipe(String id) async {
    final box = Hive.box<Recipe>(_boxName);
    await box.delete(id);
  }

  // Fungsi untuk mengedit/update resep
  Future<void> updateRecipe(Recipe recipe) async {
    final box = Hive.box<Recipe>(_boxName);
    await box.put(recipe.id, recipe);
  }
}
