import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';

/// Side-by-side Health Age vs Actual Age rings.
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
    final isBad = healthAge > actualAge;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _AgeCircle(
          value: healthAge,
          progress: (healthAge / _scaleMax).clamp(0.0, 1.0),
          accent: isBad ? AppTheme.riskHigh : AppTheme.primary,
          track: isBad ? const Color(0xFFF5E3E2) : const Color(0xFFE7EFE9),
          label: AppStrings.t('healthAge', locale),
          labelColor: isBad ? AppTheme.riskHigh : const Color(0xFF16804C),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(AppStrings.t('vsLabel', locale), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF7C8794))),
        ),
        _AgeCircle(
          value: actualAge,
          progress: (actualAge / _scaleMax).clamp(0.0, 1.0),
          accent: AppTheme.secondaryCompare,
          track: const Color(0xFFEDF0F2),
          label: AppStrings.t('actualAge', locale),
          labelColor: const Color(0xFF566171),
        ),
      ],
    );
  }
}

class _AgeCircle extends StatelessWidget {
  const _AgeCircle({
    required this.value,
    required this.progress,
    required this.accent,
    required this.track,
    required this.label,
    required this.labelColor,
  });

  final int value;
  final double progress;
  final Color accent;
  final Color track;
  final String label;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: CustomPaint(
            painter: _ConicRingPainter(progress: progress, accent: accent, track: track),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -2,
                      color: AppTheme.foreground,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: labelColor)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConicRingPainter extends CustomPainter {
  _ConicRingPainter({required this.progress, required this.accent, required this.track});

  final double progress;
  final Color accent;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final stroke = 14.0;
    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, trackPaint);

    final accentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = accent
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, accentPaint);

    // Soft white inset ring.
    final inset = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = Colors.white.withValues(alpha: 0.78);
    canvas.drawCircle(center, radius - stroke - 2, inset);
  }

  @override
  bool shouldRepaint(covariant _ConicRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.accent != accent || oldDelegate.track != track;
  }
}
