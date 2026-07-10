// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final int typeId = 0;

  @override
  Recipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recipe(
      id: fields[0] as String,
      name: fields[1] as String,
      imageUrl: fields[2] as String,
      instructions: fields[3] as String,
      ingredients: (fields[4] as List).cast<Ingredient>(),
      isFavorite: fields[5] as bool,
      notes: fields[6] as String?,
      localImagePath: fields[7] as String?,
      isLocal: fields[8] as bool,
      assetImagePath: fields[9] as String?,
      imageBase64: fields[10] as String?,
      ownerEmail: fields[11] as String?,
      isPublic: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.instructions)
      ..writeByte(4)
      ..write(obj.ingredients)
      ..writeByte(5)
      ..write(obj.isFavorite)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.localImagePath)
      ..writeByte(8)
      ..write(obj.isLocal)
      ..writeByte(9)
      ..write(obj.assetImagePath)
      ..writeByte(10)
      ..write(obj.imageBase64)
      ..writeByte(11)
      ..write(obj.ownerEmail)
      ..writeByte(12)
      ..write(obj.isPublic);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
