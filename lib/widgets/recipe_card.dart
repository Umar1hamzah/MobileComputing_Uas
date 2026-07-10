import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/models/recipe.dart';
import 'package:flutter_application_1/providers/recipe_provider.dart';
import 'package:flutter_application_1/screens/recipe_detail_screen.dart';
import 'package:flutter_application_1/widgets/recipe_image.dart';

/// Card kustom untuk menampilkan ringkasan resep secara visual yang hangat (cozy).
/// Digunakan secara berulang (reusable) di berbagai layar list resep.
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final bool showFavoriteButton;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    // Tema warna hangat & cozy
    const primaryColor = Color(0xFFE76F51); // Orange bata hangat
    const darkTextColor = Color(0xFF2B2D42); // Navy gelap untuk teks utama
    const lightCreamColor = Color(0xFFFFFDF9); // Putih gading sangat lembut untuk background kartu

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: lightCreamColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF0EAD6), // Border tipis warna krem pucat
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () {
            // Navigasi ke halaman detail saat kartu diklik
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailScreen(recipe: recipe),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // 1. Gambar Resep dengan Sudut Membulat (Modern)
                Hero(
                  tag: 'recipe_image_${recipe.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: RecipeImage(
                      imageUrl: recipe.assetImagePath ?? recipe.localImagePath ?? recipe.imageUrl,
                      imageBase64: recipe.imageBase64,
                      width: 80,
                      height: 80,
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),

                // 2. Info Detail Resep (Nama, Instruksi Singkat, Jumlah Bahan)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: darkTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        recipe.instructions.replaceAll('\n', ' '),
                        style: TextStyle(
                          fontSize: 12.0,
                          color: darkTextColor.withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8.0),
                      // Badge Jumlah Bahan
                      Container(
                        height: 20,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shopping_basket_outlined,
                              size: 14,
                              color: primaryColor.withOpacity(0.8),
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              '${recipe.ingredients.length} Bahan',
                              style: TextStyle(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w600,
                                color: primaryColor.withOpacity(0.8),
                              ),
                            ),
                            if (recipe.notes != null && recipe.notes!.isNotEmpty) ...[
                              const SizedBox(width: 8.0),
                              Icon(
                                Icons.restaurant_menu_outlined,
                                size: 14,
                                color: Colors.amber[800],
                              ),
                              const SizedBox(width: 4.0),
                              Flexible(
                                child: Text(
                                  recipe.notes!.replaceFirst('Kategori: ', ''),
                                  style: TextStyle(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.amber[800],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Tombol Favorit (Opsional)
                if (showFavoriteButton)
                  Consumer<RecipeProvider>(
                    builder: (context, provider, child) {
                      final isSavedLocally = provider.isRecipeSaved(recipe.id);
                      final isFav = isSavedLocally && recipe.isFavorite;

                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? const Color(0xFFE76F51) : const Color(0xFFD5BDAF),
                        ),
                        onPressed: () {
                          if (isSavedLocally) {
                            // Jika resep lokal, tinggal toggle favorit
                            provider.toggleFavorite(recipe);
                          } else {
                            // Jika resep dari API (belum disave), save dulu baru favoritkan
                            recipe.isFavorite = true;
                            provider.addRecipe(recipe);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('"${recipe.name}" disimpan ke lokal & favorit!'),
                                backgroundColor: primaryColor,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
