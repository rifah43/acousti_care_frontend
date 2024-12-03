import 'package:flutter/foundation.dart';

class HealthDataProvider with ChangeNotifier {
  String _riskLevel = 'Low';
  double _riskPercentage = 25.0;
  List<double> _riskTrend = [20, 22, 25, 23, 24, 25];
  List<String> _recommendations = [
    'Maintain a balanced diet',
    'Exercise regularly',
    'Get adequate sleep',
    'Manage stress levels',
  ];

  String get riskLevel => _riskLevel;
  double get riskPercentage => _riskPercentage;
  List<double> get riskTrend => _riskTrend;
  List<String> get recommendations => _recommendations;

  void updateRiskLevel(String newLevel, double newPercentage) {
    _riskLevel = newLevel;
    _riskPercentage = newPercentage;
    notifyListeners();
  }

  void updateRiskTrend(List<double> newTrend) {
    _riskTrend = newTrend;
    notifyListeners();
  }

  void updateRecommendations(List<String> newRecommendations) {
    _recommendations = newRecommendations;
    notifyListeners();
  }
}

