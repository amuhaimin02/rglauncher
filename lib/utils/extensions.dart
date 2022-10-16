Stream<T> onceAndPeriodic<T>(
    Duration period, T Function(int) computation) async* {
  yield computation(0);
  yield* Stream.periodic(period, (i) => computation(i + 1));
}

extension SafeIndexAccessList<E> on List<E> {
  E? get(int index) {
    try {
      return this[index];
    } on RangeError {
      return null;
    }
  }
}

extension PrevNextIndexAccessList<E> on List<E> {
  E? previousOf(E? item) {
    if (item == null) return null;
    try {
      return this[indexOf(item) - 1];
    } on RangeError {
      return null;
    }
  }

  E? nextOf(E? item) {
    if (item == null) return null;
    try {
      return this[indexOf(item) + 1];
    } on RangeError {
      return null;
    }
  }
}

extension PercentageString on num {
  String toPercentage({int fractionalDigits = 0}) {
    return '${(this * 100).toStringAsFixed(fractionalDigits)} %';
  }
}
