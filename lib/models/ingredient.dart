import 'package:hive/hive.dart';

part 'ingredient.g.dart';

@HiveType(typeId: 1)
class Ingredient extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String quantity;

  Ingredient({
    required this.name,
    required this.quantity,
  });
}