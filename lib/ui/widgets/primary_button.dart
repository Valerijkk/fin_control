import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  const PrimaryButton({super.key, required this.onPressed, required this.label, this.icon});
  @override
  Widget build(BuildContext context) {
    final child = Text(label);
    return icon == null
        ? FilledButton(onPressed: onPressed, child: child)
        : FilledButton.icon(onPressed: onPressed, icon: Icon(icon), label: child);
  }
}
