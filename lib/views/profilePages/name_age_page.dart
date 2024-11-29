import 'package:flutter/material.dart';
import 'package:acousti_care_frontend/views/styles.dart'; 

class NameAndAgePage extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController mailController;

  const NameAndAgePage({
    required this.nameController,
    required this.ageController,
    required this.mailController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            children: [
              Text(
            'Name',
            style: TextStyle(fontSize: 18),
          ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Enter your name',
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
            ),
          ),
          const SizedBox(height: 20), // Space between fields
          
          const Row(
            children: [
              Text(
            'Age',
            style: TextStyle(fontSize: 18),
          ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: ageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter your age',
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
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Text(
            'Email',
            style: TextStyle(fontSize: 18),
          ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: mailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Enter your email',
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
            ),
          ),
        ],
      ),
    );
  }
}
