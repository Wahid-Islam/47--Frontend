import 'package:flutter/material.dart';

/// Centres a single column of content and caps how wide it can grow.
///
/// The phone layouts are full-bleed by design. In a desktop browser the
/// same column would stretch across the whole monitor — 1500px-wide buttons
/// and unreadable line lengths — so every top-level route that sits outside
/// [ResponsiveShell] wraps its body in this.
class CenteredPane extends StatelessWidget {
  const CenteredPane({super.key, required this.child, this.maxWidth = formWidth});

  /// Comfortable measure for a form or a single call-to-action column.
  static const double formWidth = 460;

  /// Wider measure for panes that hold two columns or a chart.
  static const double wideWidth = 960;

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
