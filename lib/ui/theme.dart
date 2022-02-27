import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color bluishClr = Color(0xFF4e5ae8);
const Color yellowClr = Color(0xFFFFB746);
const Color pinkClr = Color(0xFFff4667);
const Color white = Colors.white;
const primaryClr = bluishClr;
const Color darkGreyClr = Color(0xFF121212);
Color darkHeaderClr = Color(0xFF424242);

class Themes {
  static final light = ThemeData(
      backgroundColor: white,
      primaryColor: primaryClr,
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(color: primaryClr));
  // themeMode: ThemeMode.light,
  static final dark = ThemeData(
      backgroundColor: darkGreyClr,
      primaryColor: darkGreyClr,
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(color: darkGreyClr));
}

TextStyle get subHeadingStyle {
  return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Get.isDarkMode ? Colors.grey[400] : Colors.grey);
}

TextStyle get headingStyle {
  return TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
}

TextStyle get titleStyle {
  return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Get.isDarkMode ? Colors.white : Colors.black);
}

TextStyle get subTitleStyle {
  return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Get.isDarkMode ? Colors.grey[100] : Colors.grey[600]);
}
