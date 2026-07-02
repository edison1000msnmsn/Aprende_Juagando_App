import 'package:aprendejugando_mobile/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('interpreta un nivel con varias actividades', () {
    final level = LevelModel.fromJson({
      'id': 'math-l02',
      'number': 2,
      'title': 'Sumas pequeñas',
      'unlocked': true,
      'activities': [
        {'id': 'math-l02-a01', 'instruction': 'Suma dos frutas'},
        {'id': 'math-l02-a02', 'instruction': 'Completa la serie'},
      ],
    });

    expect(level.unlocked, isTrue);
    expect(level.activities, hasLength(2));
    expect(level.activities.last.id, 'math-l02-a02');
  });
}
