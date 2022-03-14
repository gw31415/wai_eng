import 'package:flutter/material.dart';
import 'swipable_stack/swipable_stack.dart';

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
      home: const PlayingCardsPage(flashcards: _flashCardsDebug),
    );
  }
}

class FlashCard {
  final String question;
  final String answer;
  const FlashCard({required this.question, required this.answer});
}

class FlashCards {
  final List<FlashCard> body;
  final String title;
  const FlashCards({required this.title, required this.body});
  int length() {
    return body.length;
  }

  FlashCard? get(int i) {
    if (length() - 1 < i) {
      return null;
    }
    return body[i];
  }
}

const _flashCardsDebug = FlashCards(title: "デバッグ", body: [
  FlashCard(question: "問題1", answer: "答え1"),
  FlashCard(question: "問題2", answer: "答え2"),
  FlashCard(question: "問題3", answer: "答え3"),
  FlashCard(question: "問題4", answer: "答え4"),
  FlashCard(question: "問題5", answer: "答え5"),
]);

class PlayingCardsPage extends StatefulWidget {
  const PlayingCardsPage({Key? key, required this.flashcards})
      : super(key: key);
  final FlashCards flashcards;
  @override
  State<PlayingCardsPage> createState() => _PlayingCardsPageState();
}

class _PlayingCardsPageState extends State<PlayingCardsPage> {
  late final SwipableStackController _controller;
  void _listenController() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _controller = SwipableStackController()..addListener(_listenController);
  }

  @override
  void dispose() {
    super.dispose();
    _controller
      ..removeListener(_listenController)
      ..dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.flashcards.title),
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 8),
          child: SwipableStack(
            itemCount: widget.flashcards.length(),
            detectableSwipeDirections: const {
              SwipeDirection.right,
              SwipeDirection.left,
            },
            overlayBuilder: (_, properties) {
              final card = widget.flashcards.get(properties.index);
              if (card == null) {
                return Container();
              }
              return Card(child: Center(child: Text(card.answer)));
            },
            stackClipBehaviour: Clip.none,
            builder: (context, properties) {
              final card = widget.flashcards.get(properties.index);
              if (card == null) {
                return Container();
              }
              return Card(child: Center(child: Text(card.question)));
            },
            onSwipeCompleted: (i, direction) {
              switch (direction) {
                case SwipeDirection.down:
                  break;
                default:
              }
            },
          ),
        )));
  }
}
