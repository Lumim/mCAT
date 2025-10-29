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
      const McatTask(id: 'face', title: 'Face Task'),
      const McatTask(
        id: 'word',
        title: 'Word Task',
      ), // placeholders for future phases
    ];

    return MaterialApp(
      title: 'mCAT',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.intro:
            return MaterialPageRoute(
              builder: (_) => IntroScreen(
                tasks: tasks,
                onStart: () =>
                    Navigator.pushNamed(context, AppRoutes.faceIntro),
              ),
            );

          case AppRoutes.faceIntro:
            return MaterialPageRoute(
              builder: (_) => FaceTaskIntroScreen(
                onNext: () =>
                    Navigator.pushNamed(context, AppRoutes.facePractice),
              ),
            );

          case AppRoutes.facePractice:
            return MaterialPageRoute(
              builder: (_) => FaceTaskPracticeScreen(
                practiceImageAssets: const [
                  'assets/images/face_1.png',
                  'assets/images/face_2.png',
                ],
                onPracticeDone: () =>
                    Navigator.pushNamed(context, AppRoutes.faceAssessment),
              ),
            );

          case AppRoutes.faceAssessment:
            return MaterialPageRoute(
              builder: (_) => FaceTaskAssessmentScreen(
                items: [
                  FaceItem('assets/images/face_1.png', Emotion.happy),
                  FaceItem('assets/images/face_2.png', Emotion.sad),
                ],
                onFinished: (score, total) {
                  _lastScore = score;
                  _lastTotal = total;
                  Navigator.pushNamed(context, AppRoutes.faceResult);
                },
              ),
            );
          case AppRoutes.intro:
            return MaterialPageRoute(
              builder: (context) => IntroScreen(
                tasks: tasks,
                onStart: () {
                  // Use Navigator.of(context) here (same context as inside MaterialApp)
                  Navigator.of(context).pushNamed(AppRoutes.faceIntro);
                },
              ),
            );

          case AppRoutes.faceResult:
            return MaterialPageRoute(
              builder: (_) => FaceTaskResultScreen(
                score: _lastScore,
                total: _lastTotal,
                onNext: () {
                  // TODO: Navigate to next task when implemented
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
              ),
            );
        }
        return unknownRoute(settings);
      },
    );
  }
}
