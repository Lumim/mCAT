import 'package:flutter/material.dart';
import 'package:mcat_package/src/ui/widgets/instruction_intro.dart';
import '../../domain/models/mcat_task.dart';
import '../widgets/header_bar.dart';
import '../../services/data_service.dart'; // <-- adjust if your path is different
import '../../domain/models/task_record.dart';
import '../widgets/mcat_task_card.dart';
import '../widgets/instruction_intro.dart';

// this is the main screen that shows all the tasks in mCAT package version 2.0.0
// Author: Mohammad Lummim Sarker

class AllIntroScreen extends StatefulWidget {
  final VoidCallback? onStart;
  final List<McatTask> tasks;

  const AllIntroScreen({
    super.key,
    required this.onStart,
    required this.tasks,
  });

  @override
  State<AllIntroScreen> createState() => _AllIntroScreenState();
}

/// Local model for UI-friendly progress
class _TaskProgress {
  final bool completed;
  final int? correct;
  final int? total;
  final double? accuracy; // 0–1
  final double? score; // for LN, etc.

  const _TaskProgress({
    required this.completed,
    this.correct,
    this.total,
    this.accuracy,
    this.score,
  });
}

class _AllIntroScreenState extends State<AllIntroScreen> {
  late Future<Map<String, _TaskProgress>> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = _loadProgress();
  }

  Future<Map<String, _TaskProgress>> _loadProgress() async {
    final ds = DataService();
    await ds.init(); // make sure Hive & everything is ready

    final Map<String, _TaskProgress> progress = {};

    // Helper for standard tasks saved as:
    // { 'correct': x, 'total': y, 'accuracy': x/y, 'timeTakenSec': z }
    Future<void> loadStandard(String id) async {
      final TaskRecord? rec = await ds.getTask(id);
      if (rec == null) return;

      final data = rec.data;
      final correct = data['correct'] as int?;
      final total = data['total'] as int?;
      final accNum = data['accuracy'] as num?;
      final accuracy = accNum?.toDouble() ??
          ((correct != null && total != null && total > 0)
              ? correct / total
              : null);

      progress[id] = _TaskProgress(
        completed: true,
        correct: correct,
        total: total,
        accuracy: accuracy,
      );
    }

    // Standard tasks
    await loadStandard('face_task');
    await loadStandard('word_task');
    await loadStandard('coding_task');
    await loadStandard('organizational_task');
    await loadStandard('word_recall');

    // Letter number (special: saved as ln_input with score/total)
    final lnRec1 = await ds.getTask('ln_input1');
    final lnRec2 = await ds.getTask('ln_input2');
    final lnRec3 = await ds.getTask('ln_input3');
    if (lnRec1 != null) {
      final data1 = lnRec1.data;
      final scoreNum1 = data1['score'] as num?;
      final totalNum1 = data1['total'] as num?;

      final data2 = lnRec2?.data;
      final scoreNum2 = data2?['score'] as num?;
      final totalNum2 = data2?['total'] as num?;

      final data3 = lnRec3?.data;
      final scoreNum3 = data3?['score'] as num?;
      final totalNum3 = data3?['total'] as num?;

      progress['ln_input'] = _TaskProgress(
        completed: true,
        score: (scoreNum1?.toDouble() ?? 0) +
            (scoreNum2?.toDouble() ?? 0) +
            (scoreNum3?.toDouble() ?? 0),
        total: (totalNum1?.toInt() ?? 0) +
            (totalNum2?.toInt() ?? 0) +
            (totalNum3?.toInt() ?? 0),
      );
    }

    return progress;
  }

  String? _buildScoreLabel(_TaskProgress? p) {
    if (p == null) return null;

    // LN task: score / total
    if (p.score != null && p.total != null) {
      return 'Score: ${p.score!.toStringAsFixed(0)} / ${p.total}';
    }

    // Standard accuracy
    if (p.accuracy != null) {
      final percent = (p.accuracy! * 100).clamp(0, 100).toStringAsFixed(0);
      if (p.correct != null && p.total != null) {
        return 'Accuracy: $percent% (${p.correct}/${p.total})';
      }
      return 'Accuracy: $percent%';
    }

    // Fallback: just correct/total if present
    if (p.correct != null && p.total != null) {
      return 'Score: ${p.correct}/${p.total}';
    }

    return null;
  }

  _deleteAllData() async {
    final ds = DataService();
    await ds.init();
    await ds.clearDeviceData();
    setState(() {
      _progressFuture = _loadProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF5F6FB);
    const primaryBlue = Color(0xFF0077B6);

    return Scaffold(
      backgroundColor: background,
      appBar: const HeaderBar(
        title: 'Welcome to mCAT',
      ), // Using custom header bar
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro text ------------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome to mCAT',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.info_outline),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text("Details"),
                          content: InstructionIntro(), // any widget you want
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'You can pause between the task but not during the task.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  ElevatedButton(
                      onPressed: _deleteAllData,
                      child: const Text('Clear Device Data')),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Task list with scores & completion ------------------------------
            Expanded(
              child: FutureBuilder<Map<String, _TaskProgress>>(
                future: _progressFuture,
                builder: (context, snapshot) {
                  final progress = snapshot.data ?? {};

                  final faceProg = progress['face_task'];
                  final wordProg = progress['word_task'];
                  final lnProg = progress['ln_input'];
                  final orgProg = progress['organizational_task'];
                  final wordRecallProg = progress['word_recall'];
                  final codingProg = progress['coding_task'];

                  final faceCompleted = faceProg?.completed ?? false;
                  final wordCompleted = wordProg?.completed ?? false;
                  final lnCompleted = lnProg?.completed ?? false;
                  final orgCompleted = orgProg?.completed ?? false;
                  final wordRecallCompleted =
                      wordRecallProg?.completed ?? false;
                  final codingCompleted = codingProg?.completed ?? false;

                  // Word Recall can only start if Word Task is completed
                  final canStartWordRecall = wordCompleted;

                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    children: [
                      McatTaskCard(
                        icon: Icons.face_3_rounded,
                        iconBackground:
                            faceCompleted ? Colors.lightGreen : primaryBlue,
                        title: 'Face Task',
                        statusLabel: faceCompleted ? 'Completed' : 'Start',
                        statusColor:
                            faceCompleted ? Colors.lightGreen : primaryBlue,
                        subtitle: _buildScoreLabel(faceProg),
                        enabled: true,
                        onPressed: () {
                          !faceCompleted
                              ? Navigator.pushReplacementNamed(
                                  context,
                                  '/face_intro',
                                )
                              : null;
                        },
                      ),
                      McatTaskCard(
                        icon: Icons.bookmark_rounded,
                        iconBackground:
                            wordCompleted ? Colors.lightGreen : primaryBlue,
                        title: 'Word Task',
                        statusLabel: wordCompleted ? 'Completed' : 'Start',
                        statusColor:
                            wordCompleted ? Colors.lightGreen : primaryBlue,
                        subtitle: _buildScoreLabel(wordProg),
                        enabled: true,
                        onPressed: () {
                          !wordCompleted
                              ? Navigator.pushReplacementNamed(
                                  context,
                                  '/word_intro',
                                )
                              : null;
                        },
                      ),
                      McatTaskCard(
                        icon: Icons.text_fields_rounded,
                        iconBackground:
                            lnCompleted ? Colors.lightGreen : primaryBlue,
                        title: 'Letter Number Task',
                        statusLabel: lnCompleted ? 'Completed' : 'Start',
                        statusColor:
                            lnCompleted ? Colors.lightGreen : primaryBlue,
                        subtitle: _buildScoreLabel(lnProg),
                        enabled: true,
                        onPressed: () {
                          !lnCompleted
                              ? Navigator.pushReplacementNamed(
                                  context,
                                  '/ln_instruction',
                                )
                              : null;
                        },
                      ),
                      McatTaskCard(
                        icon: Icons.markunread_mailbox_rounded,
                        iconBackground:
                            orgCompleted ? Colors.lightGreen : primaryBlue,
                        title: 'Organizational Task',
                        statusLabel: orgCompleted ? 'Completed' : 'Start',
                        statusColor:
                            orgCompleted ? Colors.lightGreen : primaryBlue,
                        subtitle: _buildScoreLabel(orgProg),
                        enabled: true,
                        onPressed: () {
                          !orgCompleted
                              ? Navigator.pushReplacementNamed(
                                  context,
                                  '/org_intro',
                                )
                              : null;
                        },
                      ),
                      McatTaskCard(
                        icon: Icons.bookmarks_outlined,
                        iconBackground: wordRecallCompleted
                            ? Colors.lightGreen
                            : primaryBlue,
                        title: 'Word Recall Task',
                        statusLabel:
                            wordRecallCompleted ? 'Completed' : 'Start',
                        statusColor: wordRecallCompleted
                            ? Colors.lightGreen
                            : primaryBlue,
                        subtitle: _buildScoreLabel(wordRecallProg),
                        enabled: canStartWordRecall,
                        onPressed: () {
                          if (!canStartWordRecall) return;
                          !wordRecallCompleted
                              ? Navigator.pushReplacementNamed(
                                  context,
                                  '/word_recall_intro',
                                )
                              : null;
                        },
                      ),
                      McatTaskCard(
                        icon: Icons.grid_view_rounded,
                        iconBackground:
                            codingCompleted ? Colors.lightGreen : primaryBlue,
                        title: 'Coding Task',
                        statusLabel: codingCompleted ? 'Completed' : 'Start',
                        statusColor:
                            codingCompleted ? Colors.lightGreen : primaryBlue,
                        subtitle: _buildScoreLabel(codingProg),
                        enabled: true,
                        onPressed: () {
                          !codingCompleted
                              ? Navigator.pushReplacementNamed(
                                  context,
                                  '/coding_intro',
                                )
                              : null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
