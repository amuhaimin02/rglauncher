import 'dart:async';

import '../data/models.dart';

abstract class Scraper {
  FutureOr<String> getBoxArtImageLink(Game game);

  FutureOr<GameMetadata> getGameMetadata(Game game);
}

class DummyScraper extends Scraper {
  @override
  FutureOr<String> getBoxArtImageLink(Game game) async {
    return 'https://picsum.photos/320/320?r=${game.name}';
  }

  @override
  FutureOr<GameMetadata> getGameMetadata(Game game) async {
    return GameMetadata()
      ..title = 'Game 1'
      ..description = 'A great game fun to play for everyone'
      ..genre = 'Arcade';
  }
}
