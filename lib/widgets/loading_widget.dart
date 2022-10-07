import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
