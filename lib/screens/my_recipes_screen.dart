import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/recipe_provider.dart';
import 'package:flutter_application_1/screens/recipe_detail_screen.dart';
import 'package:flutter_application_1/screens/add_edit_recipe_screen.dart';
import 'package:flutter_application_1/widgets/recipe_image.dart';

class MyRecipesScreen extends StatelessWidget {
  const MyRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, child) {
          // Hanya resep milik sendiri
          final myRecipes = recipeProvider.recipes.where((r) => 
            r.ownerEmail == recipeProvider.currentUserEmail // Perlu menambahkan getter currentUserEmail di provider
          ).toList();

          if (myRecipes.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada resep buatanmu.\nYuk, tambah resep barumu!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8D99AE)),
              ),
            );
          }

          return ListView.builder(
            itemCount: myRecipes.length,
            itemBuilder: (context, index) {
              final recipe = myRecipes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildRecipeImage(recipe, size: 56),
                  ),
                  title: Text(recipe.name),
                  subtitle: Text(
                    recipe.instructions.split('\n')[0],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit button
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFFF4A261)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditRecipeScreen(recipe: recipe),
                            ),
                          );
                        },
                      ),
                      // Delete button
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteDialog(context, recipeProvider, recipe);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditRecipeScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, RecipeProvider provider, recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Resep'),
        content: Text('Apakah kamu yakin ingin menghapus resep "${recipe.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteRecipe(recipe);
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
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
}
