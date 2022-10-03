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
