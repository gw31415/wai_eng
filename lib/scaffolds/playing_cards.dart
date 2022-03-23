import 'package:flutter/material.dart';
import '../modules/swipable_stack/swipable_stack.dart';
import '../modules/flashcard.dart';

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
            child: Stack(children: [
          Center(
              child: IconButton(
            iconSize: 50,
            tooltip: "Play again",
            icon: const Icon(Icons.replay),
            onPressed: () {
              _controller.currentIndex = 0;
            },
          )),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 8),
              child: SwipableStack(
                controller: _controller,
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
                  duration: Duration(milliseconds: 100),
                ),
                onWillMoveNext: (_, __) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  return true;
                },
                overlayBuilder: (_, properties) {
                  final card = widget.flashcards.get(properties.index);
                  if (card == null) {
                    return Container();
                  }
                  return Card(child: Center(child: card.answer));
                },
                stackClipBehaviour: Clip.none,
                builder: (context, properties) {
                  final card = widget.flashcards.get(properties.index);
                  if (card == null) {
                    return Container();
                  }
                  return Card(child: Center(child: card.question));
                },
                onSwipeCompleted: (i, direction) {
                  switch (direction) {
                    case SwipeDirection.down:
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(milliseconds: 500),
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          content: const SizedBox(
                            height: 48,
                            child: Center(
                              child: Text(
                                'SKIPPED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )));
                      break;
                    default:
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(milliseconds: 500),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          content: const SizedBox(
                            height: 48,
                            child: Center(
                              child: Text(
                                'OK',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )));
                  }
                },
              )),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: _controller.canRewind ? _controller.rewind : null,
                  tooltip: "Undo",
                )),
          )
        ])));
  }
}
