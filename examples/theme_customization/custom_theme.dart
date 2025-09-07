import 'package:flutter/material.dart';

class CustomTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Colors.blue,
      accentColor: Colors.orange,
      scaffoldBackgroundColor: Colors.white,
      textTheme: TextTheme(
        bodyText1: TextStyle(color: Colors.black),
        bodyText2: TextStyle(color: Colors.black54),
      ),
      appBarTheme: AppBarTheme(
        color: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: Colors.blueGrey,
      accentColor: Colors.teal,
      scaffoldBackgroundColor: Colors.grey[900],
      textTheme: TextTheme(
        bodyText1: TextStyle(color: Colors.white),
        bodyText2: TextStyle(color: Colors.white70),
      ),
    );
  }
}
