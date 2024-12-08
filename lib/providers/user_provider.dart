import 'package:flutter/foundation.dart';
import 'package:acousti_care_frontend/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  String? _activeProfileId;

  User? get currentUser => _currentUser;
  String? get activeProfileId => _activeProfileId;

  Future<void> loadActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    _activeProfileId = prefs.getString('activeProfileId');
    notifyListeners();
  }

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void updateUser(User updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    _activeProfileId = null;
    notifyListeners();
  }
}