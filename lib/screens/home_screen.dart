import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/models/recipe.dart';
import 'package:flutter_application_1/providers/recipe_provider.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_application_1/screens/add_edit_recipe_screen.dart';
import 'package:flutter_application_1/widgets/recipe_card.dart';

// HomeScreen adalah halaman utama beranda katalog resep.
// Menampilkan daftar semua resep (template + milik sendiri) dengan fitur pencarian.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isOnlineSearch = false; // true = cari ke API, false = cari lokal
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value, RecipeProvider provider) {
    setState(() => _searchQuery = value);
    if (!_isOnlineSearch) {
      // Langsung filter lokal saat mengetik
      provider.searchRecipesByName(value);
    }
  }

  void _performOnlineSearch(RecipeProvider provider) {
    final query = _searchController.text.trim();
    if (_isOnlineSearch && query.isNotEmpty) {
      provider.searchOnlineRecipes(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userName = auth.currentUser?.name ?? 'Kamu';

    return Scaffold(
      body: Consumer<RecipeProvider>(
        builder: (context, provider, _) {
          final recipesToShow =
              _isOnlineSearch ? provider.apiRecipes : provider.filteredRecipes;

          return CustomScrollView(
            slivers: [
              // ─── SliverAppBar dengan Salam & Search ───────────────────
              SliverAppBar(
                expandedHeight: 160,
                floating: true,
                snap: true,
                backgroundColor: const Color(0xFFFDFBF7),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDFBF7),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Salam pengguna
                        Text(
                          'Halo, $userName 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2B2D42),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Mau masak apa hari ini?',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8D99AE),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Search Bar & Toggle ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search bar
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: _isOnlineSearch
                              ? 'Cari resep online (tekan Enter)...'
                              : 'Cari nama resep atau bahan...',
                          prefixIcon: const Icon(Icons.search,
                              color: Color(0xFFE76F51)),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                    if (_isOnlineSearch) {
                                      provider.clearApiSearch();
                                    } else {
                                      provider.searchRecipesByName('');
                                    }
                                  },
                                )
                              : null,
                        ),
                        onChanged: (v) => _onSearchChanged(v, provider),
                        onSubmitted: (_) => _performOnlineSearch(provider),
                      ),
                      const SizedBox(height: 10),

                      // Toggle Lokal / Online
                      Row(
                        children: [
                          _buildToggleChip(
                            label: 'Resep Saya',
                            icon: Icons.book_outlined,
                            selected: !_isOnlineSearch,
                            onTap: () {
                              setState(() {
                                _isOnlineSearch = false;
                                _searchController.clear();
                                _searchQuery = '';
                              });
                              provider.searchRecipesByName('');
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildToggleChip(
                            label: 'Cari Online (API)',
                            icon: Icons.cloud_outlined,
                            selected: _isOnlineSearch,
                            onTap: () {
                              setState(() {
                                _isOnlineSearch = true;
                                _searchController.clear();
                                _searchQuery = '';
                              });
                              provider.clearApiSearch();
                            },
                          ),
                        ],
                      ),

                      // Judul section
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 4),
                        child: Text(
                          _isOnlineSearch ? 'Hasil Pencarian Online' : 'Katalog Resep',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2B2D42),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Konten List Resep ─────────────────────────────────
              _buildRecipeSliver(context, provider, recipesToShow),
            ],
          );
        },
      ),

      // FAB untuk tambah resep baru
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditRecipeScreen()),
          );
        },
        backgroundColor: const Color(0xFFE76F51),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget helper: chip toggle pencarian
  Widget _buildToggleChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE76F51).withOpacity(0.12)
              : const Color(0xFFF0EAD6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFFE76F51)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: selected
                    ? const Color(0xFFE76F51)
                    : const Color(0xFF8D99AE)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
                color: selected
                    ? const Color(0xFFE76F51)
                    : const Color(0xFF8D99AE),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper: konten list (loading / error / kosong / list resep)
  Widget _buildRecipeSliver(
    BuildContext context,
    RecipeProvider provider,
    List<Recipe> recipes,
  ) {
    // Sedang loading (pencarian online)
    if (_isOnlineSearch && provider.isLoadingApi) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFFE76F51)),
              SizedBox(height: 12),
              Text('Mencari resep online...',
                  style: TextStyle(color: Color(0xFF8D99AE))),
            ],
          ),
        ),
      );
    }

    // Pesan error / kosong dari API
    if (_isOnlineSearch && provider.apiErrorMessage.isNotEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off,
                  size: 56, color: Color(0xFFD5BDAF)),
              const SizedBox(height: 12),
              Text(
                provider.apiErrorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF8D99AE)),
              ),
            ],
          ),
        ),
      );
    }

    // Prompt: belum mengetik untuk pencarian online
    if (_isOnlineSearch && _searchQuery.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.travel_explore,
                  size: 56, color: Color(0xFFD5BDAF)),
              SizedBox(height: 12),
              Text(
                'Ketik nama masakan & tekan Enter\nuntuk mencari resep dari internet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8D99AE)),
              ),
            ],
          ),
        ),
      );
    }

    // Tidak ada hasil pencarian lokal
    if (recipes.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.no_food, size: 56, color: Color(0xFFD5BDAF)),
              const SizedBox(height: 12),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Tidak ada resep yang cocok\ndengan "$_searchQuery".'
                    : 'Belum ada resep.\nTambahkan resep pertamamu!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF8D99AE)),
              ),
            ],
          ),
        ),
      );
    }

    // List resep menggunakan RecipeCard (gambar otomatis ditampilkan)
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => RecipeCard(recipe: recipes[index]),
        childCount: recipes.length,
      ),
    );
  }
}
