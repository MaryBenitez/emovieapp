import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final scale = (shortest / 400).clamp(0.85, 1.35);
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: (22 * scale).clamp(18, 28).toDouble(),
        letterSpacing: 0.2,
      ),
    );
  }
}
