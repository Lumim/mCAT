import 'package:flutter/material.dart';
import '../../../domain/models/emotion.dart';
import '../../widgets/primary_button.dart';

class FaceItem {
final String asset;
final Emotion correct;
FaceItem(this.asset, this.correct);
}


class FaceTaskAssessmentScreen extends StatefulWidget {
final List<FaceItem> items;
final void Function(int score, int total) onFinished;
const FaceTaskAssessmentScreen({super.key, required this.items, required this.onFinished});


@override
State<FaceTaskAssessmentScreen> createState() => _FaceTaskAssessmentScreenState();
}


class _FaceTaskAssessmentScreenState extends State<FaceTaskAssessmentScreen> {
int index = 0;
int score = 0;
Emotion? selected;


void _submit() {
final current = widget.items[index];
if (selected == current.correct) score++;
if (index < widget.items.length - 1) {
setState(() {
index++;
selected = null;
});
} else {
widget.onFinished(score, widget.items.length);
}
}


@override
Widget build(BuildContext context) {
final current = widget.items[index];
return Scaffold(
appBar: AppBar(title: const Text('Face Task')),
body: Padding(
padding: const EdgeInsets.all(16),
child: Column(
children: [
const SizedBox(height: 8),
const Text('Figure out the emotion by seeing the picture.'),
const SizedBox(height: 16),
Expanded(
child: Center(
child: Image.asset(current.asset, fit: BoxFit.contain),
),
),
const SizedBox(height: 16),
Wrap(
spacing: 8,
runSpacing: 8,
alignment: WrapAlignment.center,
children: Emotion.values.map((e) {
final isSelected = selected == e;
return ChoiceChip(
label: Text(e.label),
selected: isSelected,
onSelected: (_) => setState(() => selected = e),
);
}).toList(),
),
const SizedBox(height: 12),
Row(
mainAxisAlignment: MainAxisAlignment.end,
children: [
PrimaryButton(label: index == widget.items.length - 1 ? 'Finish' : 'Next', onPressed: selected != null ? _submit : null),
],
),
],
),
),
);
}
}