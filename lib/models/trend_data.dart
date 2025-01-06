class TrendData {
  final String timestamp;
  final double riskLevel;
  final Map<String, dynamic> features;

  TrendData({
    required this.timestamp,
    required this.riskLevel,
    required this.features,
  });

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      timestamp: json['timestamp'],
      riskLevel: json['risk_level'].toDouble(),
      features: Map<String, dynamic>.from(json['features'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'risk_level': riskLevel,
    'features': features,
  };
}