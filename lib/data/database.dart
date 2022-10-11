import 'package:isar/isar.dart';

import 'models.dart';

class Database {
  late final Isar _isar;

  Database._(Isar isar) : _isar = isar;

  static const _schema = [
    SystemSchema,
    EmulatorSchema,
    GameSchema,
  ];

  static Future<Database> open() async {
    return Database._(await Isar.open(_schema));
  }

  Future<void> updateSystems(List<System> systemList) async {
    _isar.writeTxnSync(() {
      _isar.systems.putAllSync(systemList);
    });
  }

  Future<List<System>> allSystems() async {
    return _isar.systems.where().anyId().findAll();
  }

  Future<System?> getSystemForGame(Game game) async {
    return _isar.systems.getByCode(game.systemCode);
  }

  Future<void> updateEmulators(List<Emulator> emulatorList) async {
    _isar.writeTxnSync(() {
      _isar.emulators.putAllSync(emulatorList);
    });
  }

  Future<List<Emulator>> allEmulators() async {
    return _isar.emulators.where().anyId().findAll();
  }

  Future<void> refreshGames(List<Game> gameList) async {
    _isar.writeTxnSync(() {
      _isar.games.clearSync();
      _isar.games.putAllSync(gameList);
    });
  }

  Future<List<Game>> allGames() async {
    return _isar.games.where().sortByName().findAll();
  }

  Future<List<Game>> allGamesBySystem(System system) async {
    return _isar.games
        .filter()
        .systemCodeEqualTo(system.code)
        .sortByName()
        .findAll();
  }

  Future<List<Emulator>> allEmulatorsBySystem(System system) async {
    return _isar.emulators
        .filter()
        .systemCodeEqualTo(system.code)
        .sortByName()
        .findAll();
  }

  Future<List<System>> scannedSystems() async {
    final systemCodes =
        await _isar.games.where().distinctBySystemCode().findAll();
    return _isar.systems
        .filter()
        .anyOf(systemCodes, (s, game) => s.codeEqualTo(game.systemCode))
        .findAll();
  }
}

// import 'dart:io';
//
// import 'package:drift/drift.dart';
// import 'package:drift/native.dart';
// import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart';
// import 'package:rglauncher/data/configs.dart';
//
// import 'models.dart';
//
// part 'database.g.dart';
//
// class StringListConverter extends TypeConverter<List<String>, String> {
//   const StringListConverter();
//
//   @override
//   List<String> fromSql(String fromDb) {
//     return fromDb.split(',');
//   }
//
//   @override
//   String toSql(List<String> value) {
//     return value.join(',');
//   }
// }
//
// @DriftDatabase(
//   tables: [Systems, Emulators, Games],
// )
// class AppDatabase extends _$AppDatabase {
//   AppDatabase() : super(_openConnection());
//
//   @override
//   int get schemaVersion => 1;
//
//   static LazyDatabase _openConnection() {
//     return LazyDatabase(() async {
//       final dbFolder = await getApplicationDocumentsDirectory();
//       final file = File(path.join(dbFolder.path, dbFileName));
//       return NativeDatabase(file);
//     });
//   }
//
//   Future<void> updateSystems(List<System> s) async {
//     await batch((batch) {
//       batch.insertAllOnConflictUpdate(systems, s);
//     });
//   }
//
//   Future<List<System>> allSystems() async {
//     return select(systems).get();
//   }
//
//   Future<void> updateEmulators(List<Emulator> s) async {
//     await batch((batch) {
//       batch.insertAllOnConflictUpdate(emulators, s);
//     });
//   }
//
//   Future<List<Emulator>> allEmulators() async {
//     return select(emulators).get();
//   }
//
//   Future<void> refreshGames(List<Insertable<Game>> g) async {
//     await batch((batch) {
//       delete(games).go();
//       batch.insertAllOnConflictUpdate(games, g);
//     });
//   }
//
//   Future<List<Game>> allGames() async {
//     return select(games).get();
//   }
//
//   Future<List<Game>> allGamesBySystem(System system) async {
//     return (select(games)
//           ..where((g) => g.system.equals(system.code))
//           ..orderBy([(g) => OrderingTerm(expression: g.name)]))
//         .get();
//   }
//
//   Future<List<Emulator>> allEmulatorsBySystem(System system) async {
//     return (select(emulators)..where((e) => e.system.equals(system.code)))
//         .get();
//   }
// }
