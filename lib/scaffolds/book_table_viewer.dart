import 'package:flutter/material.dart';
import '../modules/flashcardbook.dart';

class BookTableScaffold extends StatelessWidget {
  final UsersBook book;
  final Text title;
  const BookTableScaffold({Key? key, required this.book, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: title,
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
              return Center(
                child: Text("${snapshot.error}"),
              );
            }
            return Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).splashColor.withAlpha(153)),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          final dataTable = snapshot.data as DataTable;
          return SingleChildScrollView(
              child: Center(child: FittedBox(child: dataTable)));
        })));
  }
}
