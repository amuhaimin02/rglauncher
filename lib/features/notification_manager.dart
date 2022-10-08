import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationManager extends StateNotifier<NotificationMessage?> {
  NotificationManager() : super(null);

  Future<void> runTask({
    required FutureOr<void> Function(TaskUpdater) task,
    String initialLabel = 'Please wait...',
    String successLabel = 'Done',
    String failedLabel = 'Failed',
  }) async {
    try {
      _setNewMessage(NotificationMessage(
          label: initialLabel, status: NotificationStatus.inProgress));
      await task.call(_update);
      _setNewMessage(NotificationMessage(
          label: successLabel, status: NotificationStatus.success));
    } catch (e, s) {
      print(e);
      print(s);
      _setNewMessage(NotificationMessage(
          label: failedLabel, status: NotificationStatus.failed));
    }
  }

  void _update(String label, double progress) {
    _setNewMessage(NotificationMessage(
      label: label,
      status: NotificationStatus.inProgress,
      progress: progress,
    ));
  }

  void _setNewMessage(NotificationMessage message) {
    state = message;
    if (message.status != NotificationStatus.inProgress) {
      Future.delayed(const Duration(seconds: 2), () {
        state = null;
      });
    }
  }
}

typedef TaskUpdater = Function(String label, double progress);

class NotificationMessage {
  final String label;
  final double? progress;
  final NotificationStatus status;

  const NotificationMessage({
    required this.label,
    this.progress,
    required this.status,
  });
}

enum NotificationStatus { inProgress, success, failed }
