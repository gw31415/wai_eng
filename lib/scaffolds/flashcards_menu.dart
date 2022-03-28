import 'package:flutter/material.dart';
import '../modules/flashcard.dart';
import './book_player.dart';
import './book_table_viewer.dart';

class _FlashCardsListView extends StatelessWidget {
  final List<FlashCardBook> flashcards;
  const _FlashCardsListView({Key? key, required this.flashcards})
      : super(key: key);
  @override
  Widget build(context) {
    return ListView.builder(
        itemCount: flashcards.length,
        itemBuilder: (context, index) {
          // ダイアログの構築
          List<Widget> dialogItems = [];
          final cards = flashcards[index];
          _openBookPlayer() {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return FlashCardBookPlayerScaffold(
                book: cards,
              );
            }));
          }

          dialogItems.add(
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, _openBookPlayer),
              child: const Text('開く'),
            ),
          );
          if (cards is UsersBook) {
            _openBookTable() {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return BookTableScaffold(
                  book: cards,
                );
              }));
            }

            dialogItems.add(
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, _openBookTable),
                child: const Text('一覧'),
              ),
            );
          }

          return ListTile(
            title: Text(cards.title),
            onTap: _openBookPlayer,
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                Future.microtask(() async {
                  final nextTask = await showDialog<Function>(
                      context: context,
                      builder: (BuildContext context) {
                        return SimpleDialog(
                          title: Text(cards.title),
                          children: dialogItems,
                        );
                      });
                  if (nextTask != null) nextTask();
                });
              },
            ),
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
        title: const Text('和医大'),
      ),
      body: _FlashCardsListView(flashcards: flashcards),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(height: 50.0),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
	  */
    );
  }
}
