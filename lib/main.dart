import 'package:flutter/material.dart';

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
      home: const PlayingCardsPage(title: 'ホーム'),
    );
  }
}

class PlayingCardsPage extends StatefulWidget {
  const PlayingCardsPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<PlayingCardsPage> createState() => _PlayingCardsPageState();
}

class _PlayingCardsPageState extends State<PlayingCardsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: FlashCards(),
      ),
    );
  }
}

const double tOPwIDTH = 330;
const double tOPhEIGHT = 150;

class FlashCards extends StatefulWidget {
  const FlashCards({Key? key}) : super(key: key);
  @override
  State<FlashCards> createState() => _FlashCardsState();
}

class _FlashCardsState extends State<FlashCards> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: const [
        Align(
          alignment: Alignment(0, -0.01),
          child: SecondCard(question: "問題2"),
        ),
        Align(
          child: TopCard(answer: "答え", question: "問題"),
        ),
      ],
    );
  }
}

class SecondCard extends StatelessWidget {
  final String question;
  const SecondCard({Key? key, required this.question}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 3,
        child: SizedBox(
            width: tOPwIDTH - 10,
            height: tOPhEIGHT,
            child: Center(child: Text(question))));
  }
}

class TopCard extends StatefulWidget {
  final String question;
  final String answer;
  const TopCard({Key? key, required this.question, required this.answer})
      : super(key: key);
  @override
  State<TopCard> createState() => _TopCardState();
}

class _TopCardState extends State<TopCard> {
  bool isSurface = true;
  void toggleSurface() {
    setState(() {
      isSurface = !isSurface;
    });
  }

  void faceUp() {
    setState(() {
      isSurface = true;
    });
  }

  void faceDown() {
    setState(() {
      isSurface = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onPanEnd: (DragEndDetails? _) {
          faceUp();
        },
        onPanStart: (DragStartDetails? _) {
          faceDown();
        },
        child: Card(
          elevation: 4,
          child: SizedBox(
              width: tOPwIDTH,
              height: tOPhEIGHT,
              child: Center(
                  child: Text(isSurface ? widget.question : widget.answer))),
        ));
  }
}
