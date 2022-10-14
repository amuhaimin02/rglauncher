import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:rglauncher/features/media_manager.dart';
import 'package:rglauncher/utils/cleanup_filename.dart';

import '../data/models.dart';

abstract class MediaScraper {
  FutureOr<GameMetadataWithImages?> find(Game game, MediaManager manager);
}

class DummyScraper extends MediaScraper {
  @override
  FutureOr<GameMetadataWithImages?> find(
      Game game, MediaManager manager) async {
    final imageLink = 'https://picsum.photos/320/320?r=${game.name}';

    final imageBytes = await manager.downloadImage(imageLink);
    return GameMetadataWithImages(
      metadata: GameMetadata()
        ..title = 'Game 1'
        ..description = 'A great game fun to play for everyone'
        ..genre = 'Arcade',
      boxArtImage: imageBytes,
    );
  }
}

class ScreenScraperMediaScraper extends MediaScraper {
  ScreenScraperMediaScraper({this.devId, this.devPassword});

  final String? devId;
  final String? devPassword;

  @override
  FutureOr<GameMetadataWithImages?> find(
      Game game, MediaManager manager) async {
    final response = await http.get(
      Uri.parse('https://screenscraper.fr/api2/jeuInfos.php').replace(
        queryParameters: {
          'devid': devId,
          'devpassword': devPassword,
          'romnom': cleanupRomFileName(game.filename),
          'output': 'json'
        },
      ),
    );
    if (response.statusCode != 200) {
      return null;
    }
    final json = jsonDecode(response.body);
    final jsonGame = json['response']?['jeu'];
    final meta = GameMetadata();

    meta.title = (jsonGame?['noms'] as List?)
            ?.firstWhereOrNull((e) => e['region'] == 'ss')?['text'] ??
        '';
    meta.description = (jsonGame?['synopsis'] as List?)
            ?.firstWhereOrNull((e) => e['langue'] == 'en')?['text'] ??
        '';
    meta.genre = (jsonGame?['genres'] as List?)
            ?.map((e) => (e['noms'] as List?)
                ?.firstWhereOrNull((n) => n['langue'] == 'en')?['text'])
            .join(',') ??
        '';

    final boxArtImageLinks =
        (jsonGame?['medias'] as List?)?.where((n) => n['type'] == 'box-2D') ??
            [];

    final boxArts = {for (var b in boxArtImageLinks) b['region']: b['url']};

    final boxArtImageLink = boxArts['us'] ??
        boxArts['eu'] ??
        boxArts['jp'] ??
        boxArts.values.firstOrNull;

    final boxArtImageBytes = boxArtImageLink != null
        ? (await http.get(Uri.parse(boxArtImageLink))).bodyBytes
        : null;

    final screenshotImageLink = (jsonGame?['medias'] as List?)
        ?.firstWhereOrNull((n) => n['type'] == 'ss')?['url'];

    final screenshotImageBytes = screenshotImageLink != null
        ? (await http.get(Uri.parse(screenshotImageLink))).bodyBytes
        : null;

    return GameMetadataWithImages(
      metadata: meta,
      boxArtImage: boxArtImageBytes,
      screenshotImage: screenshotImageBytes,
    );
  }
}
