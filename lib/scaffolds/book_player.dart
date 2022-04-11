import 'package:flutter/material.dart';
import '../modules/swipable_stack/swipable_stack.dart';
import '../modules/flashcard.dart';

class FlashCardBookPlayerScaffold extends StatefulWidget {
  const FlashCardBookPlayerScaffold({Key? key, required this.book})
      : super(key: key);
  final FlashCardBook book;
  @override
  State<FlashCardBookPlayerScaffold> createState() =>
      _FlashCardBookPlayerScaffoldState();
}

class _FlashCardBookPlayerScaffoldState
    extends State<FlashCardBookPlayerScaffold> {
  late SwipableStackController _controller;
  late Future<FlashCardBookOperator> _opFuture;
  void _listenController() {
    setState(() {});
  }

  void _initCards() {
    setState(() {
      _controller = SwipableStackController()..addListener(_listenController);
      _opFuture = widget.book.init();
    });
  }

  @override
  void initState() {
    super.initState();
    _initCards();
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
          child: Stack(
            children: [
              Center(
                  child: IconButton(
                iconSize: 50,
                tooltip: "Play again",
                icon: const Icon(Icons.replay),
                onPressed: () {
                  _initCards();
                },
              )),
              FutureBuilder(
                  future: _opFuture,
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
                    final bookop = snapshot.data as FlashCardBookOperator;
                    return Stack(children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 100, horizontal: 8),
                          child: SwipableStack(
                            controller: _controller,
                            swipeAnchor: SwipeAnchor.top,
                            swipeAssistDuration:
                                const Duration(milliseconds: 100),
                            detectableSwipeDirections: const {
                              SwipeDirection.right,
                              SwipeDirection.left,
                            },
                            swipeNextOnSwipeCanceled: const SwipeNextArgs(
                              swipeDirection: SwipeDirection.down,
                              shouldCallCompletionCallback: true,
                              ignoreOnWillMoveNext: false,
                              duration: Duration(milliseconds: 200),
                            ),
                            onWillMoveNext: (_, __) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              return true;
                            },
                            overlayBuilder: (_, properties) {
                              final card = bookop.get(properties.index);
                              if (card == null) {
                                return Container();
                              }
                              return Card(child: Center(child: card.answer));
                            },
                            stackClipBehaviour: Clip.none,
                            builder: (context, properties) {
                              final card = bookop.get(properties.index);
                              if (card == null) {
                                return Container();
                              }
                              return Card(child: Center(child: card.question));
                            },
                            onSwipeCompleted: (index, direction) {
                              switch (direction) {
                                case SwipeDirection.down:
                                  bookop.onNext(index, FlashCardResult.skipped);
                                  _showSnackBar(
                                      context, "SKIPPED", Colors.grey);
                                  break;
                                default:
                                  bookop.onNext(index, FlashCardResult.ok);
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
                              onPressed: _controller.canRewind
                                  ? () {
                                      bookop.onUndo();
                                      _controller.rewind();
                                    }
                                  : null,
                              tooltip: "Undo",
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: bookop.statusRow,
                        ),
                      )
                    ]);
                  }),
            ],
          ),
        ));
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
