import 'package:flutter/material.dart';


class PrimaryButton extends StatelessWidget {
final String label;
final VoidCallback? onPressed;
final bool filled;
const PrimaryButton({super.key, required this.label, this.onPressed, this.filled = true});


@override
Widget build(BuildContext context) {
final btn = ElevatedButton(
onPressed: onPressed,
child: Text(label),
);
if (filled) return btn;
return OutlinedButton(onPressed: onPressed, child: Text(label));
}
}