import 'package:flutter/material.dart';

final ThemeData customRedTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.redAccent,
    primary: Colors.grey.shade800,
    secondary: Colors.white,
  ),
  primaryColor: Colors.redAccent,
  secondaryHeaderColor: Colors.white,
  hintColor: Colors.grey.shade700,
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
  dialogTheme: const DialogTheme(
    backgroundColor: Colors.white,
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: TextStyle(color: Colors.black),
  ),
);

//========== DARK THEME ==========
final ThemeData customRedDarkTheme = customRedTheme.copyWith(
  brightness: Brightness.dark,
  colorScheme: customRedTheme.colorScheme.copyWith(
    primary: Colors.white,
    secondary: Colors.grey.shade800,
    surface: Colors.grey.shade800,
  ),
  secondaryHeaderColor: Colors.grey.shade900,
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
  snackBarTheme: customRedTheme.snackBarTheme.copyWith(
    backgroundColor: Colors.grey.shade900,
    contentTextStyle: const TextStyle(color: Colors.white),
  ),
  dialogTheme: customRedTheme.dialogTheme.copyWith(
    backgroundColor: Colors.grey.shade900,
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: const TextStyle(color: Colors.white),
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: Colors.grey.shade800,
    textStyle: const TextStyle(color: Colors.white),
    shape: const RoundedRectangleBorder(),
  ),
);
