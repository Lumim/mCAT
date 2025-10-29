import 'package:flutter/material.dart';
// Ensure the package is added in pubspec.yaml and run flutter pub get
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

  @override
  Widget build(BuildContext context) {
    final tasks = [
      McatTask(id: 'face', title: 'Face Task'),
      McatTask(id: 'word', title: 'Word Task'),
    ];

    return MaterialApp(
      title: 'mCAT',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),

      // ✅ Define home inside MaterialApp instead of using a route that depends on outer context
      home: Builder(
        builder: (navContext) => IntroScreen(
          tasks: tasks,
          onStart: () {
            Navigator.of(navContext).pushNamed(AppRoutes.faceIntro);
          },
        ),
      ),

      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.faceIntro:
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
                  FaceItem('assets/images/face_1.png', Emotion.happy),
                  FaceItem('assets/images/face_2.png', Emotion.sad),
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
                onNext: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
              ),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Unknown route')),
              ),
            );
        }
      },
    );
  }
}
