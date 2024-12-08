import 'package:flutter/material.dart';
import 'package:acousti_care_frontend/views/styles.dart';
import 'package:provider/provider.dart';
import 'package:acousti_care_frontend/providers/health_data_provider.dart';
import 'package:acousti_care_frontend/views/custom_topbar.dart';

class HealthRecommendations extends StatelessWidget {
  const HealthRecommendations({super.key});

  @override
  Widget build(BuildContext context) {
    final healthData = Provider.of<HealthDataProvider>(context);

    return Scaffold(
      appBar: const CustomTopBar(
        title: 'Health Recommendations',
        withBack: true, 
        hasSettings: true, 
      ),
      body: SingleChildScrollView(  
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Recommendations', 
                    style: subtitleStyle(context, AppColors.textPrimary)
                  ),
                  const SizedBox(height: 16),
                  if (healthData.recommendations.isEmpty)
                    Center(
                      child: Text(
                        'No recommendations available',
                        style: normalTextStyle(context, AppColors.textSecondary),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: healthData.recommendations.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 24,
                            ),
                          ),
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
          ),
        ),
      ),
    );
  }
}