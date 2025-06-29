import '../constants.dart' show kSymbols;

enum TradeType { buy, sell }

String getTradeHint(String symbol, TradeType tradeType, String portfolio) {
  if (tradeType == TradeType.buy) {
    return '0.5-100 $symbol';
  } else {
    var count = 0.0;
    for (var e in portfolio.split(',')) {
      final split = e.split(':');
      if (symbol.toLowerCase() == split[0]) {
        count += double.parse(split[1]);
        break;
      }
    }
    return 'Available: ${count.toStringAsFixed(2)} $symbol';
  }
}

String getStreamName(String symbol, String event, String? interval) {
  var streamName = '${symbol.toLowerCase()}@${event.toLowerCase()}';
  if (interval != null) streamName = '${streamName}_$interval';
  return streamName;
}

String getComparison(String symbol, double price) {
  final fixed = price.toStringAsFixed(2);
  return '1 ${kSymbols[symbol]!['short']!.toUpperCase()} = $fixed';
}
