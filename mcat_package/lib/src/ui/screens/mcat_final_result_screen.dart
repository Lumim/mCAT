import 'package:flutter/material.dart';
import 'package:mcat_package/src/services/data_service.dart';
import 'package:mcat_package/src/domain/models/task_record.dart';
import '../widgets/header_bar.dart';
import '../widgets/primary_button.dart';

class McatFinalResultScreen extends StatefulWidget {
  const McatFinalResultScreen({super.key});

  @override
  State<McatFinalResultScreen> createState() => _McatFinalResultScreenState();
}

class _McatFinalResultScreenState extends State<McatFinalResultScreen> {
  List<TaskRecord> records = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final data = await DataService().getAllRecords();
    setState(() {
      records = data;
      loading = false;
    });
  }

  Widget _buildTaskCard(TaskRecord record, Color color) {
    final acc = (record.data['accuracy'] ?? 0.0) * 100;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(record.taskType.toUpperCase(),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text(
              'Score: ${record.data['correct']}/${record.data['total']}  '
              '(${acc.toStringAsFixed(1)}%)',
              style: const TextStyle(color: Colors.white)),
          Text(
              'Time: ${record.data['timeTakenSec'] ?? (record.data['timeTakenMs'] ?? 0) ~/ 1000}s',
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorMap = {
      'face': Colors.blue.shade400,
      'word': Colors.orange.shade400,
      'letter-number': Colors.green.shade400,
      'recall': Colors.purple.shade400,
      'coding_task': Colors.cyan.shade400,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Completion', activeStep: 6),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const Text(
                    'Test Completion Summary',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: records.map((rec) {
                        final color = colorMap[rec.taskType] ?? Colors.grey;
                        return _buildTaskCard(rec, color);
                      }).toList(),
                    ),
                  ),
                  PrimaryButton(
                    label: 'Finish',
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                ],
              ),
      ),
    );
  }
}
