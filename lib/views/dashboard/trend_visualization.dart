import 'package:flutter/material.dart';
import 'package:acousti_care_frontend/views/styles.dart';
import 'package:provider/provider.dart';
import 'package:acousti_care_frontend/providers/health_data_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class TrendVisualization extends StatelessWidget {
  const TrendVisualization({super.key});

  @override
  Widget build(BuildContext context) {
    final healthData = Provider.of<HealthDataProvider>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Health Trends', style: subtitleStyle(context, AppColors.textPrimary)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: healthData.riskTrend.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      color: AppColors.buttonPrimary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

