import 'package:flutter/material.dart';

import '../../domain/models/letter_number_models.dart' show LnController;

class ContinueElevatedButton extends StatelessWidget {
  final LnController controller;
  final String routeName;
  final String buttonText;

  const ContinueElevatedButton({
    super.key,
    required this.controller,
    this.routeName = '/ln_play',
    this.buttonText = 'Continue',
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacementNamed(
          context,
          routeName,
          arguments: controller,
        );
      },
      child: Text(buttonText),
    );
  }
}
