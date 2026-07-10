import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_1/models/recipe.dart';
import 'package:flutter_application_1/models/ingredient.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:uuid/uuid.dart';

class RecipeProvider extends ChangeNotifier {
  late Box<Recipe> _recipeBox;
  List<Recipe> _recipes = [];
  List<Recipe> _filteredRecipes = [];
  var uuid = const Uuid();

  String? _currentOwnerEmail;
  bool _isAdmin = false; // Tambahkan field untuk menyimpan status admin

  // Integrasi API
  final ApiService _apiService = ApiService();
  List<Recipe> _apiRecipes = [];
  bool _isLoadingApi = false;
  String _apiErrorMessage = '';

  RecipeProvider() {
    _recipeBox = Hive.box<Recipe>('recipes');
    if (_recipeBox.isEmpty) {
      _populateInitialData();
    } else {
      _loadRecipes();
    }
  }

  // Set email dan role user yang sedang login
  void setCurrentUser(String? email, bool isAdmin) {
    _currentOwnerEmail = email;
    _isAdmin = isAdmin;
    _loadRecipes();
  }

  // Getter untuk email user saat ini
  String? get currentUserEmail => _currentOwnerEmail;

  // Filter resep berdasarkan email pemilik ATAU akses penuh jika admin
  List<Recipe> get recipes {
    if (_currentOwnerEmail == null) return [];
    if (_isAdmin) return _recipes; // Admin lihat semua

    // User biasa melihat:
    // 1. Resep mereka sendiri
    // 2. Resep template
    // 3. Resep publik milik orang lain
    return _recipes.where((r) => 
        r.ownerEmail == _currentOwnerEmail || 
        r.ownerEmail == 'template@admin.com' ||
        r.ownerEmail == null || // Fallback agar data lama/template awal tetap muncul
        r.isPublic == true
    ).toList();
  }

  // Resep publik milik orang lain saja (untuk halaman Komunitas)
  List<Recipe> get communityRecipes {
    return _recipes.where((r) => 
        r.isPublic == true && 
        r.ownerEmail != _currentOwnerEmail &&
        r.ownerEmail != 'template@admin.com'
    ).toList();
  }

  List<Recipe> get filteredRecipes => _filteredRecipes;
  List<Recipe> get apiRecipes => _apiRecipes;
  bool get isLoadingApi => _isLoadingApi;
  String get apiErrorMessage => _apiErrorMessage;

  // ... (sisanya tetap sama)


  // Filter untuk favorit (tetap harus difilter berdasarkan email juga)
  List<Recipe> get favoriteRecipes {
    return recipes.where((recipe) => recipe.isFavorite).toList();
  }

  void _loadRecipes() {
    // Muat semua resep, nanti getter 'recipes' yang memfilter
    _recipes = _recipeBox.values.toList();
    _filteredRecipes = List.from(recipes); 
    notifyListeners();
  }

  void addRecipe(Recipe recipe) {
    // Pastikan ownerEmail diisi saat menambah resep
    recipe.ownerEmail = _currentOwnerEmail;
    _recipeBox.put(recipe.id, recipe);
    _loadRecipes();
  }

  void updateRecipe(Recipe recipe) {
    _recipeBox.put(recipe.id, recipe);
    _loadRecipes();
  }

  void deleteRecipe(Recipe recipe) {
    _recipeBox.delete(recipe.id);
    _loadRecipes();
  }

  void toggleFavorite(Recipe recipe) {
    recipe.isFavorite = !recipe.isFavorite;
    if (recipe.isInBox) {
      recipe.save();
    } else {
      recipe.ownerEmail = _currentOwnerEmail; // Pastikan owner diisi
      _recipeBox.put(recipe.id, recipe);
    }
    _loadRecipes();
  }

  void searchRecipesByName(String query) {
    if (query.isEmpty) {
      _filteredRecipes = List.from(recipes);
    } else {
      final lowercaseQuery = query.toLowerCase();
      _filteredRecipes = recipes
          .where((recipe) =>
              recipe.name.toLowerCase().contains(lowercaseQuery) ||
              recipe.ingredients.any((ingredient) =>
                  ingredient.name.toLowerCase().contains(lowercaseQuery)))
          .toList();
    }
    notifyListeners();
  }

