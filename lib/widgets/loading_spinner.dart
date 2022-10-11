import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({super.key}) : small = false;

  const LoadingSpinner.small({super.key}) : small = true;

  final bool small;

  @override
  Widget build(BuildContext context) {
    if (small) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(),
      );
    }
    return Center(
      child: Container(
        margin: const EdgeInsets.all(64),
        width: 200,
        child: const LinearProgressIndicator(
          color: Colors.white,
          backgroundColor: Colors.white38,
        ),
      ),
    );
  }
}
