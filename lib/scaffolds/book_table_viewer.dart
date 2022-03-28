import 'package:flutter/material.dart';
import '../modules/flashcard.dart';

class BookTableScaffold extends StatelessWidget {
  final FlashCardBookWithBody book;
  const BookTableScaffold({Key? key, required this.book})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(book.title),
        ),
        body: SafeArea(
            child: FutureBuilder(
                future: book.body,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("Unknown error occurred."),
                      );
                    }
                    return const Center(
                      child: Text("Loading..."),
                    );
                  }
                  final cards = snapshot.data as List<FlashCard>;
                  return DataTable(
                    columns: const [
                      DataColumn(
                        label: Text(
                          '問題',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text('答え'),
                      ),
                    ],
                    rows: cards.map((card) {
                      return DataRow(
                        cells: [
                          DataCell(card.questionAlt),
                          DataCell(card.answerAlt)
                        ],
                      );
                    }).toList(),
                  );
                })));
  }
}
