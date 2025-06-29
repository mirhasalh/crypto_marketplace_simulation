import 'dart:convert';

import 'package:http/http.dart' as http;

import '../environments.dart';
import 'constants.dart';

const headers = {'Accept': 'application/json', 'User-Agent': 'FlutterApp/1.0'};

Future<List<List<dynamic>>> fetchKlines(
  String symbol,
  String interval,
  Function(String) onError,
) async {
  final e = DateTime.now().millisecondsSinceEpoch;
  final r = kIntervals[interval]!['range'] ?? 90;
  final s = DateTime.now().subtract(Duration(days: r)).millisecondsSinceEpoch;
  final l = kIntervals[interval]!['limit'] ?? 90;

  var u =
      '$kApiBaseUrl/fapi/v1/klines?symbol=$symbol&interval=$interval&startTime=$s&endTime=$e&limit=$l';

  try {
    final res = await http.get(Uri.parse(u), headers: headers);

    if (res.statusCode == 200) {
      final data = json.decode(res.body) as List<dynamic>;
      return data.map<List<dynamic>>((e) => e as List<dynamic>).toList();
    } else {
      throw Exception('Failed to fetch klines: ${res.statusCode}');
    }
  } catch (e) {
    onError('$e');
    rethrow;
  }
}
