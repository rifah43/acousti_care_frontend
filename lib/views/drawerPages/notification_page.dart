import 'package:flutter/material.dart';
import 'dart:convert'; 
import 'package:http/http.dart' as http;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  Future<List<String>> fetchNotifications() async {
    // Replace with your API endpoint
    final response = await http.get(Uri.parse('https://api.example.com/notifications'));

    if (response.statusCode == 200) {
      final List<dynamic> notificationsData = jsonDecode(response.body);
      return notificationsData.map((notification) => notification.toString()).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: FutureBuilder<List<String>>(
        future: fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('No new notifications'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.notification_important),
                  title: Text(snapshot.data![index]),
                );
              },
            );
          } else {
            return const Center(child: Text('No new notifications'));
          }
        },
      ),
    );
  }
}
