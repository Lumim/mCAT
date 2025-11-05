import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:mcat_package/mcat_package.dart';
import './route.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Hive (local storage)
  await Hive.initFlutter();

  // ✅ Initialize Firebase (cloud sync)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await DataService().init();

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
      McatTask(id: 'coding', title: 'Coding Task'),
    ];

    return MaterialApp(
      title: 'mCAT',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),

      // ✅ Safe Builder context under MaterialApp
      home: Builder(
        builder: (navContext) => IntroScreen(
          tasks: tasks,
          onStart: () {
            Navigator.of(navContext).pushNamed(AppRoutes.finalMcatResult);
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

          case AppRoutes.lnIntro:
            return MaterialPageRoute(
              builder: (context) => LnIntroScreen(
                onStart: () =>
                    Navigator.of(context).pushNamed(AppRoutes.lnInstruction),
              ),
            );

          case AppRoutes.lnInstruction:
            return MaterialPageRoute(
              builder: (context) => LnInstructionScreen(
                onNext: () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.lnPlay, arguments: _lnController),
              ),
            );

          case AppRoutes.lnPlay:
            return MaterialPageRoute(
              builder: (context) {
                final ctrl =
                    settings.arguments as LnController? ?? _lnController;
                return LnPlayScreen(
                  controller: ctrl,
                  onNext: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.lnListen, arguments: ctrl),
                );
              },
            );

          case AppRoutes.lnListen:
            return MaterialPageRoute(
              builder: (context) {
                final ctrl =
                    settings.arguments as LnController? ?? _lnController;
                return LnListenScreen(
                  controller: ctrl,
                  onDoneCounting: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.lnInput, arguments: ctrl),
                );
              },
            );

          case AppRoutes.lnInput:
            return MaterialPageRoute(
              builder: (context) {
                final ctrl =
                    settings.arguments as LnController? ?? _lnController;
                return LnInputScreen(
                  controller: ctrl,
                  onRoundFinished: () {
                    if (ctrl.isLast) {
                      Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.lnResult, arguments: ctrl);
                    } else {
                      ctrl.nextRound();
                      Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.lnPlay, arguments: ctrl);
                    }
                  },
                );
              },
            );

          case AppRoutes.lnResult:
            return MaterialPageRoute(
              builder: (context) {
                final ctrl =
                    settings.arguments as LnController? ?? _lnController;
                return LnResultScreen(
                  controller: ctrl,
                  onNext: () {
                    // e.g. go back to home or next task
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                );
              },
            );




          // 📝 ---------------- WORD RECALL TASK FLOW ----------------

          case AppRoutes.wordRecallIntro:
            return MaterialPageRoute(
              builder: (context) => WordRecallIntroScreen(
                onNext: () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.wordRecallInstruction),
              ),
            );

          case AppRoutes.wordRecallInstruction:
            return MaterialPageRoute(
              builder: (context) => WordRecallInstructionScreen(
                onNext: () =>
                    Navigator.of(context).pushNamed(AppRoutes.wordRecallListen),
              ),
            );

          case AppRoutes.wordRecallListen:
            return MaterialPageRoute(
              builder: (context) => WordRecallListeningScreen(
                onFinished: (result) {
                  Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.wordRecallResult, arguments: result);
                },
              ),
            );

          case AppRoutes.wordRecallResult:
            return MaterialPageRoute(
              builder: (context) {
                final result = settings.arguments as WordRecallResult;
                return WordRecallResultScreen(
                  result: result,
                  onNext: () =>
                      Navigator.of(context).pushNamed(AppRoutes.codingIntro),
                );
              },
            );

          case AppRoutes.codingIntro:
            return MaterialPageRoute(
              builder: (context) => CodingIntroScreen(
                onNext: () =>
                    Navigator.of(context).pushNamed(AppRoutes.codingPractice),
              ),
            );

          case AppRoutes.codingPractice:
            return MaterialPageRoute(
              builder: (context) => CodingPracticeScreen(
                onNext: () =>
                    Navigator.of(context).pushNamed(AppRoutes.codingAssessment),
              ),
            );

          case AppRoutes.codingAssessment:
            return MaterialPageRoute(
              builder: (context) => CodingAssessmentScreen(
                onFinish: () =>
                    Navigator.of(context).pushNamed(AppRoutes.finalMcatResult),
              ),
            );

 */

          case AppRoutes.finalMcatResult:
            return MaterialPageRoute(
              builder: (_) => const McatFinalResultScreen(),
            );

          // 🚨 Unknown route fallback
          default:
            return MaterialPageRoute(
              builder: (context) =>
                  const Scaffold(body: Center(child: Text('Unknown route'))),
            );
        }
      },
    );
  }
}
