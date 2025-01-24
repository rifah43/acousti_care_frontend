import 'dart:convert';
import 'dart:io';
import 'package:acousti_care_frontend/models/trend_data.dart';
import 'package:acousti_care_frontend/services/http_provider.dart';
import 'package:flutter/material.dart';

class HealthDataProvider with ChangeNotifier {
  final ApiProvider _apiProvider = ApiProvider();
  List<TrendData> _trendData = [];
  Map<String, dynamic>? _trendStatistics;
  Map<String, List<String>>? _healthRecommendations;
  bool _isLoading = false;

  List<TrendData> get trendData => _trendData;
  Map<String, dynamic>? get trendStatistics => _trendStatistics;
  Map<String, List<String>>? get healthRecommendations => _healthRecommendations;
  bool get isLoading => _isLoading;

  Future<void> fetchTrendData(String userId, {String timeframe = '30days'}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiProvider.getRequest(
        'trends/$userId?days=${_getDaysFromTimeframe(timeframe)}',
      );

      if (response.statusCode == 404) {
        throw Exception('No trend data found.');
      }

      final data = jsonDecode(response.body);
      _trendData = (data['trend_data'] as List)
          .map((item) => TrendData.fromJson(item))
          .toList();
      _trendStatistics = data['statistics'];
      
      // After getting trend data, fetch health recommendations
      await _fetchHealthRecommendations(_trendData.last.riskLevel);
    } catch (e) {
      debugPrint('Error fetching trend data: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchHealthRecommendations(double riskLevel) async {
    try {
      final response = await _apiProvider.getRequest(
        'recommendations?risk_level=$riskLevel',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _healthRecommendations = {
          'diet': List<String>.from(data['diet_suggestions'] ?? []),
          'lifestyle': List<String>.from(data['lifestyle_recommendations'] ?? []),
          'exercise': List<String>.from(data['exercise_recommendations'] ?? [])
        };
      }
    } catch (e) {
      debugPrint('Error fetching health recommendations: $e');
      // Fallback recommendations if API fails
      _setFallbackRecommendations(riskLevel);
    }
  }

  void _setFallbackRecommendations(double riskLevel) {
    final isHighRisk = riskLevel > 0.7;
    final isMediumRisk = riskLevel > 0.4 && riskLevel <= 0.7;

    _healthRecommendations = {
      'diet': _getDietRecommendations(isHighRisk, isMediumRisk),
      'lifestyle': _getLifestyleRecommendations(isHighRisk, isMediumRisk),
      'exercise': _getExerciseRecommendations(isHighRisk, isMediumRisk)
    };
  }

  List<String> _getDietRecommendations(bool isHighRisk, bool isMediumRisk) {
    if (isHighRisk) {
      return [
        'Limit carbohydrate intake to 45-60g per meal',
        'Include more fiber-rich foods in your diet',
        'Choose foods with low glycemic index',
        'Avoid sugary drinks and processed foods',
        'Include lean proteins in every meal',
        'Eat plenty of non-starchy vegetables'
      ];
    } else if (isMediumRisk) {
      return [
        'Monitor portion sizes of carbohydrate-rich foods',
        'Include more whole grains in your diet',
        'Eat a variety of colorful vegetables daily',
        'Choose healthy fats like nuts and avocados',
        'Limit processed food intake'
      ];
    } else {
      return [
        'Maintain a balanced diet with plenty of vegetables',
        'Choose whole grains over refined grains',
        'Include healthy proteins in your meals',
        'Stay hydrated throughout the day'
      ];
    }
  }

  List<String> _getLifestyleRecommendations(bool isHighRisk, bool isMediumRisk) {
    if (isHighRisk) {
      return [
        'Monitor blood sugar levels regularly',
        'Get adequate sleep (7-9 hours per night)',
        'Manage stress through relaxation techniques',
        'Consider joining a diabetes prevention program',
        'Regular medical check-ups are important'
      ];
    } else if (isMediumRisk) {
      return [
        'Maintain regular sleep schedule',
        'Practice stress management',
        'Consider regular health screenings',
        'Stay active throughout the day'
      ];
    } else {
      return [
        'Maintain healthy sleep habits',
        'Stay active and engaged in daily activities',
        'Practice regular stress management'
      ];
    }
  }

  List<String> _getExerciseRecommendations(bool isHighRisk, bool isMediumRisk) {
    if (isHighRisk) {
      return [
        'Aim for 150 minutes of moderate exercise weekly',
        'Include both cardio and strength training',
        'Start slowly and gradually increase intensity',
        'Consider working with a fitness professional',
        'Monitor blood sugar before and after exercise'
      ];
    } else if (isMediumRisk) {
      return [
        'Get at least 30 minutes of exercise daily',
        'Mix up different types of physical activities',
        'Try walking after meals',
        'Include strength training twice a week'
      ];
    } else {
      return [
        'Stay physically active daily',
        'Find enjoyable ways to move more',
        'Include variety in your exercise routine'
      ];
    }
  }

  Future<Map<String, dynamic>> fetchMonthlyAnalysis(String userId) async {
    try {
      final response = await _apiProvider.getRequest('trends/monthly-analysis/$userId');
      if (response.statusCode == 404) {
        throw const NoDataException('No health data available for analysis');
      }
      if (response.statusCode != 200) {
        throw const HttpException('Failed to fetch health data');
      }
      final data = jsonDecode(response.body);
      if (data == null || data['monthly_analysis'] == null) {
        throw const NoDataException('No analysis data available');
      }
      return data['monthly_analysis'];
    } catch (e) {
      debugPrint('Error fetching monthly analysis: $e');
      if (e is NoDataException) {
        rethrow;
      }
      throw Exception('Failed to load health recommendations');
    }
  }

  int _getDaysFromTimeframe(String timeframe) {
    switch (timeframe) {
      case '7days':
        return 7;
      case '90days':
        return 90;
      default:
        return 30;
    }
  }

  void reset() {
    _trendData = [];
    _trendStatistics = null;
    _healthRecommendations = null;
    _isLoading = false;
    notifyListeners();
  }
}

class NoDataException implements Exception {
  final String message;
  const NoDataException(this.message);
  
  @override
  String toString() => message;
}