import '../data/database.dart';
import '../data/models.dart';

abstract class Scraper {
  String getBoxArtImageLink(Game game);
}

class DummyScraper extends Scraper {
  @override
  String getBoxArtImageLink(Game game) {
    return 'https://picsum.photos/320/320?r=${game.name}';
  }
}
