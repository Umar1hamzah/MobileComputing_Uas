import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/ingredient.dart';

void main() {
  group('Ingredient Model Tests', () {
    test('Should correctly initialize ingredient properties', () {
      final ingredient = Ingredient(name: 'Garam', quantity: '1 sdt');
      
      expect(ingredient.name, equals('Garam'));
      expect(ingredient.quantity, equals('1 sdt'));
    });
  });
}
