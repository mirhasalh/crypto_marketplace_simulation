import 'package:flutter/material.dart';

import 'pages/pages.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const AuthPage());
    case '/create-account':
      return MaterialPageRoute(builder: (_) => const CreateAccountPage());
    case '/trade':
      final args = settings.arguments as TradePageArgs;
      return MaterialPageRoute(
        builder: (_) => TradePage(
          symbol: args.symbol,
          prices: args.prices,
          user: args.user,
        ),
      );
    case '/home':
      final args = settings.arguments as HomePageArgs;
      return MaterialPageRoute(
        builder: (_) =>
            NavPage(latestKnownPrices: args.latestKnownPrices, user: args.user),
      );
    default:
      return MaterialPageRoute(
        builder: (_) => UndefinedRoutePage(routeName: settings.name!),
      );
  }
}
