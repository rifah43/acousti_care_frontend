import 'package:flutter/material.dart';
import 'package:acousti_care_frontend/views/styles.dart';
import 'package:provider/provider.dart';
import 'package:acousti_care_frontend/providers/health_data_provider.dart';
import 'package:acousti_care_frontend/providers/user_provider.dart';
import 'package:acousti_care_frontend/views/custom_topbar.dart';

class HealthRecommendations extends StatefulWidget {
  const HealthRecommendations({super.key});

  @override
  State<HealthRecommendations> createState() => _HealthRecommendationsState();
}

class _HealthRecommendationsState extends State<HealthRecommendations> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecommendations());
  }

  void _loadRecommendations() {
    final userId = Provider.of<UserProvider>(context, listen: false).activeProfileId;
    if (userId == null) {
      _showError('No active profile selected');
      return;
    }

    final healthProvider = Provider.of<HealthDataProvider>(context, listen: false);
    healthProvider.fetchTrendData(userId).catchError((error) {
      _handleError(error);
    });
  }

  void _handleError(dynamic error) {
    String message = error is NoDataException
        ? error.message
        : 'Failed to load health recommendations. Please try again later.';
    _showError(message);
  }

  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _loadRecommendations,
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, List<String> recommendations, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.textSecondary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: nameTitleStyle(context, AppColors.textPrimary),
                ),
              ],
            ),
            const Divider(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          recommendations[index],
                          style: normalTextStyle(context, AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsContent(Map<String, List<String>> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryCard(
          'Diet Recommendations',
          recommendations['diet'] ?? [],
          Icons.restaurant_menu,
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          'Lifestyle Changes',
          recommendations['lifestyle'] ?? [],
          Icons.energy_savings_leaf,
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          'Exercise Suggestions',
          recommendations['exercise'] ?? [],
          Icons.fitness_center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.recommend_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Recommendations Available',
              style: subtitleStyle(context, AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Record your voice to get personalized\nhealth recommendations',
              style: normalTextStyle(context, AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: primaryButtonStyle(),
              onPressed: _loadRecommendations,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(
        title: 'Health Recommendations',
        withBack: true,
        hasSettings: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadRecommendations(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Consumer<HealthDataProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final recommendations = provider.healthRecommendations;
              if (recommendations == null || recommendations.isEmpty) {
                return _buildEmptyState();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Personalized Health Plan',
                    style: nameTitleStyle(context, AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Based on your latest voice analysis',
                    style: subtitleStyle(context, AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  _buildRecommendationsContent(recommendations),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}