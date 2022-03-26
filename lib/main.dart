import 'package:flutter/material.dart';
import 'scaffolds/flashcards_menu.dart';
import 'modules/flashcard.dart';
import 'modules/books.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '和医大 英単語',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: FlashCardsMenuScaffold(flashcards: [_howToUse, _debug, histologyPreBook]),
    );
  }
}

final _howToUse = QueueBook(title: "使い方", body: [
  FlashCard.fromString(
      question: "触れてください。", answer: "Good job!\nこちらが裏面です。\n手を離すと次のカードに進みます。"),
  FlashCard.fromString(question: "こちらは表面です。", answer: "覚えたカードは左右にスワイプしましょう。"),
  FlashCard.fromString(
      question: "覚えていないカードは再び出題されるようになっています。\n（チュートリアルは戻りません）", answer: "それでは頑張ってください！"),
]);
final _debug = RandomBook(title: "デバッグ", body: [
  FlashCard.fromString(question: "問題1", answer: "答え1"),
  FlashCard.fromString(question: "問題2", answer: "答え2"),
  FlashCard.fromString(question: "問題3", answer: "答え3"),
  FlashCard.fromString(question: "問題4", answer: "答え4"),
  FlashCard.fromString(question: "問題5", answer: "答え5"),
]);
