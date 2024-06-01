import 'package:flutter/material.dart';

final ThemeData customRedTheme = ThemeData(
  useMaterial3: true,
  primaryColor: Colors.redAccent,
  primarySwatch: Colors.red,
  hintColor: Colors.redAccent,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.redAccent,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 24,
    ),
    iconTheme: IconThemeData(color: Colors.white),
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
  ),
);
