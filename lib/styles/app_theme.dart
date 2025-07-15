import 'package:flutter/material.dart';

Color primary = const Color(0xFFA6D1FA);
Color mblack = const Color(0xFF000000);
Color text = const Color(0xFF3b3b3b);
Color deepblue = const Color(0xFF197AD3);
Color gray = const Color(0xFFECECEC);
Color mred = const Color(0xFFF45858);

class AppTheme {
  static Color primaryColor = primary; //main color
  static Color mainblack = mblack;
  static Color textColor = text;
  static Color maindeepblue = deepblue;
  static Color maingray = gray; // 회색 상자 사용시
  static Color mainred = mred; // 삭제 시

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    scaffoldBackgroundColor: Colors.white,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: maindeepblue,
      unselectedItemColor: Colors.grey,
    ),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[800],
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    scaffoldBackgroundColor: Colors.grey[800],
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey[800],
      selectedItemColor: maindeepblue,
      unselectedItemColor: Colors.grey,
    ),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
  );
}
