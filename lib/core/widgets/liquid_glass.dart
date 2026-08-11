import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Soft liquid-glass wash. Keep opacity low (~0.10) so it stays aesthetic, not harsh.
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = AppTheme.cardRadius,
    this.opacity = 0.10,
    this.blurSigma = 14,
    this.padding,
    this.borderOpacity = 0.22,
  });

  final Widget child;
  final double borderRadius;
  final double opacity;
  final double blurSigma;
  final EdgeInsetsGeometry? padding;
  final double borderOpacity;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: opacity + 0.04),
                Colors.white.withValues(alpha: opacity),
                const Color(0xFFEAF3EE).withValues(alpha: opacity),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: borderOpacity)),
            boxShadow: const [
              BoxShadow(color: Color(0x0A223948), blurRadius: 18, offset: Offset(0, 8)),
            ],
          ),
          child: padding == null ? child : Padding(padding: padding!, child: child),
        ),
      ),
    );
  }
}

/// Full-screen liquid sheen sitting under page content.
class LiquidGlassAtmosphere extends StatelessWidget {
  const LiquidGlassAtmosphere({super.key, this.opacity = 0.10});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF7FAF8),
                  const Color(0xFFEAF3EE),
                  const Color(0xFFF6F3EF),
                  AppTheme.softGreen.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
          Positioned(
            top: -80,
            left: -40,
            child: _Blob(size: 280, color: const Color(0xFF9FD4B5).withValues(alpha: opacity)),
          ),
          Positioned(
            top: 120,
            right: -60,
            child: _Blob(size: 320, color: const Color(0xFFB9D9C8).withValues(alpha: opacity)),
          ),
          Positioned(
            bottom: -40,
            left: 40,
            child: _Blob(size: 260, color: const Color(0xFFE8DCC8).withValues(alpha: opacity)),
          ),
          Positioned(
            bottom: 80,
            right: 20,
            child: _Blob(size: 200, color: const Color(0xFFD7EDE2).withValues(alpha: opacity)),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(color: Colors.white.withValues(alpha: opacity * 0.35)),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
