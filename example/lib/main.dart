import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:mcat_package/mcat_package.dart';
import './route.dart';
import 'mcat_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive (local storage)
  await Hive.initFlutter();

  // Initialize Firebase (cloud sync)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize DataService for autosync (Hive + Firebase)
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
    final controller = LnController([
      LnRound.generate(level: 1, digits: 1, letters: 3),
      LnRound.generate(level: 2, digits: 1, letters: 4),
      LnRound.generate(level: 3, digits: 2, letters: 5),
    ]);
    final orgController = OrgController([
      OrgRound.generate(digits: 2, letters: 2),
      OrgRound.generate(digits: 3, letters: 2),
      OrgRound.generate(digits: 3, letters: 3),
    ]);

    final tasks = [
      McatTask(id: 'face', title: 'Face Task'),
      McatTask(id: 'word', title: 'Word Task'),
      McatTask(id: 'letter-number', title: 'Letter-Number Task'),
      McatTask(id: 'organizational', title: 'Organizational Task'),
      McatTask(id: 'word-recall', title: 'Word Recall Task'),
      McatTask(id: 'coding', title: 'Coding Task'),
    ];

    return MaterialApp(
      title: 'mCAT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),

      // Start at the intro screen
      home: Builder(
        builder: (navContext) => AllIntroScreen(
          tasks: tasks,
          onStart: () =>
              Navigator.of(navContext).pushNamed(AppRoutes.codingAssessment),
        ),
      ),

      /*  home: Builder(
        builder: (navContext) => IntroScreen(
          tasks: tasks,
          onStart: () =>
              Navigator.of(navContext).pushNamed(AppRoutes.codingAssessment),
        ),
      ),
 */
      onGenerateRoute: (settings) {
        switch (settings.name) {
          // ✅ FACE TASK FLOW
          case AppRoutes.faceIntro:
            return MaterialPageRoute(
              builder: (context) => FaceTaskIntroScreen(
                onNext: () =>
                    //  Navigator.of(context).pushNamed(AppRoutes.facePractice),
                    Navigator.of(context).pushNamed(AppRoutes.facePractice),
              ),
            );

          case AppRoutes.facePractice:
            return MaterialPageRoute(
              builder: (context) => FaceTaskPracticeScreen(
                practiceImageAssets: [
                  FacePracticeItem(
                    'assets/images/practice/face_happy_1.png',
                    Emotion.happy,
                  ),
                  FacePracticeItem(
                    'assets/images/practice/face_sad.png',
                    Emotion.sad,
                  ),
                ],
                onPracticeDone: () =>
                    Navigator.of(context).pushNamed(AppRoutes.faceRealTask),
              ),
            );

          case AppRoutes.faceRealTask:
            return MaterialPageRoute(
              builder: (context) => FaceRealTaskScreen(
                onNext: () {
                  Navigator.of(context).pushNamed(AppRoutes.faceAssessment);
                },
              ),
            );

          case AppRoutes.faceAssessment:
            return MaterialPageRoute(
              builder: (context) => FaceTaskAssessmentScreen(
                items: [
                  FaceItem(
                    'assets/images/practice/face_happy_1.png',
                    Emotion.happy,
                  ),
                  FaceItem('assets/images/practice/face_sad.png', Emotion.sad),
                  FaceItem(
                    'assets/images/practice/face_fear.png',
                    Emotion.fear,
                  ),
                  FaceItem(
                    'assets/images/practice/face_neutral_1.png',
                    Emotion.neutral,
                  ),
                  FaceItem(
                    'assets/images/practice/face_surprise.png',
                    Emotion.surprise,
                  ),
                  FaceItem(
                    'assets/images/practice/face_angry.png',
                    Emotion.angry,
                  ),
                  FaceItem(
                    'assets/images/practice/face_disgust.png',
                    Emotion.disgust,
                  ),
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
                onNext: () =>
                    Navigator.of(context).pushNamed(AppRoutes.wordIntro),
              ),
            );

          // ✅ WORD TASK FLOW
          case AppRoutes.wordIntro:
            return MaterialPageRoute(
              builder: (context) => WordTaskIntroScreen(
                onNext: () =>
                    Navigator.of(context).pushNamed(AppRoutes.wordPractice),
              ),
            );

          case AppRoutes.wordPractice:
            return MaterialPageRoute(
              builder: (context) => WordTaskPracticeScreen(
                words: const ['mountain', 'city', 'snowman', 'house'],
                onFinished: () =>
                    Navigator.of(context).pushNamed(AppRoutes.wordAssessment),
              ),
            );

          case AppRoutes.wordAssessment:
            return MaterialPageRoute(
              builder: (context) {
                final locale = McatSettings.appLocale;
                final words = McatSettings.wordTaskWords(locale);

                return WordTaskAssessmentScreen(
                  words: words,
                  onFinished: (score, total) {
                    _lastScore = score;
                    _lastTotal = total;
                    Navigator.of(context).pushNamed(AppRoutes.wordResult);
                  },
                );
              },
            );

          case AppRoutes.wordResult:
            return MaterialPageRoute(
              builder: (context) => WordTaskResultScreen(
                score: _lastScore,
                total: _lastTotal,
                onNext: () =>
                    Navigator.of(context).pushNamed(AppRoutes.lnInstruction),
              ),
            );

          // ✅ LETTER_NUMBER TASK FLOW
          case AppRoutes.lnInstruction: // '/ln_instruction'
            return MaterialPageRoute(
              builder: (context) => LnInstructionScreen(controller: controller),
            );

          case AppRoutes.lnPlay: // '/ln_play'
            {
              final argController =
                  (settings.arguments as LnController?) ?? controller;
              return MaterialPageRoute(
                builder: (context) => LnPlayScreen(controller: argController),
              );
            }

          case AppRoutes.lnListen: // '/ln_listen'
            {
              final argController =
                  (settings.arguments as LnController?) ?? controller;
              return MaterialPageRoute(
                builder: (context) => LnListenScreen(controller: argController),
              );
            }

          case AppRoutes.lnInput: // '/ln_input'
            {
              final argController =
                  (settings.arguments as LnController?) ?? controller;
              return MaterialPageRoute(
                builder: (context) => LnInputScreen(controller: argController),
              );
            }

          case AppRoutes.lnResult: // '/ln_result'
            {
              final argController =
                  (settings.arguments as LnController?) ?? controller;
              return MaterialPageRoute(
                builder: (context) => LnResultScreen(controller: argController),
              );
            }

          case AppRoutes.orgIntro:
            return MaterialPageRoute(
              builder: (context) => OrgIntroScreen(controller: orgController),
            );

          case AppRoutes.orgInstruction:
            return MaterialPageRoute(
              builder: (context) =>
                  OrgInstructionScreen(controller: orgController),
            );

          case AppRoutes.orgPlay:
            {
              final orgCltr =
                  (settings.arguments as OrgController?) ?? orgController;
              return MaterialPageRoute(
                builder: (_) => OrgPlayScreen(controller: orgCltr),
              );
            }

          case AppRoutes.orgInput:
            {
              final orgCltr =
                  (settings.arguments as OrgController?) ?? orgController;
              return MaterialPageRoute(
                builder: (_) => OrgInputScreen(controller: orgCltr),
              );
            }

          case AppRoutes.orgResult:
            {
              final orgCltr =
                  (settings.arguments as OrgController?) ?? orgController;
              return MaterialPageRoute(
                builder: (_) => OrgResultScreen(
                  controller: orgCltr,
                  onNextTask: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.finalMcatResult),
                ),
              );
            }

          // ✅ WORD RECALL TASK FLOW (delayed recall of Word Task words)
          case AppRoutes.wordRecallIntro:
            return MaterialPageRoute(
              builder: (context) => WordRecallIntroScreen(
                onStart: () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.wordRecallInstruction),
              ),
            );

          case AppRoutes.wordRecallInstruction:
            return MaterialPageRoute(
              builder: (context) => WordRecallInstructionScreen(
                onStartListening: () =>
                    Navigator.of(context).pushNamed(AppRoutes.wordRecallInput),
              ),
            );

          case AppRoutes.wordRecallInput:
            return MaterialPageRoute(
              builder: (context) {
                final locale = McatSettings.appLocale;
                final words = McatSettings.wordTaskWords(locale);

                return WordRecallInputScreen(
                  targetWords: words,
                  onFinished: (score, total) {
                    _lastScore = score;
                    _lastTotal = total;
                    Navigator.of(context).pushNamed(AppRoutes.wordRecallResult);
                  },
                );
              },
            );

          case AppRoutes.wordRecallResult:
            return MaterialPageRoute(
              builder: (context) => WordRecallResultScreen(
                correct: _lastScore,
                total: _lastTotal,
                onNext: () =>
                    Navigator.of(context).pushNamed(AppRoutes.codingIntro),
                // or finalMcatResult or whatever is your next task
              ),
            );

          // ✅ CODING TASK FLOW
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
                    Navigator.of(context).pushNamed(AppRoutes.codingRealText),
              ),
            );
          case AppRoutes.codingRealText:
            return MaterialPageRoute(
              builder: (context) => CodingRealTextScreen(
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

          // ✅ FINAL RESULT SCREEN
          case AppRoutes.finalMcatResult:
            return MaterialPageRoute(
              builder: (_) => const McatFinalResultScreen(),
            );

          // Fallback route
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
