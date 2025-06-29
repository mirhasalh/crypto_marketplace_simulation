import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../database_service.dart';
import 'auth_page_state.dart';
import 'create_account_page_state.dart';
import 'home_page.dart' show HomePageArgs;

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _onAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const Center(child: CircularProgressIndicator.adaptive()),
    );
  }

  // A recursive approach to initialize user and navigate.
  Future<void> _initUserAndNavigate() async {
    final nav = Navigator.of(context);
    final db = DatabaseService();

    final random = Random();

    await db.saveUser(
      kNames[random.nextInt(kNames.length)],
      kFunds[random.nextInt(kFunds.length)],
      '',
    );

    final count = await db.countUsers();

    if (count == 1) {
      final users = await db.getAllUsers();
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt('userId', users[0].id);

      var latestKnownPrices = prefs.getString('latestKnownPrices');

      if (latestKnownPrices == null) {
        final args = HomePageArgs([], users[0]);
        nav.pushNamedAndRemoveUntil('/home', (_) => false, arguments: args);
      } else {
        final prices = getLatestKnownPrices(latestKnownPrices);
        final args = HomePageArgs(prices, users[0]);
        nav.pushNamedAndRemoveUntil('/home', (_) => false, arguments: args);
      }
    } else {
      await _initUserAndNavigate();
    }
  }

  Future<void> _onAuth() async {
    final nav = Navigator.of(context);
    final db = DatabaseService();
    final prefs = await SharedPreferences.getInstance();

    var userId = prefs.getInt('userId');

    if (userId == null) {
      await _initUserAndNavigate();
    } else {
      var user = await db.findUserById(userId);

      var latestKnownPrices = prefs.getString('latestKnownPrices');

      final prices = latestKnownPrices == null
          ? <String>[]
          : getLatestKnownPrices(latestKnownPrices);
      final args = HomePageArgs(prices, user);
      nav.pushNamedAndRemoveUntil('/home', (_) => false, arguments: args);
    }
  }
}
