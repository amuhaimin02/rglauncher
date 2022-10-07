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

  factory System.fromMap(Map<String, dynamic> map) {
    return System(
      name: map['name'],
      code: map['code'],
      producer: map['producer'],
      imageLink: map['image'],
      folderNames: (map['folders'] as List).cast<String>(),
      supportedExtensions: (map['extensions'] as List).cast<String>(),
    );
  }
  @override
  String toString() => 'System: $code';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is System && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
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

  factory Emulator.fromMap(Map<String, dynamic> map) {
    return Emulator(
      name: map['name'],
      code: map['code'],
      executable: map['executable'],
      forSystem: map['for'],
      libretroPath: map['libretro'],
    );
  }

  @override
  String toString() => 'Emulator: $code';

  bool get isRetroarch => libretroPath != null;

  String get androidPackageName =>
      executable.substring(0, executable.indexOf('/'));

  String get androidComponentName =>
      executable.substring(executable.indexOf('/') + 1);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Emulator &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

class GameEntry {
  final String name;
  final String filepath;
  final System system;

  const GameEntry({
    required this.name,
    required this.filepath,
    required this.system,
  });
}
