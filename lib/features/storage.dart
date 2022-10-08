import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/models.dart';
import '../objectbox.g.dart';

class Storage {
  final Store store;
  late final Box<Game> gameBox;
  late final Box<System> systemBox;
  late final Box<Emulator> emulatorBox;

  Storage._(this.store)
      : gameBox = Box<Game>(store),
        systemBox = Box<System>(store),
        emulatorBox = Box<Emulator>(store);

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<Storage> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: p.join(docsDir.path, "storage"));
    return Storage._(store);
  }
}
