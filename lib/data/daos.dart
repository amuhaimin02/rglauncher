import 'package:floor/floor.dart';

import 'models.dart';

@dao
abstract class SystemDao {
  @Query('SELECT * FROM systems')
  Future<List<System>> listAll();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> add(System system);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> addAll(List<System> systems);
}

@dao
abstract class EmulatorDao {
  @Query('SELECT * FROM emulators')
  Future<List<Emulator>> listAll();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> add(Emulator emulator);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> addAll(List<Emulator> emulators);

  @Query('SELECT * FROM emulators WHERE system=:systemCode')
  Future<List<Emulator>> getFor(String systemCode);
}
