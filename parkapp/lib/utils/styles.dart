// External imports
import 'package:flutter/material.dart';

// Theme configuration.
ThemeData theme(BuildContext context) {
  return new ThemeData(
    primarySwatch: themeColor,
    accentColor: Colors.white,
    splashColor: themeColor,
    fontFamily: 'Regular',
    primaryColorBrightness: Brightness.dark,
    unselectedWidgetColor: Colors.white,
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: const TextStyle(
        color: Colors.white70,
      ),
      labelStyle: const TextStyle(
        color: Colors.white,
      ),
    ),
    textTheme: const TextTheme(
      title: const TextStyle(
        color: Colors.white,
        fontSize: 26.0,
      ),
      headline: const TextStyle(
        color: Colors.white,
        fontSize: 20.0,
      ),
      subhead: const TextStyle(
        color: Colors.white,
        fontSize: 17.0,
      ),
      caption: const TextStyle(
        fontSize: 12.0,
        color: themeGrey,
      ),
      button: const TextStyle(
        color: Colors.white,
        fontSize: 16.0,
      ),
      body1: const TextStyle(
        color: Colors.white,
        fontSize: 14.0,
      ),
      body2: const TextStyle(
        color: Colors.white,
        fontSize: 15.0,
      ),
      display1: const TextStyle(
        color: Colors.white,
        fontSize: 36.0,
      ),
      display2: const TextStyle(
        color: Colors.white,
        fontSize: 13.0,
      ),
      display3: const TextStyle(
        color: Colors.white,
        fontSize: 18.0,
      ),
      display4: const TextStyle(
        color: Colors.white,
        fontSize: 24.0,
      ),
    ),
  );
}

// Generated using Material Design Palette/Theme Generator
// http://mcg.mbitson.com/
// https://github.com/mbitson/mcg
const int _greenPrimary = 0xFF41DF9A;
const Color themeGrey = Color(0xFF8C94A0);
const Color themeLightGrey = Color(0xFFC5CCD6);
const Color themeDarkGrey = Color(0xFF4F4F4F);
const MaterialColor themeColor = const MaterialColor(
  _greenPrimary,
  const <int, Color>{
    50: const Color(0xFFE8FBF3),
    100: const Color(0xFFC6F5E1),
    200: const Color(0xFFA0EFCD),
    300: const Color(0xFF7AE9B8),
    400: const Color(0xFF5EE4A9),
    500: const Color(_greenPrimary),
    600: const Color(0xFF3BDB92),
    700: const Color(0xFF32D788),
    800: const Color(0xFF2AD27E),
    900: const Color(0xFF1CCA6C),
  },
);