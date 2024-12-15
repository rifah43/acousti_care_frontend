import 'package:acousti_care_frontend/home_page.dart';
import 'package:acousti_care_frontend/models/user.dart';
import 'package:acousti_care_frontend/views/custom_topbar.dart';
import 'package:acousti_care_frontend/views/profilePages/dots_indicator.dart';
import 'package:acousti_care_frontend/views/profilePages/height_weight_gender_page.dart';
import 'package:acousti_care_frontend/views/profilePages/name_age_page.dart';
import 'package:acousti_care_frontend/views/profilePages/summary_page.dart';
import 'package:acousti_care_frontend/views/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acousti_care_frontend/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final TextEditingController _passwordController = TextEditingController();
  String _gender = 'Select Gender';

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name should only contain letters and spaces';
    }
    return null;
  }

  String? _validatemail(String? value) {
    if (value == null || value.isEmpty) {
      return 'mail is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid mail address';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid number';
    }
    if (age < 12 || age > 120) {
      return 'Age must be between 18 and 120';
    }
    return null;
  }

  String? _validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Weight is required';
    }
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid number';
    }
    if (weight < 10 || weight > 600) {
      return 'Weight must be between 20 and 300 kg';
    }
    return null;
  }

  String? _validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Height is required';
    }
    final height = double.tryParse(value);
    if (height == null) {
      return 'Please enter a valid number';
    }
    if (height < 80 || height > 350) {
      return 'Height must be between 100 and 250 cm';
    }
    return null;
  }

  String? _validateGender(String? value) {
    if (value == null || value.isEmpty || value == 'Select Gender') {
      return 'Please select a gender';
    }
    return null;
  }


  void _nextPage() {
    if (_currentPage == -1) {
      setState(() => _currentPage = 0);
    } else if (_currentPage == 0) {
      final nameValidation = _validateName(_nameController.text.trim());
      final ageValidation = _validateAge(_ageController.text.trim());
      final mailValidation = _validatemail(_mailController.text.trim());

      if (nameValidation != null) {
        _showSnackBar(nameValidation);
        return;
      }
      if (ageValidation != null) {
        _showSnackBar(ageValidation);
        return;
      }
      if (mailValidation != null) {
        _showSnackBar(mailValidation);
        return;
      }
      _goToNextPage();
    } else if (_currentPage == 1) {
      final weightValidation = _validateWeight(_weightController.text.trim());
      final heightValidation = _validateHeight(_heightController.text.trim());
      final genderValidation = _validateGender(_gender);

      if (weightValidation != null) {
        _showSnackBar(weightValidation);
        return;
      }
      if (heightValidation != null) {
        _showSnackBar(heightValidation);
        return;
      }
      if (genderValidation != null) {
        _showSnackBar(genderValidation);
        return;
      }
      _goToNextPage();
    } else {
      _saveProfile();
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

void _saveProfile() async {
    // Perform final validation of all fields
    final nameValidation = _validateName(_nameController.text.trim());
    final ageValidation = _validateAge(_ageController.text.trim());
    final mailValidation = _validatemail(_mailController.text.trim());
    final weightValidation = _validateWeight(_weightController.text.trim());
    final heightValidation = _validateHeight(_heightController.text.trim());
    final genderValidation = _validateGender(_gender);

    // Check if any validation fails
    if (nameValidation != null || 
        ageValidation != null || 
        mailValidation != null ||
        weightValidation != null || 
        heightValidation != null || 
        genderValidation != null) {
      _showSnackBar('Please check all fields are valid');
      return;
    }

    final summaryPage = SummaryPage(
      name: _nameController.text.trim(),
      age: _ageController.text.trim(),
      weight: double.tryParse(_weightController.text.trim()) ?? 0.0,
      height: double.tryParse(_heightController.text.trim()) ?? 0.0,
      gender: _gender,
      mail: _mailController.text.trim(),
      bmi: _calculateBMI(),
      password: _passwordController.text.trim(),
    );
    
    final result = await summaryPage.createUser(context);
    
    if (result['success']) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final profileData = _getProfileData();
      final user = User.fromJson(profileData);
      userProvider.setCurrentUser(user);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isProfileSetup', true);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }
  }

  Map<String, dynamic> _getProfileData() {
    final weight = double.tryParse(_weightController.text.trim()) ?? 0.0;
    final height = double.tryParse(_heightController.text.trim()) ?? 0.0;
    final bmi = height > 0 ? weight / ((height / 100) * (height / 100)) : 0.0;
    return {
      'name': _nameController.text.trim(),
      'age': int.parse(_ageController.text.trim()),
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
                          passwordController: _passwordController,
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
                          password: _passwordController.text.trim(),
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
          widget.isAddingNewProfile 
              ? Text('Add New Profile', style: titleStyle(context, AppColors.textSecondary))
              : Text('Welcome to AcoustiCare', style: titleStyle(context, AppColors.textSecondary)),
          const SizedBox(height: 20),
          Text('Let\'s get started by setting up your profile', style: subtitleStyle(context, AppColors.textPrimary)),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _nextPage,
            style: primaryButtonStyle(),
            child: Text('Get Started', style: boldTextStyle(context, AppColors.buttonText)),
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
          if (_currentPage == 2)
            ElevatedButton.icon(
              onPressed: _saveProfile,
              style: primaryButtonStyle(),
              icon: const Icon(Icons.check),
              label: Text('Finish', style: boldTextStyle(context, AppColors.buttonText)),
            ),
        ],
      ),
    );
  }
}
