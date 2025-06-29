import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';

void main() {
  // For widgets to be able to read providers, we need to wrap the entire
  // application in a "ProviderScope" widget.
  // This is where the state of our providers will be stored.
  runApp(const ProviderScope(child: App()));
}
