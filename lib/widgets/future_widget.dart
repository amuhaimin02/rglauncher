import 'package:flutter/material.dart';
import 'package:rglauncher/widgets/loading_spinner.dart';

class FutureWidget<T> extends StatelessWidget {
  const FutureWidget({
    Key? key,
    required this.future,
    required this.builder,
    this.onError,
    this.onLoading,
  }) : super(key: key);

  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(
      BuildContext context, Object? error, StackTrace? stackTrace)? onError;
  final Widget Function(BuildContext context)? onLoading;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return builder(context, snapshot.data as T);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return onLoading?.call(context) ?? const LoadingSpinner();
        } else if (snapshot.hasError) {
          return onError?.call(context, snapshot.error, snapshot.stackTrace) ??
              Text('${snapshot.error}\n${snapshot.stackTrace}');
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
