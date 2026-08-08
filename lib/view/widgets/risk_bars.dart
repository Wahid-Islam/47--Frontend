import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/chips.dart';

/// Two stacked bars comparing a "You" value vs. a "National average" value
/// — used both for a single cause-of-death risk (percentages) and for the
/// Health Age national comparison (plain numbers), via the [suffix] and
/// [decimals] knobs. Colors are intentionally distinct: [AppTheme.primary]
/// (green, "You") vs [AppTheme.secondaryCompare] (neutral grey, "National
/// average") so the two series are never confused at a glance.
class RiskCompareBar extends StatelessWidget {
  const RiskCompareBar({
    super.key,
    required this.personal,
    required this.national,
    required this.personalLabel,
    required this.nationalLabel,
    this.suffix = '%',
    this.decimals = 1,
  });

  final double personal;
  final double national;
  final String personalLabel;
  final String nationalLabel;
  final String suffix;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    final max = [personal, national, 1.0].reduce((a, b) => a > b ? a : b);
    return Column(
      children: [
        _bar(personalLabel, personal, max, AppTheme.primary),
        const SizedBox(height: 10),
        _bar(nationalLabel, national, max, AppTheme.secondaryCompare),
      ],
    );
  }

  Widget _bar(String label, double value, double max, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
            Text(
              '${value.toStringAsFixed(decimals)}$suffix',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (value / max).clamp(0, 1).toDouble(),
            minHeight: 12,
            backgroundColor: AppTheme.border,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// A single contributing-factor row with a score bar and a [RiskChip].
class FactorBar extends StatelessWidget {
  const FactorBar({super.key, required this.label, required this.score, required this.impact});

  final String label;
  final double score;
  final String impact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
              RiskChip(impact),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: score.clamp(0, 1).toDouble(),
              minHeight: 10,
              backgroundColor: AppTheme.border,
              color: AppTheme.riskColor(impact),
            ),
          ),
        ],
      ),
    );
  }
}
