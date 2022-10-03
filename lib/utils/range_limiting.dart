import 'dart:ui';

void rangeLimit({
  required num value,
  num min = 0,
  required num max,
  required VoidCallback ifInRange,
}) {
  if (value < min || value >= max) {
    return;
  }
  ifInRange();
}
