import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/models/recipe.dart';
import 'package:flutter_application_1/providers/recipe_provider.dart';
import 'package:flutter_application_1/screens/add_edit_recipe_screen.dart'; // Import AddEditRecipeScreen
import 'package:flutter_application_1/widgets/recipe_image.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          IconButton(
            icon: Icon(
              recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: recipe.isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              Provider.of<RecipeProvider>(context, listen: false).toggleFavorite(recipe);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditRecipeScreen(recipe: recipe),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _confirmDelete(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar resep yang cerdas
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildRecipeImage(recipe),
            ),
            const SizedBox(height: 16),
            Text(
              'Bahan-bahan:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: recipe.ingredients
                  .map((ingredient) => Text('- ${ingredient.quantity} ${ingredient.name}'))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Instruksi:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(recipe.instructions),
            const SizedBox(height: 16),
            if (recipe.notes != null && recipe.notes!.isNotEmpty) ...[
              Text(
                'Catatan Memasak:',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(recipe.notes!),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Resep'),
          content: const Text('Apakah Anda yakin ingin menghapus resep ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Provider.of<RecipeProvider>(context, listen: false).deleteRecipe(recipe);
                Navigator.of(dialogContext).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecipeImage(Recipe recipe) {
    return RecipeImage(
      imageUrl: recipe.assetImagePath ?? recipe.localImagePath ?? recipe.imageUrl,
      imageBase64: recipe.imageBase64,
      width: double.infinity,
      height: 200,
    );
  }

  Widget _placeholder(double height) {
    return Container(
      width: double.infinity,
      height: height,
      color: const Color(0xFFF4A261).withOpacity(0.3),
      child: const Icon(Icons.restaurant, size: 64, color: Color(0xFFE76F51)),
    );
  }
}