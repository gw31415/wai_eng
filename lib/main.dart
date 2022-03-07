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
      home: const Menu(title: 'ホーム'),
    );
  }
}

class Menu extends StatefulWidget {
  const Menu({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: FlashCard(question:"問題", answer: "答え"),
      ),
    );
  }
}

class FlashCard extends StatefulWidget {

  final String question;
  final String answer;
  const FlashCard({this.question = "", this.answer = ""});
  @override
  State<FlashCard> createState() => _FlashCardState();
}

class _FlashCardState extends State<FlashCard> {
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
      child:Card(
      	child: SizedBox(
      	  width: 330,
      	  height: 150,
      	  child: Center(child: Text(
      		isSurface ?
      		  widget.question :
      		  widget.answer
      	  )),
      	),
     )
	);
  }
}
