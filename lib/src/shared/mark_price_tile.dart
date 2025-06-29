import 'package:flutter/material.dart';

import 'custom_line_chart.dart';
import 'delta_badge.dart';

class MarkPriceTile extends StatelessWidget {
  const MarkPriceTile({
    super.key,
    required this.onPressed,
    required this.fillColor,
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.badgeText,
    required this.isBearish,
    required this.prices,
  });

  final VoidCallback onPressed;
  final Color fillColor;
  final String title;
  final String subtitle;
  final String asset;
  final String badgeText;
  final bool isBearish;
  final List<double> prices;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return RawMaterialButton(
      onPressed: onPressed,
      fillColor: fillColor,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(0.0),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 48, 24, 24),
            child: SizedBox(
              height: 124.0,
              child: CustomLineChart(prices: prices, isBearish: isBearish),
            ),
          ),
          const _Curtain(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ClipOval(child: Image.asset(asset, scale: 8.0)),
                    const SizedBox(width: 8.0),
                    Text(title),
                  ],
                ),
                const SizedBox(height: 12.0),
                Text(subtitle, style: textTheme.titleLarge),
              ],
            ),
          ),
          Positioned(
            top: 16.0,
            right: 16.0,
            child: DeltaBadge(text: badgeText, isBearish: isBearish),
          ),
        ],
      ),
    );
  }
}

class _Curtain extends StatelessWidget {
  const _Curtain();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            end: Alignment.centerLeft,
            begin: Alignment.centerRight,
            colors: [colors.surface, Colors.transparent],
            stops: const [0.0, 0.7],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstOut,
        child: Container(color: colors.surface),
      ),
    );
  }
}
