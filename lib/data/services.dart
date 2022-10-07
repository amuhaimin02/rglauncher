import 'package:get_it/get_it.dart';
import 'package:rglauncher/utils/media_manager.dart';

import 'globals.dart';

final services = GetIt.instance;

Future<void> initializeServices() async {
  services.registerSingleton(await Globals.setup());
  services.registerSingleton(
    MediaManager(services<Globals>().privateAppDirectory.path),
  );
}
