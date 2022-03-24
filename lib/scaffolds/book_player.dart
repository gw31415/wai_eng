import 'package:flutter/material.dart';
import '../modules/swipable_stack/swipable_stack.dart';
import '../modules/flashcard.dart';

class FlashCardBookPlayerScaffold extends StatefulWidget {
  const FlashCardBookPlayerScaffold({Key? key, required this.book}) : super(key: key);
  final FlashCardBook book;
  @override
  State<FlashCardBookPlayerScaffold> createState() => _FlashCardBookPlayerScaffoldState();
}

class _FlashCardBookPlayerScaffoldState extends State<FlashCardBookPlayerScaffold> {
  late final SwipableStackController _controller;
  void _listenController() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
	widget.book.init();
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
          title: Text(widget.book.title),
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
                  final card = widget.book.get(properties.index);
                  if (card == null) {
                    return Container();
                  }
                  return Card(child: Center(child: card.answer));
                },
                stackClipBehaviour: Clip.none,
                builder: (context, properties) {
                  final card = widget.book.get(properties.index);
                  if (card == null) {
                    return Container();
                  }
                  return Card(child: Center(child: card.question));
                },
                onSwipeCompleted: (index, direction) {
                  switch (direction) {
                    case SwipeDirection.down:
                      widget.book.onNext(index, FlashCardResult.skipped);
                      _showSnackBar(context, "SKIPPED", Colors.grey);
                      break;
                    default:
                      widget.book.onNext(index, FlashCardResult.ok);
                      _showSnackBar(context, "OK", Colors.green);
                  }
                },
              )),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: _controller.canRewind ? () {
				    widget.book.onUndo();
				    _controller.rewind();
				  }: null,
                  tooltip: "Undo",
                )),
          )
        ])));
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _showSnackBar(
        BuildContext context, String msg, Color color) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(milliseconds: 500),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        content: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              msg,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )));
