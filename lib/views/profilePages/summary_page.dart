import 'dart:convert';
import 'package:acousti_care_frontend/services/http_provider.dart';
import 'package:acousti_care_frontend/utils/device_helper.dart';
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
  final String password;

  const SummaryPage({
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    this.bmi,
    required this.mail,
    required this.password,
    super.key,
  });

  Future<void> saveCache(String activeProfileId) async {
    await WriteCache.setString(key: "activeProfileId", value: activeProfileId);
  }

  Future<Map<String, dynamic>> createUser(BuildContext context) async {
    final Map<String, dynamic> profileData = {
      'name': name,
      'age': int.parse(age),
      'weight': weight,
      'height': height,
      'gender': gender,
      'bmi': bmi ?? 0.0,
      'isActive': true,
      'email': mail,
      'password': password,
    };
    try {
      final String? deviceID = await DeviceHelper.getDeviceId();
      
      if (deviceID == null) {
        _showSnackBar(context, 'Device ID not available', AppColors.error);
        return {'success': false, 'message': 'Device ID not available'};
      }
      
      final response = await ApiProvider().postRequest('add-profile', profileData, headers: 
      {"X-Device-ID": deviceID});
      final responseBody = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        print(responseBody);
        final userId = responseBody[0]['user_id'];
        print("jijiji");
        print(userId.runtimeType);
        if (userId != null) {
          await saveCache(userId.toString());
          _showSnackBar(context, 'Profile created successfully!', AppColors.success);
          return {'success': true, 'message': 'Profile created successfully'};
        } else {
          _showSnackBar(context, 'Invalid response format from server', AppColors.error);
          return {'success': false, 'message': responseBody["message"]};
        }
      } else {
        final errorMessage = responseBody['message'] ?? 'Error creating profile';
        _showSnackBar(context, errorMessage, AppColors.error);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      _showSnackBar(context, 'Error: $e', AppColors.error);
      return {'success': false, 'message': e.toString()};
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, {
    required IconData icon, 
    required String label, 
    required String value
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: Text(
              '$label: ',
              style: subtitleStyle(context, AppColors.textPrimary),
            ),
          ),
          Expanded(
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