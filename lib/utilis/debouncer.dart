import 'dart:async';
import 'dart:ui';

class Debouncer {
  late final Duration delay;
  Timer? _timer;
  Debouncer({required this.delay});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() => _timer?.cancel();
}
