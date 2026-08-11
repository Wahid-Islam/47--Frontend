import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';

/// 12-month Health Age projection.
class HealthAgeProjectionChart extends StatelessWidget {
  const HealthAgeProjectionChart({
    super.key,
    required this.healthAge,
    required this.actualAge,
    required this.projectedFollowPlan,
    required this.projectedNoChange,
    required this.locale,
    this.habitProgress = 1,
  });

  final int healthAge;
  final int actualAge;
  final int projectedFollowPlan;
  final int projectedNoChange;
  final String locale;

  /// Fraction of today's roadmap habits completed, in `0…1`.
  final double habitProgress;

  static const int _months = 12;

  double get _clampedProgress => habitProgress.clamp(0.0, 1.0);

  /// Full-plan floor: actual age (or current Health Age if already at/below it).
  double get _targetAge {
    final engineTarget = projectedFollowPlan.toDouble();
    final chronological = actualAge.toDouble();
    // Prefer falling toward actual age; never aim above today's Health Age.
    final target = chronological < healthAge ? chronological : healthAge.toDouble();
    // Keep engine value if it's somehow between healthAge and actual age.
    if (engineTarget >= target && engineTarget <= healthAge) return engineTarget;
    return target;
  }

  /// End Health Age for the green line given current checklist progress.
  double get _followEnd {
    final p = _clampedProgress;
    if (p <= 0 || healthAge <= _targetAge) return healthAge.toDouble();
    // First tick shows a clear drop; full checklist reaches actual age.
    final eased = 0.15 + 0.85 * p;
    return healthAge + (_targetAge - healthAge) * eased;
  }

  List<FlSpot> _followSpots() {
    final end = _followEnd;
    final p = _clampedProgress;
    // Shape mirrors the HTML prototype: slow start, steeper mid, settle at end.
    const midWeights = [0.0, 0.25, 0.55, 1.0];
    return List.generate(_months + 1, (month) {
      final t = month / _months;
      final segment = t * 3;
      final i = segment.floor().clamp(0, 2);
      final local = segment - i;
      final shaped = midWeights[i] + (midWeights[i + 1] - midWeights[i]) * local;
      final improvement = (healthAge - end) * shaped * (p == 0 ? 0.0 : 1.0);
      return FlSpot(month.toDouble(), healthAge - improvement);
    });
  }

  List<FlSpot> _noChangeSpots() {
    return List.generate(_months + 1, (month) {
      final t = month / _months;
      final value = healthAge + (projectedNoChange - healthAge) * t;
      return FlSpot(month.toDouble(), value);
    });
  }

  List<FlSpot> _actualAgeSpots() {
    return List.generate(_months + 1, (month) => FlSpot(month.toDouble(), actualAge.toDouble()));
  }

  /// Snap chart bounds to [interval] so Y labels never collide (e.g. 24 vs 25).
  static (double, double) _niceYRange(Iterable<num> values, {double interval = 5}) {
    final lo = values.reduce((a, b) => a < b ? a : b).toDouble();
    final hi = values.reduce((a, b) => a > b ? a : b).toDouble();
    final minY = ((lo - 1) / interval).floor() * interval;
    var maxY = ((hi + 1) / interval).ceil() * interval;
    if (maxY <= minY) maxY = minY + interval;
    return (minY, maxY);
  }

  @override
  Widget build(BuildContext context) {
    final followSpots = _followSpots();
    final noChangeSpots = _noChangeSpots();
    final actualSpots = _actualAgeSpots();
    final followEnd = _followEnd.round();
    final (minY, maxY) = _niceYRange([
      followEnd,
      healthAge,
      projectedNoChange,
      projectedFollowPlan,
      actualAge,
    ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 5,
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: 5,
                    getTitlesWidget: (value, meta) {
                      // Only show clean interval ticks (skip orphan min/max like 24).
                      final tick = (value / 5).round() * 5;
                      if ((value - tick).abs() > 0.01) return const SizedBox.shrink();
                      return Text(
                        tick.toString(),
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      );
                    },
                  ),
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
                      child: Text(
                        AppStrings.tn('monthShort', locale, value.toInt()),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: followSpots,
                  isCurved: true,
                  color: AppTheme.chartFollowPlan,
                  barWidth: 3.5,
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: actualSpots,
                  isCurved: false,
                  color: AppTheme.secondaryCompare,
                  barWidth: 2,
                  dashArray: const [2, 4],
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
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _legend(AppTheme.chartFollowPlan, AppStrings.t('followPlan', locale), solid: true),
            _legend(AppTheme.secondaryCompare, AppStrings.t('actualAge', locale), solid: false),
            _legend(AppTheme.chartNoChange, AppStrings.t('noChange', locale), solid: false),
          ],
        ),
      ],
    );
  }

  Widget _legend(Color color, String label, {required bool solid}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: solid ? null : Border.all(color: color.withValues(alpha: 0.01)),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
