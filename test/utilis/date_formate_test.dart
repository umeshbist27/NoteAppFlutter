import 'package:flutter_test/flutter_test.dart';
import 'package:noteappflu/utilis/date_formatter.dart';

void main() {
  test('Formats date correctly', () {
    final date = DateTime(2025, 7, 29, 9, 5); 
    final formatted = DateFormatter.format(date);
    expect(formatted, '29 JUL 25 09:05');
  });
}
