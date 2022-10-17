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
    AppSchema,
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
      final gamesToDelete = List.of(gameList);
      for (final game in gameList) {
        final existingGame = _isar.games.getByFullpathSync(game.fullpath);

        if (existingGame != null) {
          existingGame.name = game.name;
          _updateMetadata(existingGame);
          _isar.games.putByFullpathSync(existingGame);
        } else {
          _updateMetadata(game);
          _isar.games.putByFullpathSync(game);
        }
        gamesToDelete.remove(game);
      }
      // Delete games not found in folders
      if (gamesToDelete.isNotEmpty) {
        _isar.games
            .filter()
            .anyOf(gamesToDelete,
                (q, element) => q.fullpathEqualTo(element.fullpath))
            .deleteAllSync();
      }
    });
  }

  void _updateMetadata(Game game) {
    final meta = _isar.gameMetadatas
        .where()
        .keyEqualTo(game.metadataKey)
        .findFirstSync();
    if (meta != null) {
      game.name = meta.title;
    }
  }

  Future<List<Game>> getAllGames() async {
    return _isar.games.where().sortByName().findAll();
  }

  Stream<List<Game>> getGamesBySystem(System system) {
    return _isar.games
        .filter()
        .systemCodeEqualTo(system.code)
        .sortByName()
        .watch(fireImmediately: true);
  }

  Future<bool> toggleFavorite(Game game) async {
    await _isar.writeTxn(() async {
      game.isFavorite = !game.isFavorite;
      _isar.games.put(game);
    });
    return game.isFavorite;
  }

  Future<bool> toggleWishlist(Game game) async {
    await _isar.writeTxn(() async {
      game.isWishlist = !game.isWishlist;
      _isar.games.put(game);
    });
    return game.isWishlist;
  }

  Future<void> updateLastPlayed(Game game) async {
    await _isar.writeTxn(() async {
      game.timeLastPlayed = DateTime.now();
      _isar.games.put(game);
    });
  }

  Future<bool> togglePinGame(Game game, int? pinIndex) async {
    await _isar.writeTxn(() async {
      if (game.pinIndex == null) {
        game.pinIndex = pinIndex;
      } else {
        game.pinIndex = null;
      }
      _isar.games.put(game);
    });
    return game.isPinned;
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
        meta..key = game.metadataKey,
      );
      await _isar.games.put(
        game..name = meta.title.isNotEmpty ? meta.title : game.filename,
      );
    });
  }

  GameMetadata? getMetadataForGame(Game game) {
    return _isar.gameMetadatas.getByKeySync(game.metadataKey);
  }

  Future<List<Emulator>> allEmulatorsBySystemCode(String systemCode) async {
    return _isar.emulators
        .filter()
        .systemCodeEqualTo(systemCode)
        .sortByName()
        .findAll();
  }

  Stream<List<System>> getScannedSystems() {
    return _isar.games
        .where()
        .distinctBySystemCode()
        .watch(fireImmediately: true)
        .map((systemCodes) => _isar.systems
            .filter()
            .anyOf(systemCodes, (s, game) => s.codeEqualTo(game.systemCode))
            .findAllSync());
  }

  Stream<List<Game>> getFavoritedGames() {
    return _isar.games
        .filter()
        .isFavoriteEqualTo(true)
        .watch(fireImmediately: true);
  }

  Stream<List<Game>> getWishlistedGames() {
    return _isar.games
        .filter()
        .isWishlistEqualTo(true)
        .watch(fireImmediately: true);
  }

  Stream<List<Game>> getRecentGames() {
    return _isar.games
        .filter()
        .timeLastPlayedIsNotNull()
        .sortByTimeLastPlayedDesc()
        .limit(100)
        .watch(fireImmediately: true);
  }

  Stream<List<Game>> getNewlyAddedGames() {
    final pastRecentDays =
        DateTime.now().subtract(const Duration(days: daysConsideredRecent));
    return _isar.games
        .filter()
        .timeAddedGreaterThan(pastRecentDays)
        .sortByTimeAddedDesc()
        .limit(100)
        .watch(fireImmediately: true);
  }

  Stream<List<Game>> getPinnedGames() {
    return _isar.games
        .filter()
        .pinIndexIsNotNull()
        .sortByPinIndexDesc()
        .limit(10)
        .watch(fireImmediately: true);
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

  Stream<List<App>> getPinnedApps() {
    return _isar.apps.where().anyId().watch(fireImmediately: true);
  }

  Future<bool> togglePinApp(App app) async {
    return await _isar.writeTxn(() async {
      if (await _isar.apps
          .where()
          .packageNameEqualTo(app.packageName)
          .isEmpty()) {
        await _isar.apps.putByPackageName(app);
        return true;
      } else {
        await _isar.apps.deleteByPackageName(app.packageName);
        return false;
      }
    });
  }
}
