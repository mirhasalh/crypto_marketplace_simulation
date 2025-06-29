import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../constants.dart';
import '../database/database.dart';

// NOTE: See a note at 'lib/src/database/databases.dart'
List<Map<String, String>> mapSections(User user) {
  List<Map<String, String>> sections = [];

  double balance = double.tryParse(user.balanceUSD) ?? 0.0;
  double portfolioTotal = 0.0;

  List<Map<String, dynamic>> assets = [];
  if (user.portfolio.isNotEmpty) {
    final entries = user.portfolio.split(',');
    for (var e in entries) {
      final parts = e.split(':');
      if (parts.length != 3) continue;

      final symbol = parts[0];
      final amount = double.tryParse(parts[1]) ?? 0.0;
      final price = double.tryParse(parts[2]) ?? 0.0;

      final value = price * amount;
      if (value <= 0) continue;

      portfolioTotal += value;

      assets.add({'symbol': symbol, 'value': value});
    }
  }

  final sum = portfolioTotal + balance;
  if (sum == 0) return [];

  for (var asset in assets) {
    final symbol = asset['symbol'];
    final value = asset['value'];
    final percent = ((value / sum) * 100).clamp(0.0, 100.0);

    final hexColor = kCryptos[symbol]?['hex'] ?? '000000';

    sections.add({
      't': symbol.toUpperCase(),
      'v': percent.toStringAsFixed(2),
      'h': hexColor,
    });
  }

  final otherPercent = ((balance / sum) * 100).clamp(0.0, 100.0);
  sections.add({
    't': 'Other',
    'v': otherPercent.toStringAsFixed(2),
    'h': 'cecece',
  });

  return sections;
}

class Allocations extends StatelessWidget {
  const Allocations({
    super.key,
    required this.touchCallback,
    required this.user,
    required this.touchedIndex,
  });

  final Function(FlTouchEvent, PieTouchResponse?)? touchCallback;
  final User user;
  final int touchedIndex;

  @override
  Widget build(BuildContext context) {
    final sections = mapSections(user);

    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: <Widget>[
          const SizedBox(height: 18),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      touchCallback!(event, pieTouchResponse);
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: buildSections(sections),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(sections.length, (i) {
              return Indicator(
                color: Color(int.parse('0xff${sections[i]['h']}')),
                text: sections[i]['t']!,
                isSquare: true,
              );
            }),
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  List<PieChartSectionData> buildSections(List<Map<String, String>> sections) {
    return List.generate(sections.length, (i) {
      final isTouched = i == touchedIndex;

      return PieChartSectionData(
        color: Color(int.parse('0xFF${sections[i]['h']}')),
        value: double.parse(sections[i]['v']!),
        title: '${sections[i]['v']}%',
        radius: isTouched ? 60.0 : 50.0,
        titleStyle: TextStyle(
          fontSize: isTouched ? 25.0 : 16.0,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    });
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
