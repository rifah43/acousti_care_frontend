import 'package:flutter/material.dart';

class SwitchProfile extends StatelessWidget {
  // final List<User> profiles;
  // final String activeProfileId;
  // final Function(String) onProfileSelected;

  const SwitchProfile({
    super.key,
    // required this.profiles,
    // required this.activeProfileId,
    // required this.onProfileSelected,
  });

  @override
  Widget build(BuildContext context) {
    return const Text("jiji");
    // return ListView.builder(
    //   itemCount: profiles.length,
    //   itemBuilder: (context, index) {
    //     final profile = profiles[index];
    //     // Check if id is null and provide a default value if it is
    //     final profileId = profile.id ?? '';
    //     final isActive = profileId == activeProfileId;
        
    //     return ListTile(
    //       leading: CircleAvatar(
    //         child: Text(profile.name[0]),
    //       ),
    //       title: Text(profile.name),
    //       subtitle: Text(profile.email),
    //       trailing: isActive 
    //         ? const Icon(Icons.check_circle, color: Colors.green)
    //         : null,
    //       onTap: profileId.isNotEmpty 
    //         ? () => onProfileSelected(profileId)
    //         : null,  
    //     );
    //   },
    // );
  }
}