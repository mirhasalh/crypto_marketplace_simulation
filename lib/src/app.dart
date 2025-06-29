import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'routes.dart';
import 'themes.dart';

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      title: 'Simulation',
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: onGenerateRoute,
    );
  }
}
