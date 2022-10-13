import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/data/configs.dart';
import 'package:rglauncher/data/providers.dart';
import 'package:rglauncher/features/notification_manager.dart';

class NotificationOverlay extends ConsumerWidget {
  const NotificationOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(notificationProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      child: AnimatedSwitcher(
        duration: defaultAnimationDuration,
        switchInCurve: defaultAnimationCurve,
        transitionBuilder: (child, animation) {
          // Transition that slides from top, with fading
          return ScaleTransition(
            // position: Tween(
            //   begin: const Offset(0, -1),
            //   end: const Offset(0, 0),
            // ).animate(animation),
            scale: Tween<double>(
              begin: 0.8,
              end: 1,
            ).animate(animation),
            alignment: Alignment.topCenter,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: Builder(
          key: ValueKey(message),
          builder: (context) {
            if (message == null) {
              return const SizedBox();
            }
            return Material(
              color: () {
                switch (message.status) {
                  case NotificationStatus.neutral:
                  case NotificationStatus.inProgress:
                  case NotificationStatus.success:
                    return Colors.grey.shade800;
                  case NotificationStatus.failed:
                    return Colors.red;
                  case NotificationStatus.warning:
                    return Colors.amber;
                }
              }(),
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 360,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                      if (message.icon != null) {
                        return message.icon!;
                      }
                      switch (message.status) {
                        case NotificationStatus.inProgress:
                          return const Icon(Icons.hourglass_full_rounded);
                        case NotificationStatus.success:
                          return const Icon(Icons.done_rounded);
                        case NotificationStatus.failed:
                          return const Icon(Icons.error_rounded);
                        case NotificationStatus.warning:
                          return const Icon(Icons.warning);
                        case NotificationStatus.neutral:
                          return const Icon(Icons.info);
                      }
                    }(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
