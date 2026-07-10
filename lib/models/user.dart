import 'package:hive/hive.dart';

part 'user.g.dart'; // Auto-generated oleh build_runner

@HiveType(typeId: 3) // typeId harus unik, 0=Recipe, 1=Ingredient, 2=ShoppingItem, 3=User
class User extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  String password; // Catatan: untuk UAS ini kita simpan plain text. Produksi nyata harus di-hash!

  @HiveField(3)
  String role; // 'admin' atau 'user'

  User({
    required this.name,
    required this.email,
    required this.password,
    this.role = 'user',
  });
}
