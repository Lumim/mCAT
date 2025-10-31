import 'package:flutter/material.dart';
import 'package:mcat_package/mcat_package.dart';
import './route.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const McatApp());
}

class McatApp extends StatefulWidget {
  const McatApp({super.key});
  @override
  State<McatApp> createState() => _McatAppState();
}

class _McatAppState extends State<McatApp> {
  int _lastScore = 0;
  int _lastTotal = 0;

  // ✅ Word list for Word Task
  final List<String> wordList = const [
    'mountains',
    'city',
    'snowman',
    'coffee',
    'airport',
    'book',
    'cartoon',
    'sky',
    'garden',
    'house',
    'sky',
  ];

  @override
  Widget build(BuildContext context) {
    final tasks = [
      McatTask(id: 'face', title: 'Face Task'),
      McatTask(id: 'word', title: 'Word Task'),
    ];

    return MaterialApp(
      title: 'mCAT',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),

      // ✅ Safe Builder context under MaterialApp
      home: Builder(
        builder: (navContext) => IntroScreen(
          tasks: tasks,
          onStart: () {
            Navigator.of(navContext).pushNamed(AppRoutes.wordAssessment);
          },
        ),
      ),

      onGenerateRoute: (settings) {
        switch (settings.name) {
          // 🧠 ---------------- FACE TASK FLOW ----------------
         /*  case AppRoutes.faceIntro:
            return MaterialPageRoute(
              builder: (context) => FaceTaskIntroScreen(
                onNext: () {
                  Navigator.of(context).pushNamed(AppRoutes.facePractice);
                },
              ),
            );

          case AppRoutes.facePractice:
            return MaterialPageRoute(
              builder: (context) => FaceTaskPracticeScreen(
                practiceImageAssets: const [
                  'assets/images/face_1.png',
                  'assets/images/face_2.png',
                ],
                onPracticeDone: () {
                  Navigator.of(context).pushNamed(AppRoutes.faceAssessment);
                },
              ),
            );

          case AppRoutes.faceAssessment:
            return MaterialPageRoute(
              builder: (context) => FaceTaskAssessmentScreen(
                items: [
                  FaceItem('assets/images/face_1.png', Emotion.neutral),
                  FaceItem('assets/images/face_2.png', Emotion.happy),
                ],
                onFinished: (score, total) {
                  _lastScore = score;
                  _lastTotal = total;
                  Navigator.of(context).pushNamed(AppRoutes.faceResult);
                },
              ),
            );

          case AppRoutes.faceResult:
            return MaterialPageRoute(
              builder: (context) => FaceTaskResultScreen(
                score: _lastScore,
                total: _lastTotal,
                // ✅ Automatically go to Word Task Intro after “Next”
                onNext: () {
                  Navigator.of(context).pushNamed(AppRoutes.wordIntro);
                },
              ),
            );

          // 🗣 ---------------- WORD TASK FLOW ----------------
          case AppRoutes.wordIntro:
            return MaterialPageRoute(
              builder: (context) => WordTaskIntroScreen(
                onNext: () {
                  Navigator.of(context).pushNamed(AppRoutes.wordPractice);
                },
              ),
            );

          case AppRoutes.wordPractice:
            return MaterialPageRoute(
              builder: (context) => WordTaskPracticeScreen(
                words: ['coffee', 'book', 'sky'],
                onFinished: (score, total) {
                  Navigator.of(context).pushNamed(AppRoutes.wordAssessment);
                },
              ),
            );
 */
          case AppRoutes.wordAssessment:
            return MaterialPageRoute(
              builder: (context) => WordTaskAssessmentScreen(
                words: wordList,
                onFinished: (score, total) {
                  _lastScore = score;
                  _lastTotal = total;
                  Navigator.of(context).pushNamed(AppRoutes.wordResult);
                },
              ),
            );

          case AppRoutes.wordResult:
            return MaterialPageRoute(
              builder: (context) => WordTaskResultScreen(
                score: _lastScore,
                total: _lastTotal,
                onNext: () {
                  // ✅ Go back to the start or show a summary later
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
              ),
            );

          // 🚨 Unknown route fallback
          default:
            return MaterialPageRoute(
              builder: (_) =>
                  const Scaffold(body: Center(child: Text('Unknown route'))),
            );
        }
      },
    );
  }
}
