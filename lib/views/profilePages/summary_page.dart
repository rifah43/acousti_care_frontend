import 'dart:convert';

import 'package:acousti_care_frontend/home_page.dart';
import 'package:acousti_care_frontend/services/http_provider.dart';
import 'package:cache_manager/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:acousti_care_frontend/views/styles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SummaryPage extends StatelessWidget {
  final String name;
  final String age;
  final double weight;
  final double height;
  final String gender;
  final double? bmi;
  final String mail;

  const SummaryPage({
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    this.bmi,
    required this.mail,
    super.key,
  });

  Future<void> saveCache(
    String activeProfileId
  ) async {
    WriteCache.setString(key: "activeProfileId", value: activeProfileId);
  }

  Future<void> _createUser(BuildContext context) async {
    final Map<String, dynamic> profileData = {
      'name': name,
      'age': int.parse(age),
      'weight': weight,
      'height': height,
      'gender': gender,
      'bmi': bmi ?? 0.0,
      'isActive': true,
      'email': mail,
    };

    try {
      final response = await ApiProvider().postRequest('add-profile', profileData);
      final responsebody = jsonDecode(response.body);
      if (response.statusCode == 201) {
        _showSnackBar(context, 'Profile created successfully!', AppColors.success);
        saveCache(responsebody[0]["user_id"]);
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
      } else if (response.statusCode == 400) {
        _showSnackBar(context, responsebody[0]["message"], AppColors.alert);
      } else {
        _showSnackBar(context, 'Error creating profile.', AppColors.error);
      }
    } catch (e) {
      _showSnackBar(context, 'Error: $e', AppColors.error);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView( 
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSummaryRow(
                  context,
                  icon: FontAwesomeIcons.user,
                  label: 'Name',
                  value: name,
                ),
                _buildSummaryRow(
                  context,
                  icon: FontAwesomeIcons.solidCalendarAlt,
                  label: 'Age',
                  value: age,
                ),
                _buildSummaryRow(
                  context,
                  icon: FontAwesomeIcons.weight,
                  label: 'Weight',
                  value: '${weight.toStringAsFixed(1)} kg',
                ),
                _buildSummaryRow(
                  context,
                  icon: FontAwesomeIcons.rulerVertical,
                  label: 'Height',
                  value: '${height.toStringAsFixed(1)} cm',
                ),
                _buildSummaryRow(
                  context,
                  icon: FontAwesomeIcons.venusMars,
                  label: 'Gender',
                  value: gender,
                ),
                if (bmi != null)
                  _buildSummaryRow(
                    context,
                    icon: FontAwesomeIcons.heartbeat,
                    label: 'BMI',
                    value: bmi!.toStringAsFixed(1),
                  ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => _createUser(context),
                  style: secondaryButtonStyle(),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text('Add Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 20),
          const SizedBox(width: 12),
          Expanded( // Use Expanded to ensure proper space allocation
            flex: 1,
            child: Text(
              '$label: ',
              style: subtitleStyle(context, AppColors.textPrimary),
            ),
          ),
          Expanded( // Use another Expanded for the value
            flex: 2,
            child: Text(
              value,
              style: normalTextStyle(context, AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
