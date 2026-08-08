import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';

/// 12-month Health Age projection line chart for the Action Roadmap
/// (Epic 1.0 handoff): a solid green "follow the plan" line trending down
/// vs. a dashed purple "no change" line trending up, both starting from
/// today's computed Health Age.
class HealthAgeProjectionChart extends StatelessWidget {
  const HealthAgeProjectionChart({
    super.key,
    required this.healthAge,
    required this.projectedFollowPlan,
    required this.projectedNoChange,
    required this.locale,
  });

  final int healthAge;
  final int projectedFollowPlan;
  final int projectedNoChange;
  final String locale;

  static const int _months = 12;

  List<FlSpot> _spotsFor(int endValue) {
    return List.generate(_months + 1, (month) {
      final t = month / _months;
      final value = healthAge + (endValue - healthAge) * t;
      return FlSpot(month.toDouble(), value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final followSpots = _spotsFor(projectedFollowPlan);
    final noChangeSpots = _spotsFor(projectedNoChange);
    final minY = [projectedFollowPlan, healthAge, projectedNoChange].reduce((a, b) => a < b ? a : b) - 3;
    final maxY = [projectedFollowPlan, healthAge, projectedNoChange].reduce((a, b) => a > b ? a : b) + 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: minY.toDouble(),
              maxY: maxY.toDouble(),
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 34, interval: 5),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 3,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('${value.toInt()}m', style: const TextStyle(fontSize: 11)),
                    ),
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: followSpots,
                  isCurved: true,
                  color: AppTheme.chartFollowPlan,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: noChangeSpots,
                  isCurved: true,
                  color: AppTheme.chartNoChange,
                  barWidth: 3,
                  dashArray: const [8, 5],
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _legendDot(AppTheme.chartFollowPlan),
            const SizedBox(width: 6),
            Text(AppStrings.t('followPlan', locale), style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 20),
            _legendDot(AppTheme.chartNoChange),
            const SizedBox(width: 6),
            Text(AppStrings.t('noChange', locale), style: const TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 16,
      height: 4,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
    );
  }
}
