import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs
import 'package:flutter_application_1/models/recipe.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter_application_1/models/ingredient.dart';
import 'package:flutter_application_1/providers/recipe_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/utils/image_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

class AddEditRecipeScreen extends StatefulWidget {
  final Recipe? recipe; // Null if adding new recipe, not null if editing

  const AddEditRecipeScreen({super.key, this.recipe});

  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _notesController = TextEditingController();
  final List<TextEditingController> _ingredientNameControllers = [];
  final List<TextEditingController> _ingredientQuantityControllers = [];

  bool _isEditing = false;
  bool _isPublic = false; // State baru
  var uuid = const Uuid();
  String? _localImagePath;
  String? _imageBase64;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _isEditing = true;
      _nameController.text = widget.recipe!.name;
      _imageUrlController.text = widget.recipe!.imageUrl;
      _instructionsController.text = widget.recipe!.instructions;
      _notesController.text = widget.recipe!.notes ?? '';
      _localImagePath = widget.recipe!.localImagePath;
      _imageBase64 = widget.recipe!.imageBase64;
      _isPublic = widget.recipe!.isPublic; // Inisialisasi dari recipe

      for (var ingredient in widget.recipe!.ingredients) {
        _ingredientNameControllers.add(TextEditingController(text: ingredient.name));
        _ingredientQuantityControllers.add(TextEditingController(text: ingredient.quantity));
      }
    } else {
      // Add initial empty ingredient fields for new recipe
      _ingredientNameControllers.add(TextEditingController());
      _ingredientQuantityControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _instructionsController.dispose();
    _notesController.dispose();
    for (var controller in _ingredientNameControllers) {
      controller.dispose();
    }
    for (var controller in _ingredientQuantityControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addIngredientField() {
    setState(() {
      _ingredientNameControllers.add(TextEditingController());
      _ingredientQuantityControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      _ingredientNameControllers[index].dispose();
      _ingredientQuantityControllers[index].dispose();
      _ingredientNameControllers.removeAt(index);
      _ingredientQuantityControllers.removeAt(index);
    });
  }

  // Fungsi untuk mengambil gambar dari Kamera
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80, // Kompres sedikit agar tidak terlalu besar
    );

    if (image != null) {
      if (kIsWeb) {
        final Uint8List bytes = await image.readAsBytes();
        setState(() {
          _imageBase64 = ImageUtils.encodeToBase64(bytes);
          _localImagePath = null; 
        });
      } else {
        // Simpan gambar secara permanen ke dokumen aplikasi agar tidak hilang saat cache dibersihkan
        final directory = await getApplicationDocumentsDirectory();
        final String fileName = 'recipe_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String permanentPath = '${directory.path}/$fileName';
        
        final File tempFile = File(image.path);
        await tempFile.copy(permanentPath);

        setState(() {
          _localImagePath = permanentPath;
          _imageBase64 = null;
        });
      }
    }
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      final List<Ingredient> ingredients = [];
      for (int i = 0; i < _ingredientNameControllers.length; i++) {
        if (_ingredientNameControllers[i].text.isNotEmpty && _ingredientQuantityControllers[i].text.isNotEmpty) {
          ingredients.add(Ingredient(
            name: _ingredientNameControllers[i].text,
            quantity: _ingredientQuantityControllers[i].text,
          ));
        }
      }

      if (ingredients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep harus memiliki setidaknya satu bahan.')),
        );
        return;
      }

      if (_isEditing) {
        final updatedRecipe = Recipe(
          id: widget.recipe!.id,
          name: _nameController.text,
          imageUrl: _imageUrlController.text,
          instructions: _instructionsController.text,
          ingredients: ingredients,
          isFavorite: widget.recipe!.isFavorite,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          localImagePath: _localImagePath,
          imageBase64: _imageBase64,
          isLocal: true,
          isPublic: _isPublic, // Simpan status publik
        );
        Provider.of<RecipeProvider>(context, listen: false).updateRecipe(updatedRecipe);
      } else {
        final newRecipe = Recipe(
          id: uuid.v4(), // Generate unique ID for new recipe
          name: _nameController.text,
          imageUrl: _imageUrlController.text,
          instructions: _instructionsController.text,
          ingredients: ingredients,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          localImagePath: _localImagePath,
          imageBase64: _imageBase64,
          isLocal: true,
          isPublic: _isPublic, // Simpan status publik
        );
        Provider.of<RecipeProvider>(context, listen: false).addRecipe(newRecipe);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Resep' : 'Tambah Resep Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Resep'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama resep tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Tampilan Gambar (Kamera)
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4A261).withOpacity(0.2), // Warna warm
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE76F51), width: 2),
                    ),
                    child: _localImagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: kIsWeb
                                ? const Icon(Icons.image, size: 50, color: Color(0xFFE76F51))
                                : Image.file(
                                    File(_localImagePath!),
                                    fit: BoxFit.cover,
                                  ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 50, color: Color(0xFFE76F51)),
                              SizedBox(height: 8),
                              Text('Tap untuk mengambil foto', style: TextStyle(color: Color(0xFFE76F51))),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'URL Gambar Resep (Opsional jika pakai kamera)'),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(labelText: 'Instruksi Memasak'),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Instruksi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Bahan-bahan:',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              ..._buildIngredientFields(),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addIngredientField,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Bahan'),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Catatan Memasak (Opsional)'),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Jadikan Resep Publik'),
                subtitle: const Text('User lain di perangkat ini bisa melihat resep Anda'),
                value: _isPublic,
                onChanged: (bool value) {
                  setState(() {
                    _isPublic = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveRecipe,
                child: Text(_isEditing ? 'Simpan Perubahan' : 'Tambah Resep'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildIngredientFields() {
    List<Widget> ingredientFields = [];
    for (int i = 0; i < _ingredientNameControllers.length; i++) {
      ingredientFields.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _ingredientNameControllers[i],
                  decoration: InputDecoration(labelText: 'Nama Bahan ${i + 1}'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama bahan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _ingredientQuantityControllers[i],
                  decoration: InputDecoration(labelText: 'Jumlah ${i + 1}'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => _removeIngredientField(i),
              ),
            ],
          ),
        ),
      );
    }
    return ingredientFields;
  }
}