  void searchRecipesByIngredients(List<String> ingredients) {
    if (ingredients.isEmpty) {
      _filteredRecipes = List.from(recipes);
    } else {
      _filteredRecipes = recipes.where((recipe) {
        return ingredients.every((searchIngredient) => recipe.ingredients.any(
            (recipeIngredient) => recipeIngredient.name.toLowerCase().contains(searchIngredient.toLowerCase())));
      }).toList();
    }
    notifyListeners();
  }

  /// Melakukan pencarian resep online menggunakan ApiService
  Future<void> searchOnlineRecipes(String query) async {
    if (query.trim().isEmpty) {
      _apiRecipes = [];
      _apiErrorMessage = '';
      notifyListeners();
      return;
    }

    _isLoadingApi = true;
    _apiErrorMessage = '';
    _apiRecipes = [];
    notifyListeners();

    try {
      _apiRecipes = await _apiService.searchRecipes(query);
      if (_apiRecipes.isEmpty) {
        _apiErrorMessage = 'Tidak ditemukan resep dengan nama "$query".';
      }
    } catch (e) {
      _apiErrorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingApi = false;
      notifyListeners();
    }
  }

  /// Mengecek apakah resep sudah tersimpan secara lokal di Hive
  bool isRecipeSaved(String id) {
    return _recipeBox.containsKey(id);
  }

  /// Membersihkan hasil pencarian API
  void clearApiSearch() {
    _apiRecipes = [];
    _apiErrorMessage = '';
    notifyListeners();
  }

