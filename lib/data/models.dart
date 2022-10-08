import 'package:rglauncher/data/typedefs.dart';

class System {
  final String name;
  final String code;
  final String producer;
  final String imageLink;
  final List<String> folderNames;
  final List<String> supportedExtensions;

  const System({
    required this.name,
    required this.code,
    required this.producer,
    required this.imageLink,
    required this.folderNames,
    required this.supportedExtensions,
  });

  @override
  String toString() => 'System: $code';

  JsonMap toMap() {
    return {
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
      name: map['name'] as String,
      code: map['code'] as String,
      producer: map['producer'] as String,
      imageLink: map['image'] as String,
      folderNames: (map['folders'] as List).cast<String>(),
      supportedExtensions: (map['extensions'] as List).cast<String>(),
    );
  }
}

class Emulator {
  final String name;
  final String code;
  final String executable;
  final String forSystem;
  final String? libretroPath;

  const Emulator({
    required this.name,
    required this.code,
    required this.executable,
    required this.forSystem,
    this.libretroPath,
  });

  @override
  String toString() => 'Emulator: $code';

  bool get isRetroarch => libretroPath != null;

  String get androidPackageName =>
      executable.substring(0, executable.indexOf('/'));

  String get androidComponentName =>
      executable.substring(executable.indexOf('/') + 1);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'executable': executable,
      'for': forSystem,
      'libretro': libretroPath,
    };
  }

  factory Emulator.fromMap(Map<String, dynamic> map) {
    return Emulator(
      name: map['name'] as String,
      code: map['code'] as String,
      executable: map['executable'] as String,
      forSystem: map['for'] as String,
      libretroPath: map['libretro'] as String?,
    );
  }
}

class Game {
  final String name;
  final String filepath;
  final System system;

  const Game({
    required this.name,
    required this.filepath,
    required this.system,
  });
}
