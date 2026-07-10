import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/recipe_provider.dart';
import 'package:flutter_application_1/screens/recipe_detail_screen.dart';

class SearchByIngredientScreen extends StatefulWidget {
  const SearchByIngredientScreen({super.key});

  @override
  State<SearchByIngredientScreen> createState() => _SearchByIngredientScreenState();
}

class _SearchByIngredientScreenState extends State<SearchByIngredientScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  final List<String> _selectedIngredients = [];

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    final ingredientText = _ingredientController.text.trim();
    if (ingredientText.isNotEmpty && !_selectedIngredients.contains(ingredientText.toLowerCase())) {
      setState(() {
        _selectedIngredients.add(ingredientText.toLowerCase());
        _ingredientController.clear();
      });
      // Trigger search immediately after adding an ingredient
      Provider.of<RecipeProvider>(context, listen: false).searchRecipesByIngredients(_selectedIngredients);
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _selectedIngredients.remove(ingredient);
    });
    // Trigger search immediately after removing an ingredient
    Provider.of<RecipeProvider>(context, listen: false).searchRecipesByIngredients(_selectedIngredients);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ingredientController,
              decoration: InputDecoration(
                labelText: 'Masukkan Bahan',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addIngredient,
                ),
              ),
              onSubmitted: (_) => _addIngredient(),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              children: _selectedIngredients
                  .map(
                    (ingredient) => Chip(
                      label: Text(ingredient),
                      onDeleted: () => _removeIngredient(ingredient),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<RecipeProvider>(
                builder: (context, recipeProvider, child) {
                  final recipes = recipeProvider.recipes; // This will be the filtered list
                  if (_selectedIngredients.isEmpty) {
                    return const Center(child: Text('Tambahkan bahan untuk mencari resep.'));
                  }
                  if (recipes.isEmpty) {
                    return const Center(child: Text('Tidak ada resep yang ditemukan dengan bahan tersebut.'));
                  }
                  return ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(recipe.imageUrl),
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
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}