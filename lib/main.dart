import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
// path_provider tidak dipakai di Web, Hive sudah otomatis pakai IndexedDB

import 'package:flutter_application_1/models/recipe.dart';
import 'package:flutter_application_1/models/ingredient.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/models/shopping_item.dart';
import 'package:flutter_application_1/providers/recipe_provider.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_application_1/providers/shopping_provider.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hive.initFlutter() tanpa path: otomatis pakai path yang benar di Android/iOS/Web
  await Hive.initFlutter();

  Hive.registerAdapter(RecipeAdapter());
  Hive.registerAdapter(IngredientAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(ShoppingItemAdapter());

  // Open a box for recipes and users
  await Hive.openBox<Recipe>('recipes');
  await Hive.openBox<User>('usersBox');
  await Hive.openBox<ShoppingItem>('shopping_list');
  await Hive.openBox('session'); // Buka box session untuk persistensi login

  final authProvider = AuthProvider();
  final recipeProvider = RecipeProvider();

  // Jika user sudah otomatis login dari sesi sebelumnya, langsung set user di RecipeProvider
  if (authProvider.isLoggedIn) {
    recipeProvider.setCurrentUser(
      authProvider.currentUser?.email,
      authProvider.isAdmin,
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: recipeProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ShoppingProvider()),
      ],
      child: const RecipeApp(),
    ),
  );
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisi palet warna Warm & Cozy (Earthy Tones)
    const primaryColor = Color(0xFFE76F51); // Orange bata hangat
    const secondaryColor = Color(0xFFF4A261); // Kuning madu hangat
    const backgroundColor = Color(0xFFFAF5EF); // Krem lembut (warm milk/sand)
    const darkTextColor = Color(0xFF2B2D42); // Navy gelap kecokelatan untuk teks utama

    return MaterialApp(
      title: 'Aplikasi Resep',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
          // 'background' sudah deprecated, pakai surface
          surface: backgroundColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFDFBF7), // Gading pucat hangat
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: darkTextColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: primaryColor),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: CircleBorder(),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFFDF9), // Putih gading bersih
          labelStyle: const TextStyle(color: Color(0xFF8D99AE)),
          floatingLabelStyle: const TextStyle(color: primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD5BDAF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE3D5CA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFDF9),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return auth.isLoggedIn ? const MainScreen() : const LoginScreen();
        },
      ),
    );
  }
}