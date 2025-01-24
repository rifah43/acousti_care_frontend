import 'package:acousti_care_frontend/models/trend_data.dart';
import 'package:acousti_care_frontend/providers/health_data_provider.dart';
import 'package:acousti_care_frontend/providers/user_provider.dart';
import 'package:acousti_care_frontend/views/custom_topbar.dart';
import 'package:acousti_care_frontend/views/styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrendVisualization extends StatefulWidget {
  const TrendVisualization({super.key});

  @override
  State<TrendVisualization> createState() => _TrendVisualizationState();
}

class _TrendVisualizationState extends State<TrendVisualization> {
  String _selectedTimeframe = '30days';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTrendData());
  }

  Future<void> _loadTrendData() async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).activeProfileId;
      if (userId == null) {
        throw Exception('User ID not found. Please select a profile.');
      }
      await Provider.of<HealthDataProvider>(context, listen: false)
          .fetchTrendData(userId, timeframe: _selectedTimeframe);

      if (Provider.of<HealthDataProvider>(context, listen: false).trendData.isEmpty) {
        throw Exception('No trend data found.');
      }
    } catch (e) {
      String errorMessage = e.toString();
      String displayMessage = errorMessage.contains('404') 
          ? 'No trend data found for the selected profile.' 
          : 'Error loading trend data: $e';
      Color backgroundColor = AppColors.error;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(displayMessage),
            backgroundColor: backgroundColor,
          ),
        );
      }
    }
  }

  List<FlSpot> _getTrendSpots(List<TrendData> data) {
    return data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.riskLevel * 100);
    }).toList();
  }

  Widget _buildTrendChart(List<TrendData> trendData) {
    if (trendData.isEmpty) {
      return Center(
        child: Text('No trend data available.', 
          style: normalTextStyle(context, AppColors.textPrimary)
        )
      );
    }

    final spots = _getTrendSpots(trendData);
    return Container(
      height: 380,
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 20,
                  verticalInterval: 1,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Text(
                      'T2DM Risk Level (%)',
                      style: normalTextStyle(context, AppColors.textPrimary),
                    ),
                    axisNameSize: 25,
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 20,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}',
                        style: normalTextStyle(context, AppColors.textPrimary),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Recording Date (Day/Month)',
                        style: normalTextStyle(context, AppColors.textPrimary),
                      ),
                    ),
                    axisNameSize: 25,
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= trendData.length || value.toInt() < 0) {
                          return const SizedBox.shrink();
                        }
                        final date = DateTime.parse(trendData[value.toInt()].timestamp);
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            '${date.day}/${date.month}',
                            style: normalTextStyle(context, AppColors.textPrimary),
                          ),
                        );
                      },
                      interval: 1,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Theme.of(context).primaryColor,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: Theme.of(context).primaryColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final date = DateTime.parse(
                            trendData[touchedSpot.x.toInt()].timestamp);
                        return LineTooltipItem(
                          '${date.day}/${date.month}\n',
                          boldTextStyle(context, AppColors.textPrimary),
                          children: [
                            TextSpan(
                              text: 'Risk: ${touchedSpot.y.toStringAsFixed(1)}%',
                              style: normalTextStyle(context, AppColors.textPrimary),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Chart description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'The chart shows T2DM risk levels over time. X-axis shows recording dates, Y-axis shows risk percentage (0-100%).',
              style: normalTextStyle(context, AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(Map<String, dynamic> stats) {
    if (stats.isEmpty) {
      return Center(
        child: Text('No statistics available.', 
          style: normalTextStyle(context, AppColors.textPrimary)
        )
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Risk Level Statistics',
              style: titleStyle(context, AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Average Risk', '${(stats['average_risk'] * 100).toStringAsFixed(1)}%'),
            _buildStatRow('Trend', stats['trend_direction'].toString().toUpperCase()),
            _buildStatRow('Recordings', stats['total_recordings'].toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: normalTextStyle(context, AppColors.textPrimary)),
          Text(value, style: boldTextStyle(context, AppColors.textPrimary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(
        title: "Trend Analysis",
        hasDrawer: false,
        hasSettings: false,
        withBack: true,
      ),
      body: Consumer<HealthDataProvider>(
        builder: (context, provider, child) {
          final trendData = provider.trendData;
          final stats = provider.trendStatistics;

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButton<String>(
                    value: _selectedTimeframe,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTimeframe = newValue!;
                      });
                      _loadTrendData();
                    },
                    items: [
                      DropdownMenuItem(
                        value: '7days',
                        child: Text('Last 7 days', 
                          style: normalTextStyle(context, AppColors.textPrimary)
                        ),
                      ),
                      DropdownMenuItem(
                        value: '30days',
                        child: Text('Last 30 days', 
                          style: normalTextStyle(context, AppColors.textPrimary)
                        ),
                      ),
                      DropdownMenuItem(
                        value: '90days',
                        child: Text('Last 90 days', 
                          style: normalTextStyle(context, AppColors.textPrimary)
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTrendChart(trendData),
                _buildStatistics(stats ?? {}),
              ],
            ),
          );
        },
      ),
    );
  }
}