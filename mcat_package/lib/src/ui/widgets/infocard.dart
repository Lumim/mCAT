import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String text;
  final int? fontSize;

  const InfoCard(
      {super.key,
      required this.text,
      this.fontSize}); // Remove the positional String s parameter

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: (fontSize ?? 20).toDouble(), height: 1.4),
        textAlign: TextAlign.center,
      ),
    );
  }
}
