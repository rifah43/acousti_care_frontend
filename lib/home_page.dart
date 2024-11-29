import 'package:acousti_care_frontend/views/bottom_navbar.dart';
import 'package:acousti_care_frontend/views/custom_topbar.dart';
import 'package:acousti_care_frontend/views/drawerPages/feedback_page.dart';
import 'package:acousti_care_frontend/views/drawerPages/help_support.dart';
import 'package:acousti_care_frontend/views/drawerPages/notification_page.dart';
import 'package:acousti_care_frontend/views/drawerPages/switchProfile.dart';
import 'package:acousti_care_frontend/views/drawerPages/terms_and_privacy.dart';
import 'package:acousti_care_frontend/views/styles.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(
        title: "Home Page",
        hasDrawer: true,
        hasSettings: true,
        withBack: false,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.backgroundPrimary,
              ),
              child: Text(
                'User Name',
                style: TextStyle(
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
              leading: const Icon(Icons.policy),
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
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20), 
            Text(
              'Welcome to AcoustiCare!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Add your RecordVoice widget or other widgets here
            SizedBox(height: 20), 
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(), // Ensure BottomNavbar is properly implemented
    );
  }
}
