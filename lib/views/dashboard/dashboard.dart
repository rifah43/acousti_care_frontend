import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acousti_care_frontend/providers/health_data_provider.dart';
import 'package:acousti_care_frontend/providers/user_provider.dart';
import 'package:acousti_care_frontend/views/dashboard/health_recommendation.dart';
import 'package:acousti_care_frontend/views/dashboard/risk_prediction.dart';
import 'package:acousti_care_frontend/views/dashboard/trend_visualization.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshDashboard();
  }

  Future<void> _refreshDashboard() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final healthDataProvider = Provider.of<HealthDataProvider>(context, listen: false);

      await Future.wait([
        healthDataProvider.fetchRiskPredictions(),
        healthDataProvider.fetchTrendData(userProvider.activeProfileId),
        healthDataProvider.fetchRecommendations(),
      ]);

      if (mounted) {
        _showSuccessMessage('Dashboard updated successfully');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Error updating dashboard: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Health Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const RiskPrediction(),
            const SizedBox(height: 24),
            const TrendVisualization(),
            const SizedBox(height: 24),
            const HealthRecommendations(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return _isLoading
        ? Positioned.fill(
            child: Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refreshDashboard,
              child: _buildDashboardContent(),
            ),
            _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }
}
