import 'package:flutter/material.dart';
import 'package:mcat_package/mcat_package.dart'
    show
        LnIntroScreen,
        LnInstructionScreen,
        LnController,
        LnPlayScreen,
        LnListenScreen,
        LnResultScreen;

class AppRoutes {
  // Face Task
  static const faceIntro = '/face_intro';
  static const wordIntro = '/word_intro';
  static const wordPractice = '/word_practice';
  static const wordAssessment = '/word_assessment';
  static const wordResult = '/word_result';
  static const facePractice = '/face_practice';
  static const faceAssessment = '/face_assessment';
  static const faceResult = '/face_result';

  // Word Task
  /* static const wordIntro = '/word_intro';
  static const wordPractice = '/word_practice';
  static const wordAssessment = '/word_assessment';
  static const wordResult = '/word_result'; */

  static const lnIntro = '/ln-intro';
  static const lnInstruction = '/ln-instruction';
  static const lnPlay = '/ln-play';
  static const lnListen = '/ln-listen';
  static const lnInput = '/ln-input';
  static const lnResult = '/ln-result';

  static const wordRecallIntro = '/word-recall-intro';
  static const wordRecallInstruction = '/word-recall-instruction';
  static const wordRecallListen = '/word-recall-listen';
  static const wordRecallResult = '/word-recall-result';

  static const codingIntro = '/coding-intro';
  static const codingPractice = '/coding-practice';
  static const codingAssessment = '/coding-assessment';

  static const finalMcatResult = '/final-mcat-result';
}

class RouteArgs {
  final Map<String, Object?> data;
  const RouteArgs(this.data);
}

Route<dynamic> unknownRoute(RouteSettings s) => MaterialPageRoute(
  builder: (_) =>
      Scaffold(body: Center(child: Text('Unknown route: ${s.name}'))),
);

Route<dynamic> generateRoute(RouteSettings settings, LnController controller) {
  switch (settings.name) {
    case '/ln_intro':
      return MaterialPageRoute(
        builder: (_) => LnIntroScreen(controller: controller),
      );

    case '/ln_instruction':
      return MaterialPageRoute(
        builder: (_) => LnInstructionScreen(controller: controller),
      );

    case '/ln_play':
      return MaterialPageRoute(
        builder: (_) => LnPlayScreen(controller: controller),
      );

    case '/ln_listen':
      return MaterialPageRoute(
        builder: (_) => LnListenScreen(controller: controller),
      );

    case '/ln_result':
      return MaterialPageRoute(
        builder: (_) => LnResultScreen(controller: controller),
      );

    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('404 – Unknown route', style: TextStyle(fontSize: 18)),
          ),
        ),
      );
  }
}
