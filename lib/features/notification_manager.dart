import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/utils/debouncer.dart';

class NotificationManager extends StateNotifier<NotificationMessage?> {
  NotificationManager() : super(null);

  final _debouncer = Debouncer(const Duration(seconds: 2));

  Future<void> runTask({
    required FutureOr<void> Function(TaskUpdater) task,
    String initialLabel = 'Please wait...',
    String successLabel = 'Done',
    String failedLabel = 'Failed',
  }) async {
    try {
      set(NotificationMessage(
          label: initialLabel, status: NotificationStatus.inProgress));
      await task.call(_update);
      set(NotificationMessage(
          label: successLabel, status: NotificationStatus.success));
    } catch (e, s) {
      print(e);
      print(s);
      set(NotificationMessage(
          label: failedLabel, status: NotificationStatus.failed));
    }
  }

  void _update(String label, double progress) {
    set(NotificationMessage(
      label: label,
      status: NotificationStatus.inProgress,
      progress: progress,
    ));
  }

  void set(NotificationMessage message) {
    state = message;
    if (message.status != NotificationStatus.inProgress) {
      _debouncer.runLater(() => state = null);
    }
  }
}

typedef TaskUpdater = Function(String label, double progress);

class NotificationMessage {
  final String label;
  final double? progress;
  final NotificationStatus status;
  final Icon? icon;

  const NotificationMessage({
    required this.label,
    this.progress,
    this.status = NotificationStatus.neutral,
    this.icon,
  });
}

enum NotificationStatus { inProgress, success, failed, neutral, warning }
