import 'package:get_it/get_it.dart';
import 'package:rglauncher/data/database.dart';
import 'package:rglauncher/features/csv_storage.dart';
import 'package:rglauncher/features/library_manager.dart';
import 'package:rglauncher/features/media_manager.dart';

import '../data/globals.dart';
import 'app_launcher.dart';

final services = GetIt.instance;

Future<void> initializeServices() async {
  services.registerSingleton(await Globals.setup());
  services.registerSingleton(await Database.open());
  services.registerSingleton(
    MediaManager(services<Globals>().privateAppDirectory.path),
  );
  services.registerSingleton(const LibraryManager());
  services.registerSingleton(const AppLauncher());
}
