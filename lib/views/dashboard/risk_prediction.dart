import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acousti_care_frontend/providers/health_data_provider.dart';
import 'package:acousti_care_frontend/views/styles.dart';

class RiskPrediction extends StatelessWidget {
  const RiskPrediction({super.key});

  Color _getRiskColor(double percentage) {
    if (percentage < 25) return AppColors.success;
    if (percentage < 75) return Colors.orange;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthDataProvider>(
      builder: (context, healthData, _) {
        final riskLevel = healthData.riskLevel;
        final riskPercentage = healthData.riskPercentage;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'T2DM Risk Prediction',
                  style: subtitleStyle(context, AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your current risk level: $riskLevel',
                  style: normalTextStyle(context, AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: riskPercentage / 100,
                  backgroundColor: AppColors.backgroundSecondary.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getRiskColor(riskPercentage),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Risk: ${riskPercentage.toStringAsFixed(1)}%',
                  style: boldTextStyle(context, AppColors.textPrimary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
