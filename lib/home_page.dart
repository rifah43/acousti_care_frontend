import 'package:acousti_care_frontend/views/bottom_navbar.dart';
import 'package:acousti_care_frontend/views/custom_topbar.dart';
import 'package:acousti_care_frontend/views/drawerPages/feedback_page.dart';
import 'package:acousti_care_frontend/views/drawerPages/help_support.dart';
import 'package:acousti_care_frontend/views/drawerPages/notification_page.dart';
import 'package:acousti_care_frontend/views/drawerPages/switchProfile.dart';
import 'package:acousti_care_frontend/views/drawerPages/terms_and_privacy.dart';
import 'package:acousti_care_frontend/views/styles.dart';
import 'package:acousti_care_frontend/views/dashboard/dashboard.dart';
import 'package:acousti_care_frontend/views/voiceRecorder/record_voice.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acousti_care_frontend/providers/user_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.currentUser?.name ?? 'User';

    return Scaffold(
      appBar: CustomTopBar(
        title: "Welcome, $userName",
        hasDrawer: true,
        hasSettings: true,
        withBack: false,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.backgroundPrimary,
              ),
              child: Text(
                userName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Notifications"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.support),
              title: const Text("Help & Support"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpSupportPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text("Feedback"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedbackPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.policy),
              title: const Text("Terms & Privacy"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsPrivacyPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.switch_account),
              title: const Text("Switch Profile"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SwitchProfile()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
              'Welcome to AcoustiCare!',
              style: titleStyle(context, AppColors.textPrimary),
            ),
              ],
            ),
            const SizedBox(height: 20),
            const Dashboard(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RecordVoice()),
                );
              },
              style: primaryButtonStyle(),
              child: const Text('Record Voice'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(),
    );
  }
}

