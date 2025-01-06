import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acousti_care_frontend/providers/user_provider.dart';
import 'package:acousti_care_frontend/views/styles.dart';
import 'package:acousti_care_frontend/views/bottom_navbar.dart';
import 'package:acousti_care_frontend/views/custom_topbar.dart';
import 'package:acousti_care_frontend/views/dashboard/dashboard.dart';
import 'package:acousti_care_frontend/views/voiceRecorder/record_voice.dart';
import 'package:acousti_care_frontend/views/drawerPages/notification_page.dart';
import 'package:acousti_care_frontend/views/drawerPages/help_support.dart';
import 'package:acousti_care_frontend/views/drawerPages/feedback_page.dart';
import 'package:acousti_care_frontend/views/drawerPages/terms_and_privacy.dart';
import 'package:acousti_care_frontend/views/drawerPages/switchProfile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).initialize();
    });
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.iconPrimary),
      title: Text(
        title,
        style: normalTextStyle(context, AppColors.textPrimary),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  Widget _buildDrawer(String userName) {
    return Drawer(
      child: Container(
        color: AppColors.backgroundPrimary,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.buttonPrimary,
                    child: Icon(
                      Icons.person,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: nameTitleStyle(context, Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildDrawerItem(
              icon: Icons.notifications,
              title: "Notifications",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.support,
              title: "Help & Support",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpSupportPage()),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.feedback,
              title: "Feedback",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackPage()),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.policy,
              title: "Terms & Privacy",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsPrivacyPage()),
              ),
            ),
            const Divider(color: AppColors.divider, thickness: 1),
            _buildDrawerItem(
              icon: Icons.switch_account,
              title: "Switch Profile",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SwitchProfile()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Welcome to AcoustiCare!',
            style: titleStyle(context, AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Your voice-powered diabetes management companion',
            style: subtitleStyle(context, AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RecordVoice()),
              );
            },
            style: primaryButtonStyle(),
            icon: const Icon(Icons.mic, size: 20),
            label: const Text('Record Voice & Predict'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.currentUser?.name ?? 'User';

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: CustomTopBar(
          title: "Welcome, $userName",
          hasDrawer: true,
          hasSettings: true,
          withBack: false,
        ),
        drawer: _buildDrawer(userName),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: 4),
                Expanded(
                  child: Dashboard(),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: const BottomNavbar(),
      ),
    );
  }
}