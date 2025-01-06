import 'dart:convert';

import 'package:acousti_care_frontend/models/user.dart';
import 'package:acousti_care_frontend/providers/user_provider.dart';
import 'package:acousti_care_frontend/services/http_provider.dart';
import 'package:acousti_care_frontend/views/custom_topbar.dart';
import 'package:acousti_care_frontend/views/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

double getScreenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

class SwitchProfile extends StatefulWidget {
  const SwitchProfile({super.key});

  @override
  State<SwitchProfile> createState() => _SwitchProfileState();
}

class _SwitchProfileState extends State<SwitchProfile> {
  final ApiProvider _apiProvider = ApiProvider();
  List<User> profiles = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await _apiProvider.getRequest('device-profiles');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> profilesList = responseData['data']['profiles'];

        setState(() {
          profiles = profilesList.map((profileData) => User.fromJson(profileData)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load profiles: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load profiles: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _switchProfile(String? userId) async {
    if (userId == null || userId.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid user ID'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    try {
      final response = await _apiProvider.postRequest('switch-profile', {'user_id': userId});

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          profiles = profiles.map((profile) => profile.copyWith(isActive: profile.id == userId)).toList();
        });

        final activeProfile = profiles.firstWhere((p) => p.id == userId);
        if (context.mounted) {
          Provider.of<UserProvider>(context, listen: false).setCurrentUser(activeProfile);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Profile switched successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to switch profile');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to switch profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(title: 'Switch Profile', hasDrawer: false, withBack: true, hasSettings: false),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error!, style: normalTextStyle(context, AppColors.error), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                style: primaryButtonStyle(),
                onPressed: _loadProfiles,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (profiles.isEmpty) {
      return Center(
        child: Text('No profiles found', style: subtitleStyle(context, AppColors.textPrimary)),
      );
    }

    return ListView.builder(
      itemCount: profiles.length,
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (context, index) {
        final profile = profiles[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.backgroundSecondary,
              child: Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                style: boldTextStyle(context, Colors.white),
              ),
            ),
            title: Text(profile.name, style: nameTitleStyle(context, AppColors.textPrimary)),
            subtitle: Text(
              '${profile.email}\nAge: ${profile.age} | Gender: ${profile.gender}',
              style: subtitleStyle(context, AppColors.textPrimary),
            ),
            trailing: profile.isActive
                ? const Icon(Icons.check_circle, color: AppColors.success)
                : const Icon(Icons.radio_button_unchecked, color: AppColors.iconSecondary),
            onTap: () => _switchProfile(profile.id),
          ),
        );
      },
    );
  }
}
