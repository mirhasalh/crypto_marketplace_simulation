import 'package:flutter/material.dart';

class DividerBar extends StatelessWidget {
  const DividerBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(12.0),
      child: Row(children: [Text(title, style: textTheme.titleLarge)]),
    );
  }
}
