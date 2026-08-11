import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/liquid_glass.dart';

class LeafFoliagePainter extends CustomPainter {
  const LeafFoliagePainter({this.opacity = 1});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void leaf(Path path, Color color) {
      final paint = Paint()..color = color.withValues(alpha: color.a * opacity);
      canvas.drawPath(path, paint);
    }

    // Back layer — pale misty leaves.
    leaf(
      Path()
        ..moveTo(w * 0.05, h)
        ..quadraticBezierTo(w * 0.18, h * 0.35, w * 0.42, h * 0.55)
        ..quadraticBezierTo(w * 0.28, h * 0.85, w * 0.05, h)
        ..close(),
      const Color(0xFFB7D9C4),
    );
    leaf(
      Path()
        ..moveTo(w * 0.95, h)
        ..quadraticBezierTo(w * 0.78, h * 0.25, w * 0.55, h * 0.48)
        ..quadraticBezierTo(w * 0.72, h * 0.8, w * 0.95, h)
        ..close(),
      const Color(0xFFC5E3D0),
    );

    // Mid fern fronds.
    leaf(
      Path()
        ..moveTo(w * 0.22, h)
        ..quadraticBezierTo(w * 0.08, h * 0.45, w * 0.3, h * 0.12)
        ..quadraticBezierTo(w * 0.42, h * 0.4, w * 0.34, h)
        ..close(),
      const Color(0xFF6FB891),
    );
    leaf(
      Path()
        ..moveTo(w * 0.78, h)
        ..quadraticBezierTo(w * 0.92, h * 0.4, w * 0.68, h * 0.1)
        ..quadraticBezierTo(w * 0.58, h * 0.42, w * 0.66, h)
        ..close(),
      const Color(0xFF5AA87D),
    );

    // Front broad leaves.
    leaf(
      Path()
        ..moveTo(w * 0.35, h)
        ..quadraticBezierTo(w * 0.25, h * 0.55, w * 0.48, h * 0.28)
        ..quadraticBezierTo(w * 0.62, h * 0.55, w * 0.52, h)
        ..close(),
      const Color(0xFF2F8F5B),
    );
    leaf(
      Path()
        ..moveTo(w * 0.55, h)
        ..quadraticBezierTo(w * 0.7, h * 0.5, w * 0.58, h * 0.22)
        ..quadraticBezierTo(w * 0.45, h * 0.5, w * 0.48, h)
        ..close(),
      const Color(0xFF247A4C),
    );
  }

  @override
  bool shouldRepaint(covariant LeafFoliagePainter oldDelegate) => oldDelegate.opacity != opacity;
}

class KlSkylinePainter extends CustomPainter {
  const KlSkylinePainter({this.opacity = 0.18});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hill = Paint()..color = const Color(0xFF7FAF90).withValues(alpha: opacity * 0.85);
    final building = Paint()..color = const Color(0xFF6B7C88).withValues(alpha: opacity);
    final tower = Paint()..color = const Color(0xFF5E717F).withValues(alpha: opacity * 1.15);

    // Rolling hills.
    final hills = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.72)
      ..quadraticBezierTo(w * 0.22, h * 0.55, w * 0.45, h * 0.68)
      ..quadraticBezierTo(w * 0.7, h * 0.82, w, h * 0.6)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(hills, hill);

    final frontHill = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.82)
      ..quadraticBezierTo(w * 0.35, h * 0.68, w * 0.65, h * 0.78)
      ..quadraticBezierTo(w * 0.85, h * 0.85, w, h * 0.74)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(frontHill, Paint()..color = const Color(0xFF5F9A74).withValues(alpha: opacity * 0.7));

    // Twin towers (simplified).
    final leftTowerX = w * 0.52;
    final rightTowerX = w * 0.62;
    final baseY = h * 0.62;
    final topY = h * 0.18;
    final towerW = w * 0.035;

    void drawTwin(double x) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, topY, towerW, baseY - topY),
          const Radius.circular(2),
        ),
        tower,
      );
      // Spire
      canvas.drawLine(
        Offset(x + towerW / 2, topY),
        Offset(x + towerW / 2, h * 0.08),
        Paint()
          ..color = const Color(0xFF5E717F).withValues(alpha: opacity * 1.2)
          ..strokeWidth = 1.4,
      );
      // Skybridge
    }

    drawTwin(leftTowerX);
    drawTwin(rightTowerX);
    canvas.drawRect(
      Rect.fromLTWH(leftTowerX + towerW, h * 0.34, rightTowerX - leftTowerX - towerW, h * 0.025),
      tower,
    );

    // KL Tower
    final klX = w * 0.78;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(klX, h * 0.28, w * 0.028, baseY - h * 0.28),
        const Radius.circular(2),
      ),
      building,
    );
    canvas.drawCircle(Offset(klX + w * 0.014, h * 0.26), w * 0.018, building);

    // Small block buildings
    for (final bx in [0.3, 0.36, 0.42, 0.86, 0.91]) {
      final bh = h * (0.12 + (bx * 7) % 0.1);
      canvas.drawRect(Rect.fromLTWH(w * bx, baseY - bh, w * 0.03, bh), building);
    }
  }

  @override
  bool shouldRepaint(covariant KlSkylinePainter oldDelegate) => oldDelegate.opacity != opacity;
}

class SidebarPromoCard extends StatelessWidget {
  const SidebarPromoCard({super.key, required this.message});

  final String message;

  static const _leavesAsset = 'assets/images/leaves_frame.png';

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      borderRadius: 16,
      opacity: 0.10,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 96,
            child: Opacity(
              opacity: 0.35,
              child: Image.asset(
                _leavesAsset,
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 86),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2F8F5B), width: 1.6),
                    color: const Color(0xFFF3FAF5).withValues(alpha: 0.55),
                  ),
                  child: const Icon(Icons.eco_rounded, size: 15, color: Color(0xFF1F6B45)),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class KlWatermarkBackdrop extends StatelessWidget {
  const KlWatermarkBackdrop({super.key, required this.child, this.height = 220});

  final Widget child;
  final double height;

  static const _skylineAsset = 'assets/images/kl_skyline.png';

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width * 0.58, 460.0);
    return Stack(
      children: [
        child,
        Positioned(
          right: 0,
          bottom: 0,
          width: width,
          height: height,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.35,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: const [
                      Color(0xFFFFFFFF),
                      Color(0xCCFFFFFF),
                      Color(0x00FFFFFF),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ).createShader(bounds);
                },
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: const [
                        Color(0xFFFFFFFF),
                        Color(0xE6FFFFFF),
                        Color(0x00FFFFFF),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ).createShader(bounds);
                  },
                  child: Image.asset(
                    _skylineAsset,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MalaysiaFlagMark extends StatelessWidget {
  const MalaysiaFlagMark({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 1.4,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0x33000000)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFC1272D),
            Color(0xFFFFFFFF),
            Color(0xFFC1272D),
            Color(0xFFFFFFFF),
            Color(0xFFC1272D),
            Color(0xFFFFFFFF),
          ],
          stops: [0, 0.2, 0.4, 0.55, 0.75, 1],
        ),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: size * 0.7,
          height: size * 0.55,
          decoration: const BoxDecoration(
            color: Color(0xFF00247D),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(2)),
          ),
          child: const Center(
            child: Icon(Icons.star, size: 8, color: Color(0xFFFFCC00)),
          ),
        ),
      ),
    );
  }
}
