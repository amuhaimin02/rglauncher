import 'package:isar/isar.dart';
import 'package:path/path.dart' as path;
part 'models.g.dart';

@collection
class System {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String code;

  @Index()
  late String name;

  late String producer;

  late String thumbnailLink;

  late List<String> folderNames;

  late List<String> extensions;

  @override
  String toString() => 'System: $code';
}

@collection
class Emulator {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String code;

  @Index()
  late String name;

  late String executable;

  late String? libretroPath;

  @Index()
  late String systemCode;

  @override
  String toString() => 'Emulator: $code';

  @ignore
  bool get isRetroarch => libretroPath != null;

  @ignore
  String get androidPackageName =>
      executable.substring(0, executable.indexOf('/'));

  @ignore
  String get androidComponentName =>
      executable.substring(executable.indexOf('/') + 1);
}

@collection
class Game {
  Id id = Isar.autoIncrement;

  @Index()
  late String name;

  late String filename;

  late String filepath;

  @Index()
  late String systemCode;

  bool isFavorite = false;

  bool isWishlist = false;

  DateTime timeAdded = DateTime.now();

  @Index()
  DateTime? timeLastPlayed;

  @Index()
  int? pinIndex;

  @ignore
  String get fullpath => path.join(filepath, filename);
}

@collection
class GameMetadata {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String key;

  late String title;

  late String description;

  late String genre;
}
