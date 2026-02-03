import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import './study/study_word_task_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(); // now uses google-services.json

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Study',
      debugShowCheckedModeBanner: false,
      home: const StudyWordTaskScreen(),
    );
  }
}
