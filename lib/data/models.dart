class System {
  final String name;
  final String code;
  final String description;
  final String producer;
  final String imageLink;
  final List<String> folderNames;
  final List<String> supportedExtensions;

  const System({
    required this.name,
    required this.code,
    required this.description,
    required this.producer,
    required this.imageLink,
    required this.folderNames,
    required this.supportedExtensions,
  });
}
