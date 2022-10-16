import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:rglauncher/features/media_manager.dart';

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
        ..genres = ['Arcade'],
      boxArtImage: imageBytes,
    );
  }
}

class ScreenScraperMediaScraper extends MediaScraper {
  ScreenScraperMediaScraper({this.devId, this.devPassword});

  final String? devId;
  final String? devPassword;

  late final dio = Dio(BaseOptions(baseUrl: 'https://screenscraper.fr/api2'));

  static const systemIds = <String, String>{
    'NES': '3',
    'SNES': '4',
    'GB': '9',
    'GBC': '10',
    'GBA': '12',
    'NDS': '15',
    'PSP': '61',
  };

  @override
  FutureOr<GameMetadataWithImages?> find(
      Game game, MediaManager manager) async {
    try {
      final response = await dio.get(
        Uri.parse('/jeuInfos.php').replace(
          queryParameters: {
            'devid': devId,
            'devpassword': devPassword,
            'romnom': game.cleanedUpFilename,
            'output': 'json',
            'systemeid': systemIds[game.systemCode]
          },
        ).toString(),
        options: Options(responseType: ResponseType.plain),
      );
      final json = jsonDecode(response.data);
      final jsonGame = json['response']?['jeu'];
      final meta = GameMetadata();

      meta.title = (jsonGame?['noms'] as List?)
              ?.firstWhereOrNull((e) => e['region'] == 'ss')?['text'] ??
          '';
      meta.description = (jsonGame?['synopsis'] as List?)
              ?.firstWhereOrNull((e) => e['langue'] == 'en')?['text'] ??
          '';
      meta.genres = (jsonGame?['genres'] as List?)
          ?.map<String>((e) => (e['noms'] as List?)
              ?.firstWhereOrNull((n) => n['langue'] == 'en')?['text'])
          .toList();

      meta.releaseDate = (jsonGame?['dates'] as List?)
          ?.map((e) => DateTime.tryParse(e['text']) ?? DateTime.now())
          .sorted((a, b) => b.compareTo(a))
          .firstOrNull;

      final boxArtImageLinks =
          (jsonGame?['medias'] as List?)?.where((n) => n['type'] == 'box-2D') ??
              [];

      final boxArts = {for (var b in boxArtImageLinks) b['region']: b['url']};

      final boxArtImageLink = boxArts['us'] ??
          boxArts['eu'] ??
          boxArts['jp'] ??
          boxArts.values.firstOrNull;

      final boxArtImageBytes = await _downloadImage(boxArtImageLink);

      final screenshotImageLink = (jsonGame?['medias'] as List?)
          ?.firstWhereOrNull((n) => n['type'] == 'ss')?['url'];

      final screenshotImageBytes = await _downloadImage(screenshotImageLink);

      return GameMetadataWithImages(
        metadata: meta,
        boxArtImage: boxArtImageBytes,
        screenshotImage: screenshotImageBytes,
      );
    } on DioError {
      return null;
    }
  }

  Future<Uint8List?> _downloadImage(String link) async {
    final response =
        await dio.get(link, options: Options(responseType: ResponseType.bytes));
    if (response.statusCode == 200 && response.data != null) {
      return response.data;
    } else {
      return null;
    }
  }
}
