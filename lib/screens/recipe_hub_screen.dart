import 'package:flutter/material.dart';
import 'favorite_recipes_screen.dart';
import 'my_recipes_screen.dart';

class RecipeHubScreen extends StatelessWidget {
  const RecipeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resep Hub'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Resep Saya'),
              Tab(text: 'Favorit'),
            ],
            labelColor: Color(0xFFE76F51),
            indicatorColor: Color(0xFFE76F51),
          ),
        ),
        body: const TabBarView(
          children: [
            MyRecipesScreen(),
            FavoriteRecipesScreen(),
          ],
        ),
      ),
    );
  }
}
