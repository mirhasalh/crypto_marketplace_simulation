import 'package:flutter/material.dart';

import '../constants.dart' show kKeyboardKeys;

class NumPad extends StatelessWidget {
  const NumPad({super.key, required this.onKey});

  final Function(String) onKey;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: double.infinity,
        maxWidth: 360.0,
        minHeight: 0.0,
        minWidth: 0.0,
      ),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        children: List.generate(kKeyboardKeys.split(':').length, (i) {
          final k = kKeyboardKeys.split(':')[i];
          return TextButton(
            onPressed: () => onKey(k),
            child: k == 'b'
                ? Icon(Icons.backspace, size: 24.0, color: colors.onSurface)
                : Text(k, style: textTheme.titleLarge),
          );
        }),
      ),
    );
  }
}
