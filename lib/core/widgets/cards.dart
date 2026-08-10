import 'package:flutter/material.dart';

class HpCard extends StatelessWidget {
  const HpCard({super.key, required this.child, this.padding, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding ?? const EdgeInsets.all(18), child: child);
    return Card(
      child: onTap == null
          ? content
          : InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: content),
    );
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
