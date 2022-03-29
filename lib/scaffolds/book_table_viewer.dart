import 'package:flutter/material.dart';
import '../modules/flashcard.dart';

class BookTableScaffold extends StatelessWidget {
  final UsersBook book;
  const BookTableScaffold({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(book.title),
        ),
        body: SafeArea(
            child: FutureBuilder(future: Future.microtask(() async {
          final cards = await book.body;
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
                label: Text(
                  '答え',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            rows: cards.map((card) {
              return DataRow(
                cells: [DataCell(card.questionAlt), DataCell(card.answerAlt)],
              );
            }).toList(),
          );
        }), builder: (context, snapshot) {
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
          final dataTable = snapshot.data as DataTable;
          return SingleChildScrollView(child: Center(child: FittedBox(child: dataTable)));
        })));
  }
}
