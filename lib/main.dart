import 'package:flutter/material.dart';
import 'scaffolds/playing_cards.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '和医大 英単語',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const PlayingCardsScaffold(flashcards: _flashCardsDebug),
    );
  }
}

const _flashCardsDebug = FlashCards(title: "デバッグ", body: [
  FlashCard(question: "問題1", answer: "答え1"),
  FlashCard(question: "問題2", answer: "答え2"),
  FlashCard(question: "問題3", answer: "答え3"),
  FlashCard(question: "問題4", answer: "答え4"),
  FlashCard(question: "問題5", answer: "答え5"),
]);
