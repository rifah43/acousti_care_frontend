import 'package:acousti_care_frontend/views/styles.dart';
import 'package:flutter/material.dart';

class HeightWeightSettingPage extends StatefulWidget {
  final String height;
  final String weight;
  final Function(String, String) onUpdate;

  const HeightWeightSettingPage({super.key, required this.height, required this.weight, required this.onUpdate});

  @override
  State<HeightWeightSettingPage> createState() => _HeightWeightSettingPageState();
}

class _HeightWeightSettingPageState extends State<HeightWeightSettingPage> {
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController(text: widget.height);
    _weightController = TextEditingController(text: widget.weight);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Height', style: nameTitleStyle(context, AppColors.textPrimary)),
          TextField(
            controller: _heightController,
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
              labelText: 'Enter your height',
            ),
          ),
          const SizedBox(height: 16),
          Text('Weight', style: nameTitleStyle(context, AppColors.textPrimary)),
          TextField(
            controller: _weightController,
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
              labelText: 'Enter your weight',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              widget.onUpdate(_heightController.text, _weightController.text);
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
