import 'package:flutter/material.dart';

final ThemeData customRedTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.redAccent,
    primary: Colors.redAccent,
    secondary: Colors.white,
  ),
  primaryColor: Colors.redAccent,
  primarySwatch: Colors.red,
  hintColor: Colors.grey.shade700,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.redAccent,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: Colors.black,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(color: Colors.black, fontSize: 20),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.redAccent,
      foregroundColor: Colors.white,
    ),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.redAccent,
    textTheme: ButtonTextTheme.primary,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.redAccent,
    foregroundColor: Colors.white,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.redAccent,
    ),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Colors.white,
    contentTextStyle: TextStyle(color: Colors.black87),
  ),
);

//========== DARK THEME ==========
final ThemeData customRedDarkTheme = customRedTheme.copyWith(
  brightness: Brightness.dark,
  colorScheme: customRedTheme.colorScheme.copyWith(brightness: Brightness.dark),
  scaffoldBackgroundColor: Colors.grey.shade900,
  appBarTheme: customRedTheme.appBarTheme.copyWith(
    backgroundColor: Colors.redAccent,
  ),
  textTheme: customRedTheme.textTheme.copyWith(
    bodyLarge: const TextStyle(color: Colors.white),
    bodyMedium: const TextStyle(color: Colors.white70),
    displayLarge: const TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: const TextStyle(color: Colors.white, fontSize: 20),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  inputDecorationTheme: customRedTheme.inputDecorationTheme.copyWith(
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.redAccent),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white70),
    ),
    hintStyle: const TextStyle(color: Colors.white70),
    labelStyle: const TextStyle(color: Colors.white),
  ),
  bottomNavigationBarTheme: customRedTheme.bottomNavigationBarTheme.copyWith(
    backgroundColor: Colors.grey.shade900,
  ),
);
