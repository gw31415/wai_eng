import 'package:flutter/material.dart';
import '../modules/swipable_stack/swipable_stack.dart';
import '../modules/flashcardbook.dart';

class FlashCardBookPlayerScaffold extends StatefulWidget {
  const FlashCardBookPlayerScaffold(
      {Key? key, required this.book, required this.title})
      : super(key: key);
  final FlashCardBook book;
  final Text title;
  @override
  State<FlashCardBookPlayerScaffold> createState() =>
      _FlashCardBookPlayerScaffoldState();
}

class _FlashCardBookPlayerScaffoldState
    extends State<FlashCardBookPlayerScaffold> {
  late SwipableStackController _controller;
  late Future<FlashCardBookOperator> _opFuture;
  late bool nextCardAvailable;
  double Function()? progressbar = null;

  void _listenController() {
    setState(() {});
  }

  // Cardの初期化処理: initStateやリプレイボタンを押下したら発火
  void _initCards() {
    setState(() {
      _controller = SwipableStackController()..addListener(_listenController);
      _opFuture = widget.book.init();
      nextCardAvailable = true;
    });
  }

  // Stateの初期化
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
          title: widget.title,
          bottom: progressbar == null
              ? null
              : PreferredSize(
                  child: LinearProgressIndicator(value: progressbar?.call()),
                  preferredSize: const Size.fromHeight(8)),
        ),
        body: SafeArea(
          child: FutureBuilder(
              // カードを読みこむ
              future: _opFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("${snapshot.error}"),
                    );
                  }
                  return Container(
                    decoration:
                        BoxDecoration(color: Theme.of(context).splashColor),
                    child: const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  );
                }
                final bookop = snapshot.data as FlashCardBookOperator;
                progressbar = () {
                  if (bookop.length == null || bookop.progress == null) {
                    return 0;
                  }
                  return bookop.progress!.toDouble() /
                      bookop.length!.toDouble();
                };
                return Stack(
                  children: [
                    Align(
                      // StatusRow
                      alignment: Alignment.bottomCenter,
                      child: Text("${bookop.progress} / ${bookop.length}"),
                    ),
                    AnimatedSwitcher(
                      // リプレイボタンとの切りかえ
                      duration: const Duration(milliseconds: 100),
                      child: bookop.isForceFinished || !nextCardAvailable
                          ? Center(
                              // リプレイボタン
                              child: IconButton(
                              iconSize: 50,
                              tooltip: "Replay",
                              icon: const Icon(Icons.replay),
                              onPressed: () {
                                _initCards();
                              },
                            ))
                          : Stack(
                              // FlashCard & アンドゥボタン表示部
                              children: [
                                  Padding(
                                      // FlashCard
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
                                        swipeNextOnSwipeCanceled:
                                            const SwipeNextArgs(
                                          swipeDirection: SwipeDirection.down,
                                          shouldCallCompletionCallback: true,
                                          ignoreOnWillMoveNext: false,
                                          duration: Duration(milliseconds: 200),
                                        ),
                                        onWillMoveNext: (_, __) {
                                          ScaffoldMessenger.of(context)
                                              .clearSnackBars();
                                          return true;
                                        },
                                        overlayBuilder: (_, properties) {
                                          final card =
                                              bookop.get(properties.index);
                                          if (card == null) {
                                            return Container();
                                          }
                                          return Card(
                                              child:
                                                  Center(child: card.answer));
                                        },
                                        stackClipBehaviour: Clip.none,
                                        builder: (context, properties) {
                                          final card =
                                              bookop.get(properties.index);
                                          if (card == null) {
                                            return Container();
                                          }
                                          return Card(
                                              child:
                                                  Center(child: card.question));
                                        },
                                        onSwipeCompleted: (index, direction) {
                                          switch (direction) {
                                            case SwipeDirection.down:
                                              bookop.onNext(index,
                                                  FlashCardResult.skipped);
                                              _showSnackBar(context, "SKIPPED",
                                                  Colors.grey);
                                              break;
                                            default:
                                              bookop.onNext(
                                                  index, FlashCardResult.ok);
                                              _showSnackBar(
                                                  context, "OK", Colors.green);
                                          }
                                          nextCardAvailable =
                                              bookop.get(index + 1) != null;
                                        },
                                      )),
                                  Align(
                                    // アンドゥボタン
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
                                ]),
                    ),
                  ],
                );
              }),
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
