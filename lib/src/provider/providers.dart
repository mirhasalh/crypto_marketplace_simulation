import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../environments.dart';

final webSocketProvider = NotifierProvider<WebSocketNotifier, Stream<String>>(
  () {
    return WebSocketNotifier();
  },
);

class WebSocketNotifier extends Notifier<Stream<String>> {
  WebSocketChannel? _channel;
  String _currentUrl = '';
  Stream<String>? _stream;

  @override
  Stream<String> build() {
    ref.onDispose(() {
      _channel?.sink.close();
    });
    return const Stream.empty();
  }

  void connectToTopics(List<String> topics) {
    final joinedTopics = topics.join('/');
    final url = '$kWssBaseUrl/stream?streams=$joinedTopics';

    if (url == _currentUrl && _stream != null) return;

    _currentUrl = url;
    _channel?.sink.close();
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _stream = _channel!.stream
        .map((event) => event.toString())
        .asBroadcastStream();

    state = _stream!;
  }
}

final localeProvider = ChangeNotifierProvider((ref) => LocaleProvider());

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;

    notifyListeners();
  }
}

final themeProvider = ChangeNotifierProvider((ref) => ThemeProvider());

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;

    notifyListeners();
  }
}
