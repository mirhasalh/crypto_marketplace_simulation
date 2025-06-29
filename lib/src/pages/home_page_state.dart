import 'dart:math';

import '../constants.dart';
import '../models/mark_price.dart';
import '../utils.dart';

bool isBearish(List<dynamic>? klines) {
  if (klines!.isNotEmpty) {
    final a = double.parse(klines[klines.length - 1][4]);
    final b = double.parse(klines[klines.length - 2][4]);
    return a < b;
  } else {
    return false;
  }
}

double change(double a, double b) {
  return ((a - b) / b) * 100;
}

String getBadgeText(List<dynamic>? klines) {
  if (klines!.isNotEmpty) {
    final a = double.parse(klines[klines.length - 1][4]);
    final b = double.parse(klines[klines.length - 2][4]);
    final str = change(a, b).toStringAsFixed(2);
    return str[0] == '-' ? str : '+$str';
  } else {
    return '0.0';
  }
}

List<String> getTopics(Map<String, Map<String, String>> kAvailablePairs) {
  return kAvailablePairs.keys.map((key) => '${key}usdt@markPrice').toList();
}

String getPricesStringFromMarkPrices(List<MarkPrice> markPrices) {
  var latestKnownPrices = <String>[];
  for (var e in markPrices) {
    latestKnownPrices.add('${e.symbol}:${e.estSettlePrice}');
  }
  return latestKnownPrices.join(',');
}

List<dynamic> getKlinesFromMarkPrice(MarkPrice markPrice) {
  final time = DateTime.now().millisecondsSinceEpoch;

  List kline = [
    time, // Open time
    '0.0', // Open
    '0.0', // High
    '0.0', // Low
    '${markPrice.estSettlePrice}', // Close
    '0.0', // Volume
    time, // Close time
    '0.0', // Quote asset volume
    0, // Number of trades
    '0.0', // Taker buy base asset volume
    '0.0', // Taker buy quote asset volume
    '0.0', // Ignore.
  ];

  return kline;
}

List<double> getPrices(List<dynamic>? klineData) {
  if (klineData!.isNotEmpty && klineData.length >= 4) {
    var filtered = klineData.map((v) => double.parse('${v[4]}')).toList();
    return filtered;
  } else {
    return <double>[];
  }
}

String getAsset(MarkPrice markPrice) {
  final key = getFirstThreeCharacters(markPrice.symbol!).toLowerCase();
  return kAvailablePairs[key]!['image']!;
}

String threeDigitStringSeparator(String str, {String separator = ','}) {
  final regex = RegExp(r'\B(?=(\d{3})+(?!\d))');
  final separated = str.replaceAllMapped(regex, (match) => separator);
  return separated;
}

String moneyFormatter(String str, {String symbol = '\$'}) {
  var fixed = double.parse(str).toStringAsFixed(2);
  final split = fixed.split('.');
  if (split.length == 1) {
    return '$symbol${threeDigitStringSeparator(str)}.0';
  } else {
    return '$symbol${threeDigitStringSeparator(split[0])}.${split[1]}';
  }
}

String getCurrentPrice(String price, {String symbol = '\$'}) {
  var currentPrice = price.isEmpty ? '0.0' : price;
  final formatted = moneyFormatter(currentPrice, symbol: symbol);
  return formatted;
}

Map<String, List<dynamic>> initKlines(List<String> pairs) {
  Map<String, List<dynamic>> klineData = {};

  for (var e in pairs) {
    final split = e.split('@');
    final symbol = split[0].toUpperCase();
    var obj = {symbol: []};
    klineData.addAll(obj);
  }

  return klineData;
}

List<MarkPrice> initMarkPrices(List<String> pairs, List<String> knownPrices) {
  List<MarkPrice> markPairs = [];

  for (var e in pairs) {
    final split = e.split('@');
    final symbol = split[0].toUpperCase();
    if (!markPairs.map((v) => v.symbol).contains(symbol)) {
      final estimatedSettlePrice = _findKnownPrice(symbol, knownPrices);

      final markPair = MarkPrice(
        symbol: symbol,
        eventTime: 0,
        eventType: '',
        markPrice: '',
        indexPrice: '',
        estSettlePrice: estimatedSettlePrice,
        fundingRate: '',
        nextFundingTime: 0,
      );
      markPairs.add(markPair);
    }
  }

  return markPairs;
}

String _findKnownPrice(String symbol, List<String> knownPrices) {
  if (knownPrices.isNotEmpty) {
    var price = '';
    for (var i = 0; i < knownPrices.length; i++) {
      final split = knownPrices[i].split(':');
      if (split[0] == symbol) {
        price = split[1];
        break;
      }
    }
    return price;
  } else {
    return '';
  }
}

String getAssetAmount(String symbol, String portfolio) {
  final assets = portfolio.split(',');
  if (assets.map((a) => a.split(':')[0]).contains(symbol)) {
    var asset = assets.firstWhere((e) => e.split(':')[0] == symbol);
    return asset.split(':')[1];
  } else {
    return '0.0';
  }
}

String getAssetValue(String symbol, String portfolio, String currentPrice) {
  final assets = portfolio.split(',');
  if (assets.map((a) => a.split(':')[0]).contains(symbol)) {
    var asset = assets.firstWhere((e) => e.split(':')[0] == symbol);
    var value = double.parse(currentPrice) * double.parse(asset.split(':')[1]);
    return '$value';
  } else {
    return '0.0';
  }
}
