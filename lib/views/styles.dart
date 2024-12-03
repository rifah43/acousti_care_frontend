import 'package:flutter/material.dart';

double getScreenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

TextStyle normalTextStyle(BuildContext context, Color color) {
  return TextStyle(
    color: color,
    fontSize: 14,
  );
}

TextStyle boldTextStyle(BuildContext context, Color color) {
  return TextStyle(
    color: color,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
}

TextStyle nameTitleStyle(BuildContext context, Color color) {
  return TextStyle(
      color: color,
      fontSize: 16,
      fontWeight: FontWeight.bold);
}

TextStyle titleStyle(BuildContext context, Color color) {
  return TextStyle(
      color: color,
      fontSize: getScreenWidth(context) * 0.08,
      fontWeight: FontWeight.w600);
}

TextStyle subtitleStyle(BuildContext context, Color color) {
  return TextStyle(
      color: color,
      fontSize: 14,
      fontWeight: FontWeight.w400);
}

class AppColors {
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFF4A90E2);
  static const Color iconPrimary = Color(0xFF2C3E50);
  static const Color iconSecondary = Color(0xFF4A90E2);
  static const Color buttonPrimary = Color(0xFF50B689);
  static const Color buttonSecondary = Color(0xFF48A999);
  static const Color buttonText = Color(0xFFFFFFFF);
  static const Color drawerBackground = Color(0xFF2C3E50);
  static const Color drawerIcon = Color(0xFFFFFFFF);
  static const Color drawerText = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF50B689);
  static const Color textHighlight = Color(0xFFF1C40F);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color error = Color.fromARGB(255, 231, 60, 60);
  static const Color alert = Color.fromARGB(255, 248, 173, 9);
  static const Color success = Color(0xFF50B689);
}

ButtonStyle primaryButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonPrimary,
    foregroundColor: AppColors.buttonText,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
  );
}

ButtonStyle secondaryButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonSecondary,
    foregroundColor: AppColors.buttonText,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
  );
}

