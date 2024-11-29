import 'package:acousti_care_frontend/views/styles.dart';
import 'package:flutter/material.dart';

class HeightWeightGenderPage extends StatefulWidget {
  final TextEditingController heightController;
  final TextEditingController weightController;
  final String selectedGender;
  final ValueChanged<String> onGenderChanged;

  const HeightWeightGenderPage({
    required this.heightController,
    required this.weightController,
    required this.selectedGender,
    required this.onGenderChanged,
    super.key,
  });

  @override
  _HeightWeightGenderPageState createState() => _HeightWeightGenderPageState();
}

class _HeightWeightGenderPageState extends State<HeightWeightGenderPage> {
  late String selectedGender;

  final List<String> genderOptions = [
    'Select Gender',
    'Male',
    'Female',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Ensure the initial selected gender is valid
    selectedGender = genderOptions.contains(widget.selectedGender)
        ? widget.selectedGender
        : genderOptions[0]; // Default to 'Select Gender' if invalid
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.height),
                Text(
                  'Height (cm)',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.heightController,
              keyboardType: TextInputType.number,
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
            const Row(
              children: [
                Icon(Icons.monitor_weight),
                Text(
                  'Weight (kg)',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.weightController,
              keyboardType: TextInputType.number,
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
            ),
            const SizedBox(height: 16),
            const Text(
              'Gender',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: selectedGender,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: AppColors.buttonPrimary),
                ),
              ),
              items: genderOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedGender = newValue;
                  });
                  widget.onGenderChanged(selectedGender);
                }
              },
              icon: const Icon(Icons.arrow_drop_down,
                  color: AppColors.buttonPrimary),
              style: const TextStyle(color: Colors.black),
              dropdownColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
