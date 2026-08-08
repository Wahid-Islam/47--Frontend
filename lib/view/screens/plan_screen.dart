import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../controller/cubits/habits_cubit.dart';
import '../../controller/cubits/insights_cubit.dart';
import '../../controller/cubits/locale_cubit.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cards.dart';
import '../widgets/action_card.dart';
import '../widgets/health_age_projection_chart.dart';

/// Epic 1.0 handoff screen: the "Action Roadmap" — a 12-month Health Age
/// projection chart (follow-the-plan vs. no-change), the top-3 ranked
/// action checklist (with clinic/habit CTAs), and today's daily-habit
/// checklist.
class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t('plan', locale))),
      body: BlocBuilder<InsightsCubit, InsightsState>(
        buildWhen: (previous, current) => previous.insights != current.insights,
        builder: (context, state) {
          final insights = state.insights;
          if (insights == null) {
            return Center(child: Text(AppStrings.t('noInsights', locale)));
          }
          final actions = insights.topActions;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Text(
                AppStrings.t('planSubtitle', locale),
                style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 18),
              SectionHeader(AppStrings.t('healthAgeProjectionTitle', locale)),
              HpCard(
                child: HealthAgeProjectionChart(
                  healthAge: insights.healthAge,
                  projectedFollowPlan: insights.projectedHealthAgeFollowPlan,
                  projectedNoChange: insights.projectedHealthAgeNoChange,
                  locale: locale,
                ),
              ),
              const SizedBox(height: 18),
              SectionHeader(AppStrings.t('topActions', locale)),
              if (actions.isEmpty)
                HpCard(child: Text(AppStrings.t('noInsights', locale)))
              else
                for (var i = 0; i < actions.length; i++) ...[
                  ActionCard(
                    index: i + 1,
                    action: actions[i],
                    locale: locale,
                    onClinic: () => context.push('/clinics'),
                    onHabitCta: (label) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(label)));
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              const SizedBox(height: 6),
              SectionHeader(AppStrings.t('checklist', locale)),
              const _HabitChecklist(),
            ],
          );
        },
      ),
    );
  }
}

/// Today's daily-habit checklist, scoped to only rebuild when the habit
/// list itself changes (not on every unrelated [HabitsState] field).
class _HabitChecklist extends StatelessWidget {
  const _HabitChecklist();

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    return BlocBuilder<HabitsCubit, HabitsState>(
      buildWhen: (previous, current) => previous.items != current.items,
      builder: (context, state) {
        if (state.items.isEmpty) {
          return HpCard(child: Text(AppStrings.t('noInsights', locale)));
        }
        return Column(
          children: [
            for (final item in state.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: HpCard(
                  onTap: () => context.read<HabitsCubit>().toggle(item.id, completed: !item.completed),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: Checkbox(
                          value: item.completed,
                          onChanged: (v) =>
                              context.read<HabitsCubit>().toggle(item.id, completed: v ?? false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.localizedTitle(locale),
                          style: TextStyle(
                            fontSize: 17,
                            decoration: item.completed ? TextDecoration.lineThrough : null,
                            color: item.completed ? AppTheme.textSecondary : AppTheme.foreground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
