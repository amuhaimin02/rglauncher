// import 'dart:convert';
// import 'dart:io';
//
// import 'package:csv/csv.dart';
//
// class CsvStorage {
//   const CsvStorage();
//
//   Future<List<T>> loadCsvFromFile<T>(
//       File file, T Function(List<Object?> line) transform) async {
//     final input = file.openRead();
//     final fields = await input
//         .transform(utf8.decoder)
//         .transform(const CsvToListConverter())
//         .toList();
//     return fields.map((e) => transform(e)).toList();
//   }
//
//   Future<void> saveCsvToFile<T>(
//     File file,
//     List<T> list,
//     List<Object> Function(T item) transform,
//   ) async {
//     final csv = const ListToCsvConverter()
//         .convert(list.map((e) => transform(e)).toList());
//     if (!file.existsSync()) {
//       file.createSync(recursive: true);
//     }
//     file.writeAsStringSync(csv);
//   }
// }
