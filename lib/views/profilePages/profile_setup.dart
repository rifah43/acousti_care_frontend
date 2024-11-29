import 'package:acousti_care_frontend/views/custom_topbar.dart';
import 'package:acousti_care_frontend/views/profilePages/dots_indicator.dart';
import 'package:acousti_care_frontend/views/profilePages/height_weight_gender_page.dart';
import 'package:acousti_care_frontend/views/profilePages/name_age_page.dart';
import 'package:acousti_care_frontend/views/profilePages/summary_page.dart';
import 'package:acousti_care_frontend/views/styles.dart';
import 'package:flutter/material.dart';

class ProfileSetup extends StatefulWidget {
  final bool isAddingNewProfile;

  const ProfileSetup({super.key, required this.isAddingNewProfile});

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  int _currentPage = -1;
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String _gender = 'Select Gender';

  void _nextPage() {
    if (_currentPage == -1) {
      setState(() => _currentPage = 0);
    } else if (_currentPage == 0) {
      final name = _nameController.text.trim();
      final age = _ageController.text.trim();

      if (name.isEmpty || age.isEmpty) {
        _showSnackBar('Please enter your name and age');
        return;
      }
      _goToNextPage();
    } else if (_currentPage == 1) {
      final weight = double.tryParse(_weightController.text.trim()) ?? 0.0;
      final height = double.tryParse(_heightController.text.trim()) ?? 0.0;

      if (weight <= 0 || height <= 0 || _gender.isEmpty) {
        _showSnackBar('Please enter your weight, height, and select your gender');
        return;
      }
      _goToNextPage();
    } else {
      final profileData = _getProfileData();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SummaryPage(
            name: profileData['name']!,
            age: profileData['age']!,
            weight: profileData['weight']!,
            height: profileData['height']!,
            gender: profileData['gender']!,
            bmi: profileData['bmi']!,
            mail: profileData['mail']!,
          ),
        ),
      );
    }
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
    setState(() => _currentPage++);
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      setState(() => _currentPage--);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.alert),
    );
  }

  Map<String, dynamic> _getProfileData() {
    final weight = double.tryParse(_weightController.text.trim()) ?? 0.0;
    final height = double.tryParse(_heightController.text.trim()) ?? 0.0;
    final bmi = height > 0 ? weight / ((height / 100) * (height / 100)) : 0.0;
    return {
      'name': _nameController.text.trim(),
      'age': _ageController.text.trim(),
      'weight': weight,
      'height': height,
      'gender': _gender,
      'bmi': bmi,
      'mail': _mailController.text.trim(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: widget.isAddingNewProfile ? 'Add New Profile' : 'Get Started',
        withBack: widget.isAddingNewProfile,
        hasSettings: false,
        hasDrawer: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _currentPage == -1
                  ? _buildGetStartedScreen(context)
                  : PageView(
                      controller: _pageController,
                      onPageChanged: (int pageIndex) {
                        setState(() => _currentPage = pageIndex);
                      },
                      children: [
                        NameAndAgePage(
                          nameController: _nameController,
                          ageController: _ageController,
                          mailController: _mailController,
                        ),
                        HeightWeightGenderPage(
                          heightController: _heightController,
                          weightController: _weightController,
                          selectedGender: _gender,
                          onGenderChanged: (String newGender) {
                            setState(() => _gender = newGender);
                          },
                        ),
                        SummaryPage(
                          name: _nameController.text.trim(),
                          age: _ageController.text.trim(),
                          weight: double.tryParse(_weightController.text.trim()) ?? 0.0,
                          height: double.tryParse(_heightController.text.trim()) ?? 0.0,
                          gender: _gender,
                          mail: _mailController.text.trim(),
                          bmi: _calculateBMI(),
                        ),
                      ],
                    ),
            ),
            if (_currentPage >= 0) DotsIndicator(currentPage: _currentPage),
            _buildNavigationButtons(context),
          ],
        ),
      ),
    );
  }

  double _calculateBMI() {
    final weight = double.tryParse(_weightController.text.trim()) ?? 0.0;
    final height = double.tryParse(_heightController.text.trim()) ?? 0.0;
    return height > 0 ? weight / ((height / 100) * (height / 100)) : 0.0;
  }

  Widget _buildGetStartedScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.isAddingNewProfile ? Text('Welcome to AcoustiCare', style: titleStyle(context, AppColors.textSecondary)): Text('Start Adding New Profile', style: titleStyle(context, AppColors.textSecondary)),
          const SizedBox(height: 20),
          Text('Let\'s get started by setting up your profile', style: subtitleStyle(context, AppColors.textPrimary)),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _nextPage,
            style: primaryButtonStyle(),
            child: widget.isAddingNewProfile ? Text('Get Started', style: boldTextStyle(context, AppColors.buttonText)): Text('Add Profile', style: boldTextStyle(context, AppColors.buttonText)),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          if (_currentPage > 0)
            ElevatedButton.icon(
              onPressed: _previousPage,
              style: secondaryButtonStyle(),
              icon: const Icon(Icons.arrow_back),
              label: Text('Back', style: boldTextStyle(context, AppColors.buttonText)),
            ),
          const Spacer(),
          if (_currentPage < 2 && _currentPage != -1)
            ElevatedButton.icon(
              onPressed: _nextPage,
              style: secondaryButtonStyle(),
              icon: const Icon(Icons.arrow_forward),
              label: Text('Next', style: boldTextStyle(context, AppColors.buttonText)),
            ),
        ],
      ),
    );
  }
}
