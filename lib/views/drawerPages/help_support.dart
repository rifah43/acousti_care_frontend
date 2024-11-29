import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help & Support")),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text("FAQs"),
          ),
          ListTile(
            leading: Icon(Icons.contact_support),
            title: Text("Contact Support"),
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text("App Tutorials"),
          ),
        ],
      ),
    );
  }
}