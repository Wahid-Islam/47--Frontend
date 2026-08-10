import 'package:flutter/material.dart';

class CenteredPane extends StatelessWidget {
  const CenteredPane({super.key, required this.child, this.maxWidth = formWidth});

  static const double formWidth = 460;

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
