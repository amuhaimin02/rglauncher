import 'dart:async';
import 'dart:ui';

class Debouncer {
  Timer? _currentTimer;

  Debouncer(this.timerDuration);

  final Duration timerDuration;

  Future<void> runLater(VoidCallback task) async {
    if (_currentTimer != null) {
      _currentTimer?.cancel();
      _currentTimer = null;
    }
    _currentTimer = Timer(timerDuration, () {
      task();
      _currentTimer = null;
    });
  }
}
