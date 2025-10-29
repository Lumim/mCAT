import 'package:flutter/material.dart';
import '../../domain/models/mcat_task.dart';
import '../widgets/primary_button.dart';


class IntroScreen extends StatelessWidget {
final VoidCallback? onStart;
final List<McatTask> tasks;
const IntroScreen({super.key, required this.onStart, required this.tasks});


@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('mCAT')),
body: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const SizedBox(height: 8),
Text(
'A smartphone-based battery for cognitive assessment',
style: Theme.of(context).textTheme.titleLarge,
),
const SizedBox(height: 16),
Text('You will complete a brief set of tasks. Find a quiet room and avoid distractions.'),
const SizedBox(height: 24),
Text('Tasks included:', style: Theme.of(context).textTheme.titleMedium),
const SizedBox(height: 8),
Expanded(
child: ListView.separated(
itemCount: tasks.length,
separatorBuilder: (_, __) => const SizedBox(height: 8),
itemBuilder: (context, i) {
final t = tasks[i];
return Card(
child: ListTile(
title: Text(t.title),
trailing: const Icon(Icons.chevron_right),
),
);
},
),
),
const SizedBox(height: 8),
Align(
alignment: Alignment.centerRight,
child: PrimaryButton(label: 'Start', onPressed: onStart),
),
],
),
),
);
}
}