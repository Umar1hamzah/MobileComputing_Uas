import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_1/models/shopping_item.dart';
import 'package:uuid/uuid.dart';

class ShoppingProvider extends ChangeNotifier {
  late Box<ShoppingItem> _shoppingBox;
  List<ShoppingItem> _shoppingList = [];
  var uuid = const Uuid();

  ShoppingProvider() {
    _shoppingBox = Hive.box<ShoppingItem>('shopping_list');
    _loadShoppingList();
  }

  List<ShoppingItem> get shoppingList => _shoppingList;

  void _loadShoppingList() {
    _shoppingList = _shoppingBox.values.toList();
    notifyListeners();
  }

  void addItem(String name) {
    final newItem = ShoppingItem(id: uuid.v4(), name: name);
    _shoppingBox.put(newItem.id, newItem);
    _loadShoppingList();
  }

  void toggleItem(ShoppingItem item) {
    item.isChecked = !item.isChecked;
    item.save();
    _loadShoppingList();
  }

  void removeItem(ShoppingItem item) {
    item.delete();
    _loadShoppingList();
  }
}
