import 'package:crypto_marketplace_simulation/src/pages/home_page_state.dart';
import 'package:flutter/material.dart';

class AssetListTile extends StatelessWidget {
  const AssetListTile({
    super.key,
    required this.asset,
    required this.amount,
    required this.name,
    required this.onPressed,
    required this.short,
    required this.value,
  });

  final VoidCallback onPressed;
  final String name;
  final String short;
  final String amount;
  final String value;
  final String asset;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return RawMaterialButton(
      onPressed: onPressed,
      fillColor: colors.surface,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 0.0, 12.0),
            child: ClipOval(child: Image.asset(asset, scale: 8.0)),
          ),
          const SizedBox(width: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(short),
              Text(name, style: textTheme.bodySmall),
            ],
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(amount),
                if (value != '0.0')
                  Text(moneyFormatter(value), style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
