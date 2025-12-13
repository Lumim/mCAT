import 'package:flutter/material.dart';
import '../study/study_intro_screen.dart';
import '../study/study_word_task_screen.dart';

class AppRoutes {
  static const studyIntro = '/study-intro';
  static const studyWordTask = '/study-word-task';

  static final routes = <String, WidgetBuilder>{
    studyIntro: (_) => const StudyIntroScreen(),
    studyWordTask: (_) => const StudyWordTaskScreen(),
  };
}
