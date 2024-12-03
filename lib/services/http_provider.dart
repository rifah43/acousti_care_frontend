import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiProvider {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<http.Response> getRequest(String endpoint) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    try {
      final response = await http.get(url);
      _handleResponse(response);
      return response;
    } catch (e) {
      throw Exception('Failed to make GET request: $e');
    }
  }

  Future<http.Response> postRequest(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      _handleResponse(response);
      return response;
    } catch (e) {
      throw Exception('Failed to make POST request: $e');
    }
  }

  Future<http.Response> putRequest(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      _handleResponse(response);
      return response;
    } catch (e) {
      throw Exception('Failed to make PUT request: $e');
    }
  }

  Future<http.Response> deleteRequest(String endpoint) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    try {
      final response = await http.delete(url);
      _handleResponse(response);
      return response;
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

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      _handleResponse(response);
      return response;
    } catch (e) {
      throw Exception('Failed to upload audio file: $e');
    }
  }

  void _handleResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error: ${response.statusCode} ${response.body}');
    }
  }
}

