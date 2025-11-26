import 'package:flutter/material.dart';
import 'package:mcat_package/mcat_package.dart'
    show
        LnController,
        LnInstructionScreen,
        LnIntroScreen,
        LnListenScreen,
        LnPlayScreen,
        LnResultScreen;

class AppRoutes {
  // Face Task
  static const facePractice = '/face_practice';
  static const faceAssessment = '/face_assessment';
  static const faceResult = '/face_result';
  static const faceRealTask = '/face_real_task';
  static const faceIntro = '/face_intro';

  // Word Task
  static const wordIntro = '/word_intro';
  static const wordPractice = '/word_practice';
  static const wordAssessment = '/word_assessment';
  static const wordResult = '/word_result';

  // Letter–Number Task
  static const lnIntro = '/ln_intro';
  static const lnInstruction = '/ln_instruction';
  static const lnPlay = '/ln_play';
  static const lnListen = '/ln_listen';
  static const lnInput = '/ln_input';
  static const lnResult = '/ln_result';

  // Organizational Task
  static const orgIntro = '/org_intro';
  static const orgInstruction = '/org_instruction';
  static const orgPlay = '/org_play';
  static const orgInput = '/org_input';
  static const orgResult = '/org_result';

  // Word Recall Task
  static const wordRecallIntro = '/word_recall_intro';
  static const wordRecallInstruction = '/word_recall_instruction';
  static const wordRecallInput = '/word_recall_input';
  static const wordRecallResult = '/word_recall_result';

  // Coding Task
  static const codingIntro = '/coding_intro';
  static const codingPractice = '/coding_practice';
  static const codingAssessment = '/coding_assessment';
  static const codingRealText = '/coding_real_text';
  static const allIntroScreen = '/all_intro_screen';

  // Final MCAT Result
  static const finalMcatResult = '/final_mcat_result';
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
