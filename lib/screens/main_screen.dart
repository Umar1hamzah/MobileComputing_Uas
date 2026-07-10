import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'recipe_hub_screen.dart'; 
import 'profile_screen.dart';    
import 'shopping_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Daftar halaman
  final List<Widget> _pages = [
    const HomeScreen(),
    const ShoppingListScreen(),
    const RecipeHubScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), label: 'Belanja'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Resep Hub'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
