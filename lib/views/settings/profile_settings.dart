import 'package:acousti_care_frontend/views/styles.dart';
import 'package:flutter/material.dart';

class ProfileSettingPage extends StatefulWidget {
  final String name;
  final String age;
  final Function(String, String) onUpdate;

  const ProfileSettingPage({super.key, required this.name, required this.age, required this.onUpdate});

  @override
  State<ProfileSettingPage> createState() => _ProfileSettingPageState();
}

class _ProfileSettingPageState extends State<ProfileSettingPage> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _ageController = TextEditingController(text: widget.age);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name', style: nameTitleStyle(context, AppColors.textPrimary)),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelStyle: normalTextStyle(context, AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: AppColors.buttonPrimary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              labelText: 'Enter your name',
            ),
          ),
          const SizedBox(height: 16),
          Text('Age', style: nameTitleStyle(context, AppColors.textPrimary)),
          TextField(
            controller: _ageController,
            decoration: InputDecoration(
              labelStyle: normalTextStyle(context, AppColors.textPrimary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: AppColors.buttonPrimary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              labelText: 'Enter your age',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              widget.onUpdate(_nameController.text, _ageController.text);
              Navigator.pop(context);
            },
            style: primaryButtonStyle(),
            child: const Text('Save Profile'),
          ),
        ],
      ),
    );
  }
}
