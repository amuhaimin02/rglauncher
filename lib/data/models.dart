import 'package:objectbox/objectbox.dart';
import 'package:rglauncher/data/typedefs.dart';

import '../objectbox.g.dart';

@Entity()
class System {
  int id;
  String name;
  String code;
  String producer;
  String imageLink;
  List<String> folderNames;
  List<String> supportedExtensions;

  System({
    this.id = 0,
    required this.name,
    required this.code,
    required this.producer,
    required this.imageLink,
    required this.folderNames,
    required this.supportedExtensions,
  });

  @override
  String toString() => 'System: $code';

  @Backlink('system')
  final games = ToMany<Game>();

  @Backlink('system')
  final emulators = ToMany<Emulator>();

  JsonMap toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'producer': producer,
      'image': imageLink,
      'folders': folderNames,
      'extensions': supportedExtensions,
    };
  }

  factory System.fromMap(JsonMap map) {
    return System(
      id: (map['id'] ?? 0) as int,
      name: map['name'] as String,
      code: map['code'] as String,
      producer: map['producer'] as String,
      imageLink: map['image'] as String,
      folderNames: (map['folders'] as List).cast<String>(),
      supportedExtensions: (map['extensions'] as List).cast<String>(),
    );
  }
}

@Entity()
class Emulator {
  int id;
  String name;
  String code;
  String executable;
  String forSystem;
  String? libretroPath;

  Emulator({
    this.id = 0,
    required this.name,
    required this.code,
    required this.executable,
    required this.forSystem,
    this.libretroPath,
  });

  final system = ToOne<System>();

  @override
  String toString() => 'Emulator: $code';

  bool get isRetroarch => libretroPath != null;

  String get androidPackageName =>
      executable.substring(0, executable.indexOf('/'));

  String get androidComponentName =>
      executable.substring(executable.indexOf('/') + 1);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'executable': executable,
      'for': forSystem,
      'libretro': libretroPath,
    };
  }

  factory Emulator.fromMap(Map<String, dynamic> map) {
    return Emulator(
      id: (map['id'] ?? 0) as int,
      name: map['name'] as String,
      code: map['code'] as String,
      executable: map['executable'] as String,
      forSystem: map['for'] as String,
      libretroPath: map['libretro'] as String?,
    );
  }
}

@Entity()
class Game {
  int id;
  String name;
  String filepath;

  Game({
    this.id = 0,
    required this.name,
    required this.filepath,
  });

  final system = ToOne<System>();
}
