import 'package:floor/floor.dart';

@Entity(
  tableName: 'systems',
)
class System {
  @primaryKey
  final String code;

  @ColumnInfo(name: 'name')
  final String name;

  @ColumnInfo(name: 'producer')
  final String producer;

  @ColumnInfo(name: 'image')
  final String imageLink;

  @ColumnInfo(name: 'folders')
  final List<String> folderNames;

  @ColumnInfo(name: 'extensions')
  final List<String> supportedExtensions;

  const System({
    required this.name,
    required this.code,
    required this.producer,
    required this.imageLink,
    required this.folderNames,
    required this.supportedExtensions,
  });

  @override
  String toString() => 'System: $code';
}

@Entity(
  tableName: 'emulators',
  foreignKeys: [
    ForeignKey(
      childColumns: ['system'],
      parentColumns: ['code'],
      entity: System,
    )
  ],
)
class Emulator {
  @primaryKey
  final String code;

  @ColumnInfo(name: 'name')
  final String name;

  @ColumnInfo(name: 'executable')
  final String executable;

  @ColumnInfo(name: 'system')
  final String forSystem;

  @ColumnInfo(name: 'libretro')
  final String? libretroPath;

  const Emulator({
    required this.name,
    required this.code,
    required this.executable,
    required this.forSystem,
    this.libretroPath,
  });

  @override
  String toString() => 'Emulator: $code';

  bool get isRetroarch => libretroPath != null;

  String get androidPackageName =>
      executable.substring(0, executable.indexOf('/'));

  String get androidComponentName =>
      executable.substring(executable.indexOf('/') + 1);
}

class Game {
  final String name;
  final String filepath;
  final System system;

  const Game({
    required this.name,
    required this.filepath,
    required this.system,
  });
}
