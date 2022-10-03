import 'package:flutter/material.dart';

class LargeClock extends StatelessWidget {
  const LargeClock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.center,
      child: StreamBuilder<void>(
        stream: Stream.periodic(const Duration(seconds: 2)),
        builder: (context, snapshot) {
          final now = DateTime.now();
          return Text(
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 108,
            ),
          );
        },
      ),
    );
  }
}
