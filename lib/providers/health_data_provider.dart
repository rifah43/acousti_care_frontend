import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'dart:convert';

class HealthRecommendationsService {
  static const MEDLINE_API = 'https://health.gov/myhealthfinder/api/v3/';
  static const NIH_API = 'https://health.data.nih.gov/api/3/action/';

  Future<List<String>> fetchHealthRecommendations(String riskLevel) async {
    List<String> recommendations = [];

    try {
      await Future.wait([
        _fetchFromMedlinePlus(recommendations),
        _fetchFromNIH(recommendations),
        _fetchFromWHO(recommendations)
      ]);

      if (recommendations.isEmpty) {
        recommendations = _getLocalRecommendations(riskLevel);
      }

      return _processRecommendations(recommendations);
    } catch (e) {
      return _getLocalRecommendations(riskLevel);
    }
  }

  Future<void> _fetchFromMedlinePlus(List<String> recommendations) async {
    try {
      final response = await http.get(
        Uri.parse('${MEDLINE_API}topicsearch.json?keyword=diabetes+management')
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resources = data['Result']['Resources']['Resource'];
        
        for (var resource in resources) {
          if (resource['Type'] == 'Health Topic' &&
              resource['Title'].toString().toLowerCase().contains('diabetes')) {
            recommendations.add(resource['Title']);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchFromNIH(List<String> recommendations) async {
    try {
      final response = await http.get(
        Uri.parse('${NIH_API}datastore_search?resource_id=diabetes-prevention')
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['result']['records'];

        for (var record in results) {
          if (record['recommendation'] != null) {
            recommendations.add(record['recommendation']);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchFromWHO(List<String> recommendations) async {
    try {
      final response = await http.get(Uri.parse('https://www.who.int/diabetes/en/'));

      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final elements = document.querySelectorAll('.diabetes-recommendations li');

        for (var element in elements) {
          recommendations.add(element.text.trim());
        }
      }
    } catch (_) {}
  }

  List<String> _processRecommendations(List<String> recommendations) {
    final keywords = ['diabetes', 'blood sugar', 'diet', 'exercise', 'lifestyle'];
    return recommendations
        .toSet()
        .where((rec) => keywords.any((k) => rec.toLowerCase().contains(k)))
        .map((rec) {
          rec = rec.trim();
          return rec.endsWith('.') ? rec : '$rec.';
        })
        .take(10)
        .toList();
  }

  List<String> _getLocalRecommendations(String riskLevel) {
    const highRisk = [
      'Monitor blood sugar levels frequently.',
      'Follow a strict low-glycemic diet.',
      'Engage in regular physical activity.',
      'Take prescribed medications as directed.'
    ];

    const moderateRisk = [
      'Schedule regular check-ups with your doctor.',
      'Maintain a balanced diet.',
      'Exercise for at least 30 minutes daily.',
      'Monitor your weight regularly.'
    ];

    const lowRisk = [
      'Eat a healthy, balanced diet.',
      'Stay active with regular exercise.',
      'Monitor your health metrics regularly.'
    ];

    switch (riskLevel.toLowerCase()) {
      case 'high':
        return highRisk;
      case 'moderate':
        return moderateRisk;
      default:
        return lowRisk;
    }
  }
}


class HealthDataProvider with ChangeNotifier {
  final HealthRecommendationsService _recommendationService = HealthRecommendationsService();
  
  List<String> _recommendations = [];
  List<Map<String, dynamic>> _trendData = [];
  Map<String, dynamic> _riskPredictions = {};
  String _riskLevel = 'default';
  bool _isLoading = false;

  List<String> get recommendations => _recommendations;
  List<Map<String, dynamic>> get trendData => _trendData;
  Map<String, dynamic> get riskPredictions => _riskPredictions;
  String get riskLevel => _riskLevel;
  bool get isLoading => _isLoading;

  get riskTrend => null;

  get riskPercentage => null;

  void updateRiskLevel(String newLevel) {
    _riskLevel = newLevel;
    notifyListeners();
  }
  Future<void> fetchTrendData(String? userId) async {
    if (userId == null) return;

    try {
      _trendData = await _getMockTrendData();
      notifyListeners();
    } catch (e) {
      _trendData = _getDefaultTrendData();
      notifyListeners();
    }
  }

  Future<void> fetchRecommendations() async {
    try {
      _isLoading = true;
      notifyListeners();

      _recommendations = await _recommendationService.fetchHealthRecommendations(_riskLevel);
    } catch (_) {
      _recommendations = _recommendationService._getLocalRecommendations(_riskLevel);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRiskPredictions() async {
    try {
      _isLoading = true;
      notifyListeners();

      _riskPredictions = await _getMockRiskPrediction();
      _riskLevel = _riskPredictions['risk_level'] ?? 'default';
    } catch (_) {
      _riskPredictions = _getDefaultRiskPredictions();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

   Future<List<Map<String, dynamic>>> _getMockTrendData() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.generate(7, (index) {
      return {
        'date': DateTime.now().subtract(Duration(days: 6 - index)).toIso8601String(),
        'risk_level': index < 3 ? 'low' : (index < 5 ? 'moderate' : 'high'),
        'value': 0.3 + (index * 0.1)
      };
    });
  }

  Future<Map<String, dynamic>> _getMockRiskPrediction() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'risk_level': 'moderate',
      'confidence': 0.85,
      'last_updated': DateTime.now().toIso8601String(),
      'details': {'factors': ['BMI', 'age']}
    };
  }

  List<Map<String, dynamic>> _getDefaultTrendData() {
    return [
      {'date': DateTime.now().toIso8601String(), 'risk_level': 'moderate', 'value': 0.5}
    ];
  }

  Map<String, dynamic> _getDefaultRiskPredictions() {
    return {
      'risk_level': 'moderate',
      'confidence': 0.75,
      'last_updated': DateTime.now().toIso8601String()
    };
  }
}