  void _populateInitialData() {
    final List<Recipe> initialRecipes = [
      Recipe(
        id: uuid.v4(),
        name: 'Nasi Goreng',
        imageUrl: '',
        assetImagePath: 'Asset/Nasi Goreng.jpg',
        instructions:
            '1. Panaskan minyak, tumis bawang merah & putih hingga harum.\n2. Masukkan telur, orak-arik hingga setengah matang.\n3. Masukkan nasi putih, aduk rata dengan bumbu.\n4. Tambahkan kecap manis, garam, dan merica. Aduk hingga matang.\n5. Sajikan dengan kerupuk dan acar.',
        ingredients: [
          Ingredient(name: 'Nasi Putih', quantity: '1 piring'),
          Ingredient(name: 'Telur', quantity: '2 butir'),
          Ingredient(name: 'Bawang Merah', quantity: '3 siung'),
          Ingredient(name: 'Bawang Putih', quantity: '2 siung'),
          Ingredient(name: 'Kecap Manis', quantity: '2 sdm'),
          Ingredient(name: 'Garam & Merica', quantity: 'secukupnya'),
        ],
        isFavorite: true,
        notes: 'Tambahkan irisan sosis atau ayam untuk rasa yang lebih kaya.',
        isLocal: true,
      ),
      Recipe(
        id: uuid.v4(),
        name: 'Bakso',
        imageUrl: '',
        assetImagePath: 'Asset/Bakso.jpg',
        instructions:
            '1. Rebus air hingga mendidih, beri sedikit garam.\n2. Masukkan bakso, rebus hingga mengapung.\n3. Tambahkan bumbu kuah (bawang putih goreng, kecap asin, merica).\n4. Rebus mie kuning dan sawi di panci terpisah.\n5. Sajikan bakso bersama mie, sawi, taburan seledri dan bawang goreng.',
        ingredients: [
          Ingredient(name: 'Bakso Sapi', quantity: '10 butir'),
          Ingredient(name: 'Mie Kuning', quantity: '1 bungkus'),
          Ingredient(name: 'Sawi Hijau', quantity: '1 ikat'),
          Ingredient(name: 'Bawang Putih', quantity: '3 siung'),
          Ingredient(name: 'Kecap Asin', quantity: '1 sdm'),
          Ingredient(name: 'Seledri', quantity: 'secukupnya'),
        ],
        isFavorite: false,
        notes: 'Sajikan selagi hangat dengan sambal dan kecap.',
        isLocal: true,
      ),
      Recipe(
        id: uuid.v4(),
        name: 'Rendang',
        imageUrl: '',
        assetImagePath: 'Asset/Rendang.jpg',
        instructions:
            '1. Haluskan bumbu: bawang merah, putih, cabai merah, jahe, lengkuas.\n2. Masak santan di wajan besar dengan bumbu halus, serai, dan daun jeruk.\n3. Masukkan daging sapi, aduk rata.\n4. Masak dengan api sedang sambil terus diaduk hingga santan mengering.\n5. Kecilkan api, masak terus hingga daging berwarna cokelat gelap.',
        ingredients: [
          Ingredient(name: 'Daging Sapi', quantity: '500 g'),
          Ingredient(name: 'Santan Kental', quantity: '800 ml'),
          Ingredient(name: 'Bawang Merah', quantity: '10 siung'),
          Ingredient(name: 'Bawang Putih', quantity: '5 siung'),
          Ingredient(name: 'Cabai Merah', quantity: '15 buah'),
          Ingredient(name: 'Serai', quantity: '2 batang'),
          Ingredient(name: 'Daun Jeruk', quantity: '5 lembar'),
        ],
        isFavorite: true,
        notes: 'Butuh 3–4 jam memasak untuk hasil rendang yang sempurna.',
        isLocal: true,
      ),
      Recipe(
        id: uuid.v4(),
        name: 'Gado-Gado',
        imageUrl: '',
        assetImagePath: 'Asset/Gado-gado.jpg',
        instructions:
            '1. Rebus sayuran (kangkung, tauge, kacang panjang) hingga matang, tiriskan.\n2. Goreng tempe dan tahu hingga kecokelatan.\n3. Buat saus kacang: haluskan kacang tanah goreng, cabai, bawang putih, dan gula merah. Tambahkan air dan kecap manis.\n4. Tata sayuran dan gorengan di piring.\n5. Siram dengan saus kacang, sajikan dengan kerupuk dan lontong.',
        ingredients: [
          Ingredient(name: 'Kangkung', quantity: '1 ikat'),
          Ingredient(name: 'Tauge', quantity: '100 g'),
          Ingredient(name: 'Kacang Panjang', quantity: '100 g'),
          Ingredient(name: 'Tempe', quantity: '100 g'),
          Ingredient(name: 'Tahu', quantity: '2 buah'),
          Ingredient(name: 'Kacang Tanah', quantity: '150 g'),
          Ingredient(name: 'Lontong', quantity: '2 buah'),
        ],
        isFavorite: false,
        notes: 'Sajikan saus kacang hangat di atas sayuran segar.',
        isLocal: true,
      ),
      Recipe(
        id: uuid.v4(),
        name: 'Rawon',
        imageUrl: '',
        assetImagePath: 'Asset/Rawon.jpg',
        instructions:
            '1. Rebus daging sapi hingga empuk, sisihkan kaldunya.\n2. Haluskan bumbu: kluwek, bawang merah, bawang putih, kunyit, jahe.\n3. Tumis bumbu halus bersama serai dan daun salam hingga harum.\n4. Masukkan tumisan bumbu ke dalam kaldu daging.\n5. Masukkan daging, masak hingga bumbu meresap. Sajikan dengan tauge dan telur asin.',
        ingredients: [
          Ingredient(name: 'Daging Sapi', quantity: '500 g'),
          Ingredient(name: 'Kluwek', quantity: '3 buah'),
          Ingredient(name: 'Bawang Merah', quantity: '8 siung'),
          Ingredient(name: 'Bawang Putih', quantity: '4 siung'),
          Ingredient(name: 'Serai', quantity: '2 batang'),
          Ingredient(name: 'Tauge', quantity: '100 g'),
          Ingredient(name: 'Telur Asin', quantity: '2 butir'),
        ],
        isFavorite: false,
        notes: 'Ciri khas rawon adalah warna hitam dari kluwek yang khas.',
        isLocal: true,
      ),
      Recipe(
        id: uuid.v4(),
        name: 'Opor Ayam',
        imageUrl: '',
        assetImagePath: 'Asset/Opor ayam.jpg',
        instructions:
            '1. Haluskan bumbu: bawang merah, putih, kemiri, ketumbar.\n2. Tumis bumbu halus bersama serai, daun salam, dan daun jeruk hingga harum.\n3. Masukkan potongan ayam, aduk rata dengan bumbu.\n4. Tuangkan santan, masak dengan api sedang sambil sesekali diaduk.\n5. Masak hingga ayam empuk dan kuah sedikit mengental.',
        ingredients: [
          Ingredient(name: 'Ayam', quantity: '1 ekor (potong 8)'),
          Ingredient(name: 'Santan', quantity: '600 ml'),
          Ingredient(name: 'Bawang Merah', quantity: '8 siung'),
          Ingredient(name: 'Bawang Putih', quantity: '5 siung'),
          Ingredient(name: 'Kemiri', quantity: '4 butir'),
          Ingredient(name: 'Serai', quantity: '2 batang'),
          Ingredient(name: 'Daun Jeruk', quantity: '4 lembar'),
        ],
        isFavorite: false,
        notes: 'Cocok disajikan saat Lebaran bersama ketupat dan sambal goreng.',
        isLocal: true,
      ),
      Recipe(
        id: uuid.v4(),
        name: 'Kue Putu',
        imageUrl: '',
        assetImagePath: 'Asset/Kue Putu.jpg',
        instructions:
            '1. Campur tepung beras dengan air dan pewarna hijau (dari daun pandan), aduk hingga lembab.\n2. Isi cetakan bambu setengah dengan adonan tepung beras.\n3. Masukkan gula merah serut sebagai isian.\n4. Tutup kembali dengan adonan tepung beras.\n5. Kukus di atas uap air panas selama 10-15 menit.\n6. Sajikan dengan kelapa parut yang telah diberi sedikit garam.',
        ingredients: [
          Ingredient(name: 'Tepung Beras', quantity: '200 g'),
          Ingredient(name: 'Gula Merah', quantity: '100 g'),
          Ingredient(name: 'Kelapa Parut', quantity: '100 g'),
          Ingredient(name: 'Daun Pandan', quantity: '3 lembar'),
          Ingredient(name: 'Garam', quantity: '1/4 sdt'),
          Ingredient(name: 'Air', quantity: 'secukupnya'),
        ],
        isFavorite: false,
        notes: 'Adonan tepung beras harus lembab, bukan cair.',
        isLocal: true,
      ),
      Recipe(
        id: uuid.v4(),
        name: 'Nagasari',
        imageUrl: '',
        assetImagePath: 'Asset/Nagasari.jpg',
        instructions:
            '1. Campur tepung beras, tepung tapioka, gula, garam, dan santan. Aduk rata.\n2. Masak adonan di atas api kecil sambil terus diaduk hingga mengental.\n3. Siapkan daun pisang, oles dengan sedikit minyak.\n4. Ambil satu sendok adonan, letakkan di daun pisang.\n5. Tambahkan irisan pisang raja sebagai isian di tengahnya.\n6. Bungkus dan kukus selama 20-25 menit.',
        ingredients: [
          Ingredient(name: 'Tepung Beras', quantity: '150 g'),
          Ingredient(name: 'Tepung Tapioka', quantity: '50 g'),
          Ingredient(name: 'Santan', quantity: '400 ml'),
          Ingredient(name: 'Gula Pasir', quantity: '80 g'),
          Ingredient(name: 'Pisang Raja', quantity: '2 buah'),
          Ingredient(name: 'Daun Pisang', quantity: 'secukupnya'),
        ],
        isFavorite: false,
        notes: 'Gunakan pisang yang matang sempurna untuk rasa terbaik.',
        isLocal: true,
      ),
    ];

    for (var recipe in initialRecipes) {
      recipe.ownerEmail = 'template@admin.com';
      _recipeBox.put(recipe.id, recipe);
    }
    _loadRecipes();
  }
}
