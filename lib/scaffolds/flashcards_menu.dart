import 'package:flutter/material.dart';
import '../modules/flashcard.dart';
import './playing_cards.dart';

class _FlashCardsListView extends StatelessWidget {
  final List<FlashCards> flashcards;
  const _FlashCardsListView({Key? key, required this.flashcards})
      : super(key: key);
  @override
  Widget build(context) {
    return ListView.builder(
        itemCount: flashcards.length,
        itemBuilder: (context, index) {
          final cards = flashcards[index];
          return ListTile(
            title: Text(cards.title),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PlayingCardsScaffold(
                  flashcards: cards,
                );
              }));
            },
          );
        });
  }
}

class FlashCardsMenuScaffold extends StatelessWidget {
  final List<FlashCards> flashcards;
  const FlashCardsMenuScaffold({Key? key, required this.flashcards})
      : super(key: key);
  @override
  Widget build(context) {
    return Scaffold(body: _FlashCardsListView(flashcards: flashcards));
  }
}
