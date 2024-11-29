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
  // Background Colors
  static const Color backgroundPrimary = Color(0xFFFFFFFF); // White for main background
  static const Color backgroundSecondary = Color(0xFF4A90E2); // Light gray for secondary backgrounds

  // Icon Colors
  static const Color iconPrimary = Color(0xFF2C3E50); // Deep navy for primary icons
  static const Color iconSecondary = Color(0xFF4A90E2); // Soft blue for secondary icons

  // Button Colors
  static const Color buttonPrimary = Color(0xFF50B689); // Cool green for primary buttons
  static const Color buttonSecondary = Color(0xFF48A999); // Muted teal for secondary buttons
  static const Color buttonText = Color(0xFFFFFFFF); // White text on buttons

  // Drawer Colors
  static const Color drawerBackground = Color(0xFF2C3E50); // Deep navy for the drawer background
  static const Color drawerIcon = Color(0xFFFFFFFF); // White for drawer icons
  static const Color drawerText = Color(0xFFFFFFFF); // White for drawer text

  // Text Colors
  static const Color textPrimary = Color(0xFF2C3E50); // Deep navy for primary text
  static const Color textSecondary = Color(0xFF50B689); // Cool green for secondary text
  static const Color textHighlight = Color(0xFFF1C40F); // Warm yellow for highlights and special emphasis

  // Divider Colors
  static const Color divider = Color(0xFFE0E0E0); // Light gray for dividers

  // Alert/Notification Colors
  static const Color error = Color.fromARGB(255, 231, 60, 60); // Soft red for alerts and errors
  static const Color alert = Color.fromARGB(255, 248, 173, 9);
  static const Color success = Color(0xFF50B689); // Cool green for success notifications
}

// Button Style Functions
ButtonStyle primaryButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonPrimary, // Background color
    foregroundColor: AppColors.buttonText, // Text color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8), // Rounded corners
    ),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28), // Button padding
  );
}

ButtonStyle secondaryButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonSecondary, // Background color
    foregroundColor: AppColors.buttonText, // Text color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8), // Rounded corners
    ),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24), // Button padding
  );
}
