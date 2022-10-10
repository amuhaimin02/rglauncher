import 'dart:async';

import 'package:floor/floor.dart';

// ignore: depend_on_referenced_packages
import 'package:sqflite/sqflite.dart' as sqflite;

import 'daos.dart';
import 'models.dart';

part 'database.g.dart';

@TypeConverters([StringListConverter])
@Database(version: 1, entities: [System, Emulator])
abstract class AppDatabase extends FloorDatabase {
  SystemDao get systems;

  EmulatorDao get emulators;

  static Future<AppDatabase> open(String dbFileName) async {
    return $FloorAppDatabase.databaseBuilder(dbFileName).build();
  }
}

class StringListConverter extends TypeConverter<List<String>, String> {
  @override
  List<String> decode(String databaseValue) {
    return databaseValue.split(',');
  }

  @override
  String encode(List<String> value) {
    return value.join(',');
  }
}
