import 'package:flutter/material.dart';
import '../modules/flashcard.dart';
import './book_player.dart';

class _FlashCardsListView extends StatelessWidget {
  final List<FlashCardBook> flashcards;
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
                return FlashCardBookPlayerScaffold(
                  book: cards,
                );
              }));
            },
          );
        });
  }
}

class FlashCardsMenuScaffold extends StatelessWidget {
  final List<FlashCardBook> flashcards;
  const FlashCardsMenuScaffold({Key? key, required this.flashcards})
      : super(key: key);
  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: _FlashCardsListView(flashcards: flashcards),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(height: 50.0),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
