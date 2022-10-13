import 'package:flutter/material.dart';

class SmallLabel extends StatelessWidget {
  const SmallLabel(
      {Key? key, required this.text, this.textColor, this.backgroundColor})
      : super(key: key);

  final Widget text;
  final Color? textColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: backgroundColor ?? Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
        child: DefaultTextStyle(
          style: textTheme.titleMedium!.copyWith(
            color: textColor ?? Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          child: text,
        ),
      ),
    );
  }
}
