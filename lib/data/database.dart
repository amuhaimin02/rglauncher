import 'package:collection/collection.dart';
import 'package:isar/isar.dart';
import 'package:rglauncher/data/configs.dart';

import 'models.dart';

class Database {
  late final Isar _isar;

  Database._(Isar isar) : _isar = isar;

  static const _schema = [
    SystemSchema,
    EmulatorSchema,
    GameSchema,
    GameMetadataSchema,
  ];

  static Future<Database> open({bool temporary = false}) async {
    return Database._(await Isar.open(_schema, inspector: !temporary));
  }

  Future<void> updateSystems(List<System> systemList) async {
    _isar.writeTxnSync(() {
      _isar.systems.putAllSync(systemList);
    });
  }

  Future<List<System>> getAllSystems() async {
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

  Future<List<Emulator>> getAllEmulators() async {
    return _isar.emulators.where().anyId().findAll();
  }

  Future<void> refreshGames(List<Game> gameList) async {
    _isar.writeTxnSync(() {
      _isar.games.putAllSync(gameList);
    });
  }

  Future<List<Game>> getAllGames() async {
    return _isar.games.where().sortByName().findAll();
  }

  Future<List<Game>> getGamesBySystem(System system) async {
    return _isar.games
        .filter()
        .systemCodeEqualTo(system.code)
        .sortByName()
        .findAll();
  }

  Future<void> toggleFavorite(Game game) async {
    await _isar.writeTxn(() async {
      game.isFavorite = !game.isFavorite;
      _isar.games.put(game);
    });
  }

  Future<void> toggleWishlist(Game game) async {
    await _isar.writeTxn(() async {
      game.isWishlist = !game.isWishlist;
      _isar.games.put(game);
    });
  }

  Future<void> updateLastPlayed(Game game) async {
    await _isar.writeTxn(() async {
      game.timeLastPlayed = DateTime.now();
      _isar.games.put(game);
    });
  }

  Future<void> pinGame(Game game, int pinIndex) async {
    await _isar.writeTxn(() async {
      game.pinIndex = pinIndex;
      _isar.games.put(game);
    });
  }

  Future<void> removePinFromGame(Game game) async {
    await _isar.writeTxn(() async {
      game.pinIndex = null;
      _isar.games.put(game);
    });
  }

  Future<void> saveGameMetadata(Game game, GameMetadata meta) async {
    await _isar.writeTxn(() async {
      await _isar.gameMetadatas.put(
        meta..key = game.filename,
      );
    });
  }

  Future<GameMetadata?> getMetadataForGame(Game game) async {
    return _isar.gameMetadatas.getByKey(game.filename);
  }

  Future<List<Emulator>> allEmulatorsBySystemCode(String systemCode) async {
    return _isar.emulators
        .filter()
        .systemCodeEqualTo(systemCode)
        .sortByName()
        .findAll();
  }

  Future<List<System>> getScannedSystems() async {
    final systemCodes =
        await _isar.games.where().distinctBySystemCode().findAll();
    return _isar.systems
        .filter()
        .anyOf(systemCodes, (s, game) => s.codeEqualTo(game.systemCode))
        .findAll();
  }

  Future<List<Game>> getFavoritedGames() {
    return _isar.games.filter().isFavoriteEqualTo(true).findAll();
  }

  Future<List<Game>> getWishlistedGames() {
    return _isar.games.filter().isWishlistEqualTo(true).findAll();
  }

  Future<List<Game>> getRecentGames() {
    return _isar.games
        .filter()
        .timeLastPlayedIsNotNull()
        .sortByTimeLastPlayedDesc()
        .limit(100)
        .findAll();
  }

  Future<List<Game>> getNewlyAddedGames() {
    final pastRecentDays =
    DateTime.now().subtract(const Duration(days: daysConsideredRecent));
    return _isar.games
        .filter()
        .timeAddedGreaterThan(pastRecentDays)
        .sortByTimeAddedDesc()
        .limit(100)
        .findAll();
  }

  Future<List<Game>> getPinnedGames() {
    return _isar.games
        .filter()
        .pinIndexIsNotNull()
        .sortByPinIndexDesc()
        .limit(10)
        .findAll();
  }

  Stream<Game?> getLastPlayedGame() {
    return _isar.games
        .where()
        .timeLastPlayedIsNotNull()
        .sortByTimeLastPlayedDesc()
        .limit(1)
        .build()
        .watch(fireImmediately: true)
        .map((list) => list.firstOrNull);
  }
}
