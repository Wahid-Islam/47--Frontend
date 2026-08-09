import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/cubits/habits_cubit.dart';
import '../../controller/cubits/insights_cubit.dart';
import '../../controller/cubits/locale_cubit.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cards.dart';
import '../widgets/health_age_projection_chart.dart';
import '../widgets/page_header.dart';

/// My Roadmap — personalised 4 daily habits, risk drop, reminders, projection.
class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<InsightsCubit, InsightsState>(
        buildWhen: (previous, current) => previous.insights != current.insights,
        builder: (context, state) {
          final insights = state.insights;
          if (insights == null) {
            return Center(child: Text(AppStrings.t('noInsights', locale)));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              PageHeader(
                title: AppStrings.t('roadmapTitle', locale),
                subtitle: AppStrings.t('roadmapSubtitle', locale),
              ),
              HpCard(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<HabitsCubit, HabitsState>(
                      buildWhen: (p, c) =>
                          p.items != c.items ||
                          p.riskDropPoints != c.riskDropPoints ||
                          p.adjustedHealthAge != c.adjustedHealthAge,
                      builder: (context, habitState) {
                        final done = habitState.completedCount;
                        final total = habitState.totalCount == 0 ? 4 : habitState.totalCount;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.t('roadmapSectionTitle', locale),
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    AppStrings.t('roadmapSectionSubtitle', locale),
                                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: AppTheme.softGreen,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$done / $total ${AppStrings.t('complete', locale)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ),
                                if (habitState.riskDropPoints > 0) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '−${habitState.riskDropPoints.toStringAsFixed(1)} ${AppStrings.t('riskPts', locale)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF196D45),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const _ReminderCard(),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final stacked = constraints.maxWidth < 800;
                        final habits = const _HabitChecklist();
                        final chart = BlocBuilder<HabitsCubit, HabitsState>(
                          buildWhen: (p, c) =>
                              p.items != c.items ||
                              p.adjustedHealthAge != c.adjustedHealthAge ||
                              p.habitProgress != c.habitProgress,
                          builder: (context, habitState) {
                            final progress = habitState.habitProgress;
                            final displayHealthAge = progress > 0 && habitState.adjustedHealthAge > 0
                                ? habitState.adjustedHealthAge
                                : insights.healthAge;
                            return HpCard(
                              padding: const EdgeInsets.all(22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.t('projectionCardTitle', locale),
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    AppStrings.t('projectionCardSubtitle', locale),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      height: 1.5,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  if (habitState.riskDropPoints > 0) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      AppStrings.t('riskDropToday', locale)
                                          .replaceAll('{pts}', habitState.riskDropPoints.toStringAsFixed(1))
                                          .replaceAll('{age}', '${habitState.adjustedHealthAge}'),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF196D45),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  HealthAgeProjectionChart(
                                    healthAge: insights.healthAge,
                                    actualAge: insights.actualAge,
                                    projectedFollowPlan: insights.actualAge,
                                    projectedNoChange: insights.projectedHealthAgeNoChange,
                                    habitProgress: progress,
                                    locale: locale,
                                  ),
                                  if (displayHealthAge != insights.healthAge) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      '${AppStrings.t('healthAge', locale)} → $displayHealthAge '
                                      '(${AppStrings.t('actualAge', locale)} ${insights.actualAge})',
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        );

                        if (stacked) {
                          return Column(
                            children: [
                              habits,
                              const SizedBox(height: 18),
                              chart,
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 105, child: habits),
                            const SizedBox(width: 18),
                            Expanded(flex: 95, child: chart),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard();

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    return BlocBuilder<HabitsCubit, HabitsState>(
      buildWhen: (p, c) =>
          p.reminderEnabled != c.reminderEnabled ||
          p.reminderHour != c.reminderHour ||
          p.reminderMinute != c.reminderMinute,
      builder: (context, state) {
        final timeLabel =
            '${state.reminderHour.toString().padLeft(2, '0')}:${state.reminderMinute.toString().padLeft(2, '0')}';
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4E9E7)),
          ),
          child: Row(
            children: [
              const Icon(Icons.notifications_active_outlined, color: AppTheme.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.t('dailyReminder', locale),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      state.reminderEnabled
                          ? AppStrings.t('reminderOnAt', locale).replaceAll('{time}', timeLabel)
                          : AppStrings.t('reminderOff', locale),
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: state.reminderHour, minute: state.reminderMinute),
                  );
                  if (picked == null || !context.mounted) return;
                  await context.read<HabitsCubit>().setReminder(
                    enabled: true,
                    hour: picked.hour,
                    minute: picked.minute,
                  );
                },
                child: Text(AppStrings.t('setTime', locale)),
              ),
              Switch(
                value: state.reminderEnabled,
                onChanged: (v) => context.read<HabitsCubit>().setReminder(enabled: v),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HabitChecklist extends StatelessWidget {
  const _HabitChecklist();

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    return BlocBuilder<HabitsCubit, HabitsState>(
      buildWhen: (previous, current) =>
          previous.items != current.items || previous.motivation != current.motivation,
      builder: (context, state) {
        if (state.items.isEmpty) {
          return Text(AppStrings.t('noInsights', locale));
        }
        final done = state.completedCount;
        final total = state.totalCount;
        final progress = state.habitProgress;

        return Column(
          children: [
            Text(
              state.localizedMotivation(locale),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF32684C)),
            ),
            const SizedBox(height: 12),
            for (final item in state.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.read<HabitsCubit>().toggle(item.id, completed: !item.completed),
                    child: Container(
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE4E9E7)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 25,
                            height: 25,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: item.completed ? AppTheme.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: item.completed ? AppTheme.primary : const Color(0xFFC8D3CE),
                                width: 2,
                              ),
                            ),
                            child: item.completed
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.localizedTitle(locale),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    decoration: item.completed ? TextDecoration.lineThrough : null,
                                    color: item.completed ? const Color(0xFF8B9692) : AppTheme.foreground,
                                  ),
                                ),
                                if (item.localizedReason(locale).isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    item.localizedReason(locale),
                                    style: const TextStyle(fontSize: 11, height: 1.35, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.softGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.category,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8F6),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.t('todaysProgress', locale),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '$done ${AppStrings.t('of', locale)} $total',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFDFE8E3),
                      valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7F3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDCECE2)),
              ),
              child: Text(
                AppStrings.t('roadmapNotice', locale),
                style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF32684C)),
              ),
            ),
          ],
        );
      },
    );
  }
}
