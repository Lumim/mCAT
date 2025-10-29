import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';


class FaceTaskIntroScreen extends StatelessWidget {
final VoidCallback onNext;
const FaceTaskIntroScreen({super.key, required this.onNext});


@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Face Task – Instructions')),
body: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'This will be the practice for the face task. There will be 2 faces for practicing the task.\n\n'+
'First, you can do a practice round. Next, you will start the real round.\n\n'+
'Each face shows one of the emotions: anger, fear, joy, sadness, surprise, or disgust. Some can also be neutral.',
),
const Spacer(),
Row(
mainAxisAlignment: MainAxisAlignment.end,
children: [
PrimaryButton(label: 'Next', onPressed: onNext),
],
)
],
),
),
);
}
}