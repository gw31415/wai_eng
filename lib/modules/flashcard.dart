import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

final cardFontStyle = GoogleFonts.notoSansMono(
	fontSize: 20,
	);

abstract class FlashCard {
  Widget get question;
  Widget get answer;
  Text get questionAlt {
    return const Text("(表示できません)");
  }

  Text get answerAlt {
    return const Text("(表示できません)");
  }

  const FlashCard();
}

class StringCard extends FlashCard {
  @override
  Widget get question {
    return Padding(padding: const EdgeInsets.all(8), child: questionAlt);
  }

  @override
  Widget get answer {
    return Padding(padding: const EdgeInsets.all(8), child: answerAlt);
  }

  @override
  Text questionAlt;
  @override
  Text answerAlt;

  StringCard({required String question, required String answer})
      : questionAlt = Text(
          question,
          style: cardFontStyle,
	  ),
        answerAlt = Text(
			answer,
			style: cardFontStyle,
		),
        super();
}
