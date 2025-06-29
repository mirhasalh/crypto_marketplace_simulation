import 'package:flutter/material.dart';

import '../utils.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 40.0,
      height: 40.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).disabledColor,
      ),
      child: title == ''
          ? Icon(Icons.person, color: colors.surface)
          : Text(
              getAvatarTitle(title),
              style: textTheme.titleSmall!.copyWith(color: colors.surface),
            ),
    );
  }
}
