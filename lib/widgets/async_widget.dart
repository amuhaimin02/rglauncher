import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/widgets/loading_spinner.dart';

class AsyncWidget<T> extends StatelessWidget {
  const AsyncWidget({
    Key? key,
    required this.value,
    required this.data,
    this.error,
    this.loading,
  }) : super(key: key);

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function(Object error, StackTrace stackTrace)? error;
  final Widget Function()? loading;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      error: error ?? (error, stack) => Text('$error\n$stack'),
      loading: loading ?? () => const Center(child: LoadingSpinner()),
    );
  }
}
