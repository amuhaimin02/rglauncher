import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rglauncher/data/providers.dart';
import 'package:rglauncher/widgets/async_widget.dart';
import 'package:rglauncher/widgets/command.dart';
import 'package:rglauncher/widgets/launcher_scaffold.dart';

import '../utils/navigate.dart';

class AllAppsScreen extends ConsumerWidget {
  const AllAppsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                          child: Image.memory(app.icon),
                        ),
                        onTap: () {
                          app.openApp();
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        app.appName,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
