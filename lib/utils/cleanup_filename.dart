final fileExtensionRegex = RegExp(r'\.[\w]+$');
final numbersInFrontRegex = RegExp(r'^\d+\s-\s');

String cleanupRomFileName(String filename) {
  String newName = filename;
  newName = newName.replaceAll(fileExtensionRegex, '');
  newName = newName.replaceAll(numbersInFrontRegex, '');
  newName = newName.replaceAll('_', ' ');
  return newName;
}
