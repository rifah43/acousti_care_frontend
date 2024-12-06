import 'package:flutter/material.dart';
import 'package:acousti_care_frontend/views/styles.dart';
import 'package:provider/provider.dart';
import 'package:acousti_care_frontend/providers/health_data_provider.dart';

class RiskPrediction extends StatelessWidget {
  const RiskPrediction({super.key});

  @override
  Widget build(BuildContext context) {
    final healthData = Provider.of<HealthDataProvider>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('T2DM Risk Prediction', style: subtitleStyle(context, AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'Your current risk level: ${healthData.riskLevel}',
              style: normalTextStyle(context, AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: healthData.riskPercentage / 100,
              backgroundColor: AppColors.backgroundSecondary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                healthData.riskPercentage < 50 ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Risk: ${healthData.riskPercentage.toStringAsFixed(1)}%',
              style: boldTextStyle(context, AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

