import 'package:flutter/material.dart';
import 'package:acousti_care_frontend/views/styles.dart';
import 'package:provider/provider.dart';
import 'package:acousti_care_frontend/providers/health_data_provider.dart';

class HealthRecommendations extends StatelessWidget {
  const HealthRecommendations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final healthData = Provider.of<HealthDataProvider>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Health Recommendations', style: subtitleStyle(context, AppColors.textPrimary)),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: healthData.recommendations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.check_circle, color: AppColors.success),
                  title: Text(
                    healthData.recommendations[index],
                    style: normalTextStyle(context, AppColors.textPrimary),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

