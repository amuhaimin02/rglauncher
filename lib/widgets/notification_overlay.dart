import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/data/providers.dart';
import 'package:rglauncher/features/notification_manager.dart';

class NotificationOverlay extends ConsumerWidget {
  const NotificationOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(notificationProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      child: Builder(
        builder: (context) {
          if (message == null) {
            return const SizedBox();
          }
          return Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 360,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.label,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                        if (message.status ==
                            NotificationStatus.inProgress) ...[
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: message.progress,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  () {
                    switch (message.status) {
                      case NotificationStatus.inProgress:
                        return const Icon(Icons.hourglass_full_rounded);
                      case NotificationStatus.success:
                        return const Icon(Icons.done_rounded);
                      case NotificationStatus.failed:
                        return const Icon(Icons.error_rounded,
                            color: Colors.red);
                    }
                  }(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
