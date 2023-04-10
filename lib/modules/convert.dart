import 'package:csv/csv.dart';
import "./flashcard.dart";

List<FlashCard> cardFromCsv(String csv) {
  final list = const CsvToListConverter().convert(csv).map((line) {
    if (line.length < 2) {
      throw Exception("There are not enough columns in the CSV.");
    }
    return StringCard(question: line[0] as String, answer: line[1] as String);
  }).toList();
  if (list.length <= 1) {
    throw Exception("There are not enough rows in the CSV.");
  }
  return list;
}
