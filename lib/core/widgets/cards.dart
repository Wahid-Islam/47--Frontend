import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'liquid_glass.dart';

class HpCard extends StatelessWidget {
  const HpCard({super.key, required this.child, this.padding, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding ?? const EdgeInsets.all(18), child: child);
    final glass = LiquidGlass(
      opacity: 0.15,
      borderRadius: AppTheme.cardRadius,
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                child: content,
              ),
            ),
    );
    return glass;
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
