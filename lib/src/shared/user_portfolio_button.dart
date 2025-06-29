import 'package:flutter/material.dart';

import '../database/database.dart' show User;
import '../pages/home_page_state.dart';
import 'user_avatar.dart';

class UserPortfolioButton extends StatelessWidget {
  const UserPortfolioButton({
    super.key,
    required this.onPressed,
    required this.user,
  });

  final VoidCallback onPressed;
  final User user;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final balance = moneyFormatter(user.balanceUSD);
    final colors = Theme.of(context).colorScheme;

    return RawMaterialButton(
      onPressed: onPressed,
      padding: const EdgeInsetsGeometry.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12.0),
      ),
      constraints: const BoxConstraints(
        maxHeight: double.infinity,
        maxWidth: double.infinity,
        minHeight: 0.0,
        minWidth: 0.0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAvatar(title: user.name),
          const SizedBox(width: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.name,
                style: textTheme.bodySmall!.copyWith(
                  color: colors.onSurface.withAlpha(200),
                ),
              ),
              Text(balance, style: textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}
