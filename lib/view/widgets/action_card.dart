import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/chips.dart';
import '../../model/action_item.dart';

class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.index,
    required this.action,
    required this.locale,
    required this.onClinic,
    required this.onHabitCta,
  });

  final int index;
  final ActionItem action;
  final String locale;
  final VoidCallback onClinic;
  final ValueChanged<String> onHabitCta;

  @override
  Widget build(BuildContext context) {
    final title = action.localizedTitle(locale);
    final description = action.localizedDescription(locale);
    final ctaLabel = action.cta.localizedLabel(locale);
    final isClinic = action.cta.type == 'clinic';

    return HpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.accent.withValues(alpha: 0.18),
                foregroundColor: AppTheme.foreground,
                child: Text('$index', style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleSmall)),
              RiskChip(action.impact),
            ],
          ),
          const SizedBox(height: 12),
          Text(description, style: const TextStyle(fontSize: 16, height: 1.4)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule, size: 18, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text(
                '${action.timeMinutes} ${AppStrings.t('minutes', locale)}',
                style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary),
              ),
              const SizedBox(width: 16),
              Text(
                '${AppStrings.t('impact', locale)}: '
                '${AppStrings.t(action.impact == 'medium' ? 'moderate' : action.impact, locale)}',
                style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: isClinic
                ? ElevatedButton.icon(
                    onPressed: onClinic,
                    icon: const Icon(Icons.local_hospital_outlined),
                    label: Text(ctaLabel),
                  )
                : OutlinedButton.icon(
                    onPressed: () => onHabitCta(ctaLabel),
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(ctaLabel),
                  ),
          ),
        ],
      ),
    );
  }
}
