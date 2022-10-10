// class System {
//   final String code;
//
//   final String name;
//   final String producer;
//
//   final String imageLink;
//
//   final List<String> folderNames;
//
//   final List<String> supportedExtensions;
//
//   const System({
//     required this.name,
//     required this.code,
//     required this.producer,
//     required this.imageLink,
//     required this.folderNames,
//     required this.supportedExtensions,
//   });
//
//   @override
//   String toString() => 'System: $code';
// }
//
// class Emulator {
//   final String code;
//
//   final String name;
//
//   final String executable;
//
//   final String forSystem;
//
//   final String? libretroPath;
//
//   const Emulator({
//     required this.name,
//     required this.code,
//     required this.executable,
//     required this.forSystem,
//     this.libretroPath,
//   });
//
//   @override
//   String toString() => 'Emulator: $code';
//
//   bool get isRetroarch => libretroPath != null;
//
//   String get androidPackageName =>
//       executable.substring(0, executable.indexOf('/'));
//
//   String get androidComponentName =>
//       executable.substring(executable.indexOf('/') + 1);
// }

import 'package:drift/drift.dart';

import 'database.dart';

class Systems extends Table {
  TextColumn get code => text()();

  TextColumn get name => text()();

  TextColumn get producer => text()();

  TextColumn get thumbnailLink => text().named('thumbnail')();

  TextColumn get folderNames =>
      text().named('folders').map(const StringListConverter())();

  TextColumn get supportedExtensions =>
      text().named('extensions').map(const StringListConverter())();

  @override
  Set<Column<Object>>? get primaryKey => {code};
}

class Emulators extends Table {
  TextColumn get code => text()();

  TextColumn get name => text()();

  TextColumn get executable => text()();

  TextColumn get system => text().named('system').references(Systems, #id)();

  TextColumn get libretroPath => text().named('libretro').nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {code};
}

// class Game {
//   final String name;
//   final String filepath;
//   final System system;
//
//   const Game({
//     required this.name,
//     required this.filepath,
//     required this.system,
//   });
// }
class Games extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get filepath => text()();

  TextColumn get system => text().named('system').references(Systems, #id)();
}
