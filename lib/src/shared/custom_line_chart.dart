import 'package:flutter/material.dart';

import '../color_palette.dart';

class LineChartPainter extends CustomPainter {
  LineChartPainter(this.prices, this.isBearish);

  final List<double> prices;
  final bool isBearish;

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.isEmpty) return;

    final paint = Paint()
      ..color = isBearish ? kFolly : kMint
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double minPrice = prices.reduce((a, b) => a < b ? a : b);
    double maxPrice = prices.reduce((a, b) => a > b ? a : b);
    double priceRange = maxPrice - minPrice;

    Path path = Path();
    for (int i = 0; i < prices.length; i++) {
      double x = (i / (prices.length - 1)) * size.width;
      double y =
          size.height - ((prices[i] - minPrice) / priceRange) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return oldDelegate.prices != prices;
  }
}

class CustomLineChart extends StatelessWidget {
  const CustomLineChart({
    super.key,
    required this.prices,
    required this.isBearish,
  });

  final List<double> prices;
  final bool isBearish;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: LineChartPainter(prices, isBearish),
    );
  }
}
