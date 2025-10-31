import 'package:flutter/material.dart';


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
}



class RouteArgs {
final Map<String, Object?> data;
const RouteArgs(this.data);
}


Route<dynamic> unknownRoute(RouteSettings s) => MaterialPageRoute(
builder: (_) => Scaffold(body: Center(child: Text('Unknown route: ${s.name}'))),
);