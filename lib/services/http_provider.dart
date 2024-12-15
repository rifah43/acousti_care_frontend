import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiProvider {
  static const int timeoutDuration = 10; 
  
  String get _baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL not found in environment variables');
    }
    return url;
  }

  Future<http.Response> getRequest(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    try {
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw Exception('Network error: Please check your internet connection and server status. (${e.message})');
    } on TimeoutException {
      throw Exception('Request timed out: Server is not responding');
    } catch (e) {
      throw Exception('Failed to make GET request: $e');
    }
  }

  /// POST request
  Future<http.Response> postRequest(String endpoint, Map<String, dynamic> data, {Map<String, String>? headers}) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    try {
      print('Making POST request to: $url');
      print('Request body: ${jsonEncode(data)}');
      
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (headers != null) ...headers, // Add optional headers
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: timeoutDuration));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return _handleResponse(response);
    } on SocketException catch (e) {
      throw Exception('Network error: Please check your internet connection and server status. (${e.message})');
    } on TimeoutException {
      throw Exception('Request timed out: Server is not responding');
    } on FormatException catch (e) {
      throw Exception('Data format error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to make POST request: $e');
    }
  }

  /// PUT request
  Future<http.Response> putRequest(String endpoint, Map<String, dynamic> data, {Map<String, String>? headers}) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (headers != null) ...headers, // Add optional headers
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw Exception('Network error: Please check your internet connection and server status. (${e.message})');
    } on TimeoutException {
      throw Exception('Request timed out: Server is not responding');
    } catch (e) {
      throw Exception('Failed to make PUT request: $e');
    }
  }

  /// DELETE request
  Future<http.Response> deleteRequest(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    try {
      final response = await http.delete(url, headers: headers)
          .timeout(const Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw Exception('Network error: Please check your internet connection and server status. (${e.message})');
    } on TimeoutException {
      throw Exception('Request timed out: Server is not responding');
    } catch (e) {
      throw Exception('Failed to make DELETE request: $e');
    }
  }

  Future<http.Response> uploadAudioFile(String endpoint, File audioFile) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    try {
      var request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath(
        'audioFile', 
        audioFile.path,
      ));

      var streamedResponse = await request.send()
          .timeout(const Duration(seconds: timeoutDuration * 2)); // Longer timeout for file upload
      var response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw Exception('Network error: Please check your internet connection and server status. (${e.message})');
    } on TimeoutException {
      throw Exception('Request timed out: Server is not responding');
    } catch (e) {
      throw Exception('Failed to upload audio file: $e');
    }
  }

  http.Response _handleResponse(http.Response response) {
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    switch (response.statusCode) {
      case 400:
        throw Exception('Bad request: ${_parseErrorMessage(response.body)}');
      case 401:
        throw Exception('Unauthorized: Please log in again');
      case 403:
        throw Exception('Forbidden: You don\'t have permission to access this resource');
      case 404:
        throw Exception('Not found: The requested resource doesn\'t exist');
      case 500:
        throw Exception('Server error: Please try again later');
      default:
        throw Exception('Error ${response.statusCode}: ${_parseErrorMessage(response.body)}');
    }
  }

  String _parseErrorMessage(String body) {
    try {
      final parsed = jsonDecode(body);
      return parsed['message'] ?? parsed['error'] ?? body;
    } catch (e) {
      return body;
    }
  }
}