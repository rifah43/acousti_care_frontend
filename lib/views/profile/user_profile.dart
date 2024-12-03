import 'package:flutter/material.dart';
import 'package:acousti_care_frontend/views/styles.dart';
import 'package:provider/provider.dart';
import 'package:acousti_care_frontend/providers/user_provider.dart';
import 'package:acousti_care_frontend/views/custom_topbar.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Scaffold(
      appBar: const CustomTopBar(
        title: 'User Profile',
        withBack: true,
        hasSettings: false,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildProfileItem('Name', user.name),
                  _buildProfileItem('Age', user.age.toString()),
                  _buildProfileItem('Gender', user.gender),
                  _buildProfileItem('Height', '${user.height} cm'),
                  _buildProfileItem('Weight', '${user.weight} kg'),
                  _buildProfileItem('BMI', user.bmi.toStringAsFixed(1)),
                  _buildProfileItem('Email', user.email),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to edit profile page
                      },
                      style: primaryButtonStyle(),
                      child: Text('Edit Profile', style: boldTextStyle(context, AppColors.buttonText)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

