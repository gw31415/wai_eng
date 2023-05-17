import 'package:flutter/material.dart';
import '../modules/flashcardbook.dart';

class OpenCloseCard extends StatefulWidget {
  final Widget question;
  final Widget answer;
  const OpenCloseCard({Key? key, required this.question, required this.answer})
      : super(key: key);

  @override
  State<OpenCloseCard> createState() => _OpenCloseCardState();
}

class _OpenCloseCardState extends State<OpenCloseCard> {
  var ontap = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (details) {
        setState(() {
          ontap = true;
        });
      },
      onPointerUp: (details) {
        setState(() {
          ontap = false;
        });
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Stack(children: [
            Center(
              child: Opacity(opacity: ontap ? 0 : 1, child: widget.question),
            ),
            Center(
              child: Opacity(opacity: ontap ? 1 : 0, child: widget.answer),
            ),
          ]),
        ),
      ),
    );
  }
}

class BookTableScaffold extends StatelessWidget {
  final ListableBook book;
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
          final cards = await book.intoCardList();
          return ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              if (index + 1 > cards.length) {
                return null;
              } else {
                return OpenCloseCard(
                  question: cards[index].questionAlt,
                  answer: cards[index].answerAlt,
                );
              }
            },
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
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }
          final view = snapshot.data as ListView;
          return view;
        })));
  }
}
