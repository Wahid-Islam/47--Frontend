import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/cubits/locale_cubit.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

class RiskChip extends StatelessWidget {
  const RiskChip(this.level, {super.key});

  final String level;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    final color = AppTheme.riskColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        AppStrings.riskLevelLabel(level, locale),
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.4),
      ),
    );
  }
}

class ChoiceChipRow extends StatelessWidget {
  const ChoiceChipRow({super.key, required this.options, required this.value, required this.onChanged});

  final List<({String value, String label})> options;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final selected = opt.value == value;
        return SizedBox(
          height: 48,
          child: FilterChip(
            selected: selected,
            label: Text(opt.label, style: const TextStyle(fontSize: 16)),
            onSelected: (_) => onChanged(opt.value),
            selectedColor: AppTheme.accent.withValues(alpha: 0.22),
            checkmarkColor: AppTheme.foreground,
            labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          ),
        );
      }).toList(),
    );
  }
}
