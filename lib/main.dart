import 'package:flutter/material.dart';
import 'scaffolds/flashcards_menu.dart';
import 'modules/flashcard.dart';

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
      home: const FlashCardsMenuScaffold(flashcards: [_flashCardsDebug]),
    );
  }
}

const _flashCardsDebug = FlashCards(title: "デバッグ", body: [
  FlashCard(question: Text("問題1"), answer: Text("答え1")),
  FlashCard(question: Text("問題2"), answer: Text("答え2")),
  FlashCard(question: Text("問題3"), answer: Text("答え3")),
  FlashCard(question: Text("問題4"), answer: Text("答え4")),
  FlashCard(question: Text("問題5"), answer: Text("答え5")),
]);
