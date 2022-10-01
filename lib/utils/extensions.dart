Stream<T> onceAndPeriodic<T>(
    Duration period, T Function(int) computation) async* {
  yield computation(0);
  yield* Stream.periodic(period, (i) => computation(i + 1));
}
