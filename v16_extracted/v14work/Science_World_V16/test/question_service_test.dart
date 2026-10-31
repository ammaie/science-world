import 'package:flutter_test/flutter_test.dart';
import 'package:science_world/features/questions/data/question_service.dart';

void main() {
  test('QuestionService should be instantiable', () {
    final service = QuestionService();
    expect(service, isNotNull);
  });
}
