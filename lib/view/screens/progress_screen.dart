import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/cubits/habits_cubit.dart';
import '../../controller/cubits/locale_cubit.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cards.dart';

/// Today's habits: a completion donut plus a checklist that toggles
/// `habit_logs.completed_habit_ids` via [HabitsCubit].
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.t('progress', locale)),
        actions: [
          IconButton(
            onPressed: () => context.read<HabitsCubit>().refreshToday(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<HabitsCubit, HabitsState>(
        builder: (context, state) {
          final items = state.items;
          final completed = state.completedCount;
          final total = state.totalCount;
          final ratio = total == 0 ? 0.0 : completed / total;
          final motivation = state.localizedMotivation(locale);

          return RefreshIndicator(
            onRefresh: () => context.read<HabitsCubit>().refreshToday(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                HpCard(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                startDegreeOffset: -90,
                                sectionsSpace: 0,
                                centerSpaceRadius: 38,
                                sections: [
                                  PieChartSectionData(
                                    value: ratio <= 0 ? 0.001 : ratio,
                                    color: AppTheme.primary,
                                    radius: 16,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    value: (1 - ratio).clamp(0.001, 1),
                                    color: AppTheme.border,
                                    radius: 16,
                                    showTitle: false,
                                  ),
                                ],
                              ),
                            ),
                            Text('$completed/$total', style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.t('dailyHabits', locale),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$completed ${AppStrings.t('completedOf', locale)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              motivation,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppTheme.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SectionHeader(AppStrings.t('dailyHabits', locale)),
                if (items.isEmpty)
                  HpCard(child: Text(AppStrings.t('noInsights', locale)))
                else
                  ...items.map((item) {
                    return Padding(
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
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
