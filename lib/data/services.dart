import 'package:get_it/get_it.dart';

import 'globals.dart';

final services = GetIt.instance;

Future<void> initializeServices() async {
  services.registerSingleton(await Globals.setup());
}
