import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:rglauncher/data/configs.dart';

import 'models.dart';

part 'database.g.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    return fromDb.split(',');
  }

  @override
  String toSql(List<String> value) {
    return value.join(',');
  }
}

@DriftDatabase(
  tables: [Systems, Emulators, Games],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(path.join(dbFolder.path, dbFileName));
      return NativeDatabase(file);
    });
  }

  Future<void> updateSystems(List<System> s) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(systems, s);
    });
  }

  Future<List<System>> allSystems() async {
    return select(systems).get();
  }

  Future<void> updateEmulators(List<Emulator> s) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(emulators, s);
    });
  }

  Future<List<Emulator>> allEmulators() async {
    return select(emulators).get();
  }

  Future<void> refreshGames(List<Insertable<Game>> g) async {
    await batch((batch) {
      delete(games).go();
      batch.insertAllOnConflictUpdate(games, g);
    });
  }

  Future<List<Game>> allGames() async {
    return select(games).get();
  }

  Future<List<Game>> allGamesBySystem(System system) async {
    return (select(games)
          ..where((g) => g.system.equals(system.code))
          ..orderBy([(g) => OrderingTerm(expression: g.name)]))
        .get();
  }

  Future<List<Emulator>> allEmulatorsBySystem(System system) async {
    return (select(emulators)..where((e) => e.system.equals(system.code)))
        .get();
  }
}
