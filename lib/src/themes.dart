import 'package:flutter/material.dart';

const kSeedColor = Color(0xfff58220);
const kContrastLevel = -0.5;

final inputDecorationTheme = const InputDecorationTheme(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
  ),
);

final theme = ThemeData.light().copyWith(
  colorScheme: ColorScheme.fromSeed(
    seedColor: kSeedColor,
    brightness: Brightness.light,
    contrastLevel: kContrastLevel,
    surface: const Color(0xffffffff),
  ),
  scaffoldBackgroundColor: const Color.fromRGBO(245, 245, 247, 1),
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    backgroundColor: Color(0xffffffff),
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color.fromRGBO(245, 245, 247, 1),
  ),
  inputDecorationTheme: inputDecorationTheme,
  listTileTheme: const ListTileThemeData(tileColor: Color(0xffffffff)),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xffffffff),
  ),
);

final darkTheme = ThemeData.dark().copyWith(
  colorScheme: ColorScheme.fromSeed(
    seedColor: kSeedColor,
    brightness: Brightness.dark,
    contrastLevel: kContrastLevel,
    surface: const Color.fromRGBO(13, 17, 22, 1),
  ),
  scaffoldBackgroundColor: const Color.fromRGBO(2, 4, 10, 1),
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    backgroundColor: Color.fromRGBO(13, 17, 22, 1),
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color.fromRGBO(2, 4, 10, 1),
  ),
  inputDecorationTheme: inputDecorationTheme,
  listTileTheme: const ListTileThemeData(
    tileColor: Color.fromRGBO(13, 17, 22, 1),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color.fromRGBO(13, 17, 22, 1),
  ),
);
