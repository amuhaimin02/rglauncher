import 'dart:typed_data';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as path;
import 'package:string_similarity/string_similarity.dart';

part 'models.g.dart';

@collection
class System {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String code;

  @Index()
  late String name;

  late String producer;

  late String thumbnailLink;

  late List<String> folderNames;

  late List<String> extensions;

  @override
  String toString() => 'System: $code';
}

@collection
class Emulator {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String code;

  @Index()
  late String name;

  late String executable;

  late String? libretroPath;

  @Index()
  late String systemCode;

  @override
  String toString() => 'Emulator: $code';

  @ignore
  bool get isRetroarch => libretroPath != null;

  @ignore
  String get androidPackageName =>
      executable.substring(0, executable.indexOf('/'));

  @ignore
  String get androidComponentName =>
      executable.substring(executable.indexOf('/') + 1);
}

final fileExtensionRegex = RegExp(r'\.[\w]+$');
final numbersInFrontRegex = RegExp(r'^\d+\s-\s');
final inParenthesesRegex = RegExp(r'(\(([^)]+)\))|(\[([^]]+)\])');

@collection
class Game {
  Id id = Isar.autoIncrement;

  @Index()
  late String name;

  @Index()
  late String filename;

  late String filepath;

  @Index()
  late String systemCode;

  bool isFavorite = false;

  bool isWishlist = false;

  DateTime timeAdded = DateTime.now();

  @Index()
  DateTime? timeLastPlayed;

  @Index()
  int? pinIndex;

  @ignore
  bool get isPinned => pinIndex != null;

  @ignore
  String get metadataKey => '$systemCode:$filename';

  @ignore
  String get fileNameNoExtension => filename.replaceAll(fileExtensionRegex, '');

  @ignore
  double get filenameCorrectness =>
      StringSimilarity.compareTwoStrings(name, cleanedUpFilename);

  @Index(unique: true, replace: true)
  String get fullpath => path.join(filepath, filename);

  @override
  String toString() => 'Game: $name';

  @ignore
  String get cleanedUpFilename {
    String newName = filename;
    newName = newName.replaceAll('_', ' ');
    newName = newName.replaceAll(fileExtensionRegex, '');
    newName = newName.replaceAll(numbersInFrontRegex, '');
    newName = newName.replaceAll(inParenthesesRegex, '');
    print('New name: $newName');
    return newName;
  }
}

@collection
class GameMetadata {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String key;

  late String title;

  late String description;

  List<String>? genres;

  DateTime? releaseDate;
}

class GameMetadataWithImages {
  final GameMetadata metadata;
  final Uint8List? boxArtImage;
  final Uint8List? screenshotImage;

  const GameMetadataWithImages({
    required this.metadata,
    this.boxArtImage,
    this.screenshotImage,
  });
}

@collection
class App {
  Id id = Isar.autoIncrement;

  late String name;

  @Index(unique: true, replace: true)
  late String packageName;
}
