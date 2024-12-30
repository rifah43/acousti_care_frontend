import 'package:cache_manager/cache_manager.dart';
import 'package:acousti_care_frontend/utils/device_helper.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _deviceIdKey = 'device_id';
  static const String _userIdKey = 'user_id';

  // Store token using cache manager
  static Future<void> setToken(String token) async {
    await WriteCache.setString(key: _tokenKey, value: token);
  }

  // Get token from cache manager
  static Future<String?> getToken() async {
    return await ReadCache.getString(key: _tokenKey);
  }

  // Remove token from cache manager
  static Future<void> removeToken() async {
    await DeleteCache.deleteKey(_tokenKey);
  }

  // Get device ID (uses DeviceHelper)
  static Future<String?> getDeviceId() async {
    String? deviceId = await ReadCache.getString(key: _deviceIdKey);
    if (deviceId == null) {
      deviceId = await DeviceHelper.getDeviceId();
      if (deviceId != null) {
        await WriteCache.setString(key: _deviceIdKey, value: deviceId);
      }
    }
    return deviceId;
  }

  // Initialize device
  static Future<void> initializeDevice() async {
    String? deviceId = await getDeviceId();
    if (deviceId == null) {
      throw Exception('Failed to initialize device ID');
    }
  }

  // Set active user ID
  static Future<void> setUserId(String userId) async {
    await WriteCache.setString(key: _userIdKey, value: userId);
  }

  // Get active user ID
  static Future<String?> getUserId() async {
    return await ReadCache.getString(key: _userIdKey);
  }

  // Remove user ID
  static Future<void> removeUserId() async {
    await DeleteCache.deleteKey(_userIdKey);
  }

  // Clear all auth data
  static Future<void> clearAuth() async {
    await removeToken();
    await removeUserId();
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    final userId = await getUserId();
    return token != null && userId != null;
  }

  // Save full auth data (used after successful login/registration)
  static Future<void> saveAuthData({
    required String token,
    required String userId,
  }) async {
    await setToken(token);
    await setUserId(userId);
  }
}