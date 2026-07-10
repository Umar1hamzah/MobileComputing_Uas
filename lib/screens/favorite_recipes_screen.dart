import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/recipe_provider.dart';
import 'package:flutter_application_1/screens/recipe_detail_screen.dart';
import 'package:flutter_application_1/widgets/recipe_image.dart';

class FavoriteRecipesScreen extends StatelessWidget {
  const FavoriteRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, child) {
          final favoriteRecipes = recipeProvider.favoriteRecipes;
          if (favoriteRecipes.isEmpty) {
            return const Center(
              child: Text('Belum ada resep favorit.'),
            );
          }
          return ListView.builder(
            itemCount: favoriteRecipes.length,
            itemBuilder: (context, index) {
              final recipe = favoriteRecipes[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildRecipeImage(recipe, size: 56),
                  ),
                  title: Text(recipe.name),
                  subtitle: Text(recipe.instructions.split('\n')[0]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      recipeProvider.toggleFavorite(recipe);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper untuk menampilkan gambar resep secara cerdas
  Widget _buildRecipeImage(recipe, {double size = 56}) {
    return RecipeImage(
      imageUrl: recipe.assetImagePath ?? recipe.localImagePath ?? recipe.imageUrl,
      imageBase64: recipe.imageBase64,
      width: size,
      height: size,
    );
  }

  Widget _placeholder(double size) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFF4A261).withOpacity(0.3),
      child: const Icon(Icons.restaurant, color: Color(0xFFE76F51)),
    );
  }
}
