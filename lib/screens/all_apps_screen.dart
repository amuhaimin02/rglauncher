import 'dart:typed_data';

import 'package:device_apps/src/plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rglauncher/data/configs.dart';
import 'package:rglauncher/data/database.dart';
import 'package:rglauncher/data/providers.dart';
import 'package:rglauncher/features/services.dart';
import 'package:rglauncher/widgets/async_widget.dart';
import 'package:rglauncher/widgets/command.dart';
import 'package:rglauncher/widgets/launcher_scaffold.dart';

import '../data/models.dart';
import '../features/notification_manager.dart';
import '../utils/navigate.dart';

class AllAppsScreen extends ConsumerStatefulWidget {
  const AllAppsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AllAppsScreen> createState() => _AllAppsScreenState();
}

class _AllAppsScreenState extends ConsumerState<AllAppsScreen> {
  @override
  Widget build(BuildContext context) {
    return LauncherScaffold(
      body: CommandWrapper(
        commands: [
          Command(
            button: CommandButton.a,
            label: 'Open',
            onTap: () => Navigate.back(),
          ),
          Command(
            button: CommandButton.b,
            label: 'Back',
            onTap: () => Navigate.back(),
          )
        ],
        child: AsyncWidget(
          value: ref.watch(installedAppsProvider),
          data: (allApps) {
            return AsyncWidget(
              value: ref.watch(pinnedAppsProvider),
              data: (pinnedApps) {
                return GridView.count(
                  padding: const EdgeInsets.all(64),
                  crossAxisCount: 8,
                  childAspectRatio: 0.7,
                  children: [
                    for (final app in allApps)
                      Column(
                        children: [
                          InkWell(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Stack(
                                children: [
                                  Image.memory(
                                    app.iconBytes as Uint8List,
                                    gaplessPlayback: true,
                                  ),
                                  if (pinnedApps.any((element) =>
                                  element.packageName == app.packageName))
                                    const Align(
                                      alignment: AlignmentDirectional.bottomEnd,
                                      child: Material(
                                        type: MaterialType.circle,
                                        color: Colors.red,
                                        elevation: 6,
                                        child: Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(
                                            MdiIcons.pin,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ),
                            onTap: () {
                              DeviceApps.openApp(app.packageName);
                            },
                            onLongPress: () {
                              _togglePinApp(app);
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            app.name,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _togglePinApp(App app) async {
    final notifier = ref.read(notificationProvider.notifier);
    final db = services<Database>();

    if (await db.togglePinApp(app)) {
      notifier.set(
        const NotificationMessage(
          label: 'Pinned app to home page',
          status: NotificationStatus.success,
          icon: Icon(MdiIcons.pin),
        ),
      );
    } else {
      notifier.set(
        const NotificationMessage(
          label: 'Unpinned from home page',
          status: NotificationStatus.success,
          icon: Icon(MdiIcons.pinOff),
        ),
      );
    }
  }
}
