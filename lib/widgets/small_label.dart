import 'package:flutter/material.dart';

class SmallLabel extends StatelessWidget {
  const SmallLabel({Key? key, required this.text}) : super(key: key);

  final Widget text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
        child: DefaultTextStyle(
          style: textTheme.titleMedium!.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          child: text,
        ),
      ),
    );
  }
}
