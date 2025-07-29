import 'package:flutter_test/flutter_test.dart';
import 'package:noteappflu/utilis/debouncer.dart';

void main() {
  test('Debouncer delays execution', () async {
    final debouncer = Debouncer(delay: const Duration(milliseconds: 200));

    var counter = 0;
    debouncer.run(() => counter++); 
    debouncer.run(() => counter++); 
    debouncer.run(() => counter++); 
    expect(counter, 0);

    await Future.delayed(const Duration(milliseconds: 300));
    expect(counter, 1);
  });

  test('Debouncer cancels properly on dispose', () async {
    final debouncer = Debouncer(delay: const Duration(milliseconds: 100));
    var called = false;

    debouncer.run(() => called = true);
    debouncer.dispose();

    await Future.delayed(const Duration(milliseconds: 200));
    expect(called, false);
  });
}
