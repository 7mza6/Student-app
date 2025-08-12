// lib/Views/theam.dart

import 'package:flutter/material.dart';
import '../Viewmodels/constants.dart';

ThemeMode themeMode = ThemeMode.light;

setThemeMode(ThemeMode mode) {
  themeMode = mode;
}

ThemeMode getThemeMode() {
  return themeMode;
}

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: kPrimaryColor,
    secondary: kSecondaryColor,
    background: kLightBackgroundColor,
    surface: Colors.white,
    shadow: Color.fromARGB(125, 158, 158, 158),
  ),
  cardTheme: CardTheme(
    color: Color(0xFFF4F9FF),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF3F99F6),
    foregroundColor: Colors.white,
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: kPrimaryColor,
    secondary: kSecondaryColor,
    background: kDarkBackgroundColor,
    surface: kDarkSurfaceColor,
    shadow: Colors.white,
  ),


  scaffoldBackgroundColor: kDarkBackgroundColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: kPrimaryColor,
    foregroundColor: Colors.white,
  ),
);