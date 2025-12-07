import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int activeIndex;
  final int total;
  const StepIndicator({
    super.key,
    required this.activeIndex,
    this.total = 6,
  });

  @override
  Widget build(BuildContext context) {
    Widget? currentWidget;

    switch (activeIndex) {
      case 1:
        currentWidget = faceTask();
        break;
      case 2:
        currentWidget = wordTask();
        break;
      case 3:
        currentWidget = letterNumberTask();
        break;
      case 4:
        currentWidget = orgTask();
        break;
      case 5:
        currentWidget = codingTask();
        break;
      default:
        currentWidget = null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: currentWidget != null ? [currentWidget] : [],
      ),
    );
  }

  Widget faceTask() {
    return const Padding(
      padding: EdgeInsets.all(2),
      child: Text(
        'Face Task',
      ),
    );
  }

  Widget wordTask() {
    return const Padding(
      padding: EdgeInsets.all(2),
      child: Text('Word Task'),
    );
  }

  Widget letterNumberTask() {
    return const Padding(
      padding: EdgeInsets.all(2),
      child: Text('Letter Number Task'),
    );
  }

  Widget orgTask() {
    return const Padding(
      padding: EdgeInsets.all(2),
      child: Text('Organizational Task'),
    );
  }

  Widget codingTask() {
    return const Padding(
      padding: EdgeInsets.all(2),
      child: Text('Coding Task'),
    );
  }
}
