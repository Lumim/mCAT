import 'package:flutter/material.dart';
import '../routes.dart';

void main() {
  runApp(const MCATStudyApp());
}

class MCATStudyApp extends StatelessWidget {
  const MCATStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCAT Study',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.studyIntro,
      routes: AppRoutes.routes,
    );
  }
}
