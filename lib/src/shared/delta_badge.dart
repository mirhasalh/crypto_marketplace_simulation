import 'package:flutter/material.dart';

import '../color_palette.dart';

class DeltaBadge extends StatelessWidget {
  const DeltaBadge({super.key, required this.isBearish, required this.text});

  final bool isBearish;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isBearish ? kFolly.withAlpha(30) : kMint.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: TextStyle(color: isBearish ? kFolly : kMint)),
    );
  }
}
