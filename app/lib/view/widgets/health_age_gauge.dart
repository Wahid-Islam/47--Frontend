import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';

/// Semi-circular gauge comparing actual age vs. computed Health Age.
class HealthAgeGauge extends StatelessWidget {
  const HealthAgeGauge({super.key, required this.actualAge, required this.healthAge, required this.locale});

  final double actualAge;
  final double healthAge;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GaugePainter(
        actualAge: actualAge,
        healthAge: healthAge,
        trackColor: AppTheme.border,
        progressColor: healthAge > actualAge ? AppTheme.riskModerate : AppTheme.primary,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              healthAge.round().toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 48),
            ),
            Text(
              AppStrings.t('healthAge', locale),
              style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.actualAge,
    required this.healthAge,
    required this.trackColor,
    required this.progressColor,
  });

  final double actualAge;
  final double healthAge;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10);
    final radius = math.min(size.width, size.height) / 2 - 8;
    const start = math.pi * 0.75;
    const sweep = math.pi * 1.5;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final progress = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, track);

    final minAge = (actualAge - 10).clamp(20, 90).toDouble();
    final maxAge = (actualAge + 15).clamp(30, 100).toDouble();
    final t = ((healthAge - minAge) / (maxAge - minAge)).clamp(0.0, 1.0).toDouble();
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep * t, false, progress);

    final actualT = ((actualAge - minAge) / (maxAge - minAge)).clamp(0.0, 1.0).toDouble();
    final angle = start + sweep * actualT;
    final marker = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));
    canvas.drawCircle(marker, 7, Paint()..color = AppTheme.foreground);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.healthAge != healthAge || oldDelegate.actualAge != actualAge;
}
