import 'package:flutter/material.dart';
import 'swipable_stack/swipable_stack.dart';

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

class PlayingCardsScaffold extends StatefulWidget {
  const PlayingCardsScaffold({Key? key, required this.flashcards})
      : super(key: key);
  final FlashCards flashcards;
  @override
  State<PlayingCardsScaffold> createState() => _PlayingCardsScaffoldState();
}

class _PlayingCardsScaffoldState extends State<PlayingCardsScaffold> {
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
            swipeAnchor: SwipeAnchor.top,
            swipeAssistDuration: const Duration(milliseconds: 100),
            detectableSwipeDirections: const {
              SwipeDirection.right,
              SwipeDirection.left,
            },
            swipeNextOnSwipeCanceled: const SwipeNextArgs(
              swipeDirection: SwipeDirection.down,
              shouldCallCompletionCallback: true,
              ignoreOnWillMoveNext: false,
            ),
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
