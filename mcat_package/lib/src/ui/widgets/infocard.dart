import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String text;
  final int? fontSize;

  const InfoCard({
    super.key,
    required this.text,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text, // Use the instance variable
          textAlign: TextAlign.center,
          style: fontSize != null 
              ? TextStyle(fontSize: fontSize!.toDouble()) 
              : null,
        ),
      ),
    );
  }
}