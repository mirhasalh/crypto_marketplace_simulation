import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'provider/providers.dart';
import 'routes.dart';
import 'themes.dart';

class App extends ConsumerWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider).locale;
    final themeMode = ref.watch(themeProvider).themeMode;

    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      title: 'Simulation',
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      initialRoute: '/',
      onGenerateRoute: onGenerateRoute,
    );
  }
}
