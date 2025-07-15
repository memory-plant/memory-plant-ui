import 'package:flutter/material.dart';

Color primary = const Color(0xFFA6D1FA);
Color mblack = const Color(0xFF000000);
Color text = const Color(0xFF3b3b3b);
Color deepblue = const Color(0xFF197AD3);
Color gray = const Color(0xFFECECEC);
Color mred = const Color(0xFFF45858);

class AppStyles {
  static Color primaryColor = primary; //main color
  static Color mainblack = mblack;
  static Color textColor = text;
  static Color maindeepblue = deepblue;
  static Color maingray = gray; // 회색 상자 사용시
  static Color mainred = mred; // 삭제 시
  static TextStyle textStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor);
}
