

import 'dart:convert';

import 'package:acousti_care_frontend/models/user.dart';
import 'package:acousti_care_frontend/services/auth_service.dart';
import 'package:acousti_care_frontend/services/http_provider.dart';
import 'package:cache_manager/cache_manager.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  String? _activeProfileId;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  String? get activeProfileId => _activeProfileId;
  bool get isLoading => _isLoading;

  // Initialize provider by loading cached profile
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await loadActiveProfileId();
      if (_activeProfileId != null) {
        await loadUserData();
      }
    } catch (e) {
      debugPrint('Error initializing UserProvider: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load active profile ID from cache
  Future<void> loadActiveProfileId() async {
    try {
      final cachedId = await ReadCache.getString(key: 'activeProfileId');
      _activeProfileId = cachedId;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading active profile ID: $e');
    }
  }

  // Save active profile ID to cache
  Future<void> saveActiveProfileId(String profileId) async {
    try {
      await WriteCache.setString(key: 'activeProfileId', value: profileId);
      _activeProfileId = profileId;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving active profile ID: $e');
      throw Exception('Failed to save profile ID');
    }
  }

  // Load user data from API using active profile ID
  Future<void> loadUserData() async {
    if (_activeProfileId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Assuming you have an API endpoint to get user data
      final response = await ApiProvider().getRequest('get-profile/$_activeProfileId', additionalHeaders: {
        'X-Device-ID': (await AuthService.getDeviceId()) ?? '',
      });
      final userData = jsonDecode(response.body);

      if (response.statusCode == 200 && userData != null) {
        _currentUser = User.fromJson(userData['user']);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setCurrentUser(User user) async {
    try {
      _currentUser = user;
      if (user.id != null) {
        await saveActiveProfileId(user.id.toString());
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting current user: $e');
      throw Exception('Failed to set current user');
    }
  }

  // Update existing user data
  Future<void> updateUser(User updatedUser) async {
    try {
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user: $e');
      throw Exception('Failed to update user');
    }
  }

  // Clear user data and cached profile ID
  Future<void> clearUser() async {
    try {
      _currentUser = null;
      _activeProfileId = null;
      await DeleteCache.deleteKey('activeProfileId');
      await AuthService.clearAuth();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing user data: $e');
      throw Exception('Failed to clear user data');
    }
  }
}