import 'package:hive/hive.dart';

part 'shopping_item.g.dart';

@HiveType(typeId: 2) // Gunakan typeId unik, sesuaikan jika sudah ada 0 dan 1
class ShoppingItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  bool isChecked;

  ShoppingItem({
    required this.id,
    required this.name,
    this.isChecked = false,
  });
}
