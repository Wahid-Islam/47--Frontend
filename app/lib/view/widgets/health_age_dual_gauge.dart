import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';

/// Side-by-side circular comparison of the computed Health Age vs. the
/// user's actual (chronological) age, for the "Your Health Age" card on
/// Personal Insights (US 1.2). Both rings share the same 0-100 scale so
/// their relative fill length is directly comparable.
class HealthAgeDualGauge extends StatelessWidget {
  const HealthAgeDualGauge({
    super.key,
    required this.healthAge,
    required this.actualAge,
    required this.locale,
  });

  final int healthAge;
  final int actualAge;
  final String locale;

  static const double _scaleMax = 100;

  @override
  Widget build(BuildContext context) {
    final healthAgeColor = healthAge > actualAge ? AppTheme.riskModerate : AppTheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _AgeCircle(value: healthAge, color: healthAgeColor, label: AppStrings.t('healthAge', locale)),
        _AgeCircle(
          value: actualAge,
          color: AppTheme.secondaryCompare,
          label: AppStrings.t('actualAge', locale),
        ),
      ],
    );
  }
}

class _AgeCircle extends StatelessWidget {
  const _AgeCircle({required this.value, required this.color, required this.label});

  final int value;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ratio = (value / HealthAgeDualGauge._scaleMax).clamp(0.0, 1.0).toDouble();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(value: 1, strokeWidth: 12, color: AppTheme.border),
              CircularProgressIndicator(
                value: ratio,
                strokeWidth: 12,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
              Text('$value', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 36)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
