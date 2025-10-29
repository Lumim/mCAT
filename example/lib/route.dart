import 'package:flutter/material.dart';


class AppRoutes {
static const intro = '/';
static const faceIntro = '/face/intro';
static const facePractice = '/face/practice';
static const faceAssessment = '/face/assessment';
static const faceResult = '/face/result';
}


class RouteArgs {
final Map<String, Object?> data;
const RouteArgs(this.data);
}


Route<dynamic> unknownRoute(RouteSettings s) => MaterialPageRoute(
builder: (_) => Scaffold(body: Center(child: Text('Unknown route: ${s.name}'))),
);