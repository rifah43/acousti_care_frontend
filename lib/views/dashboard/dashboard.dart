import 'package:acousti_care_frontend/views/dashboard/health_recommendation.dart';
import 'package:flutter/material.dart';
import 'package:acousti_care_frontend/views/dashboard/risk_prediction.dart';
import 'package:acousti_care_frontend/views/dashboard/trend_visualization.dart';
import 'package:acousti_care_frontend/views/styles.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Health Dashboard', style: titleStyle(context, AppColors.textPrimary)),
            const SizedBox(height: 20),
            const RiskPrediction(),
            const SizedBox(height: 20),
            const TrendVisualization(),
            const SizedBox(height: 20),
            const HealthRecommendations(),
          ],
        ),
      ),
    );
  }
}

