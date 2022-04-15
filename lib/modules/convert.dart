import "./flashcard.dart";

List<FlashCard> cardFromCsv(String csv) {
  List<StringCard> cards = [];
  for (var rowString in csv.split('\n')) {
    final row = rowString.split(',');
    switch (row.length) {
      case 0:
        break;
      case 1:
        if (row[0] != "") {
          cards.add(StringCard(question: row[0], answer: ""));
        }
        break;
      default:
        if (row[0] != "" && row[1] != "") {
          cards.add(StringCard(question: row[0], answer: row[1]));
        }
        break;
    }
  }
  return cards;
}
