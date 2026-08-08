import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/cubits/auth_cubit.dart';
import '../../controller/cubits/insights_cubit.dart';
import '../../controller/cubits/locale_cubit.dart';
import '../../controller/cubits/profile_cubit.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/chips.dart';
import '../widgets/health_age_gauge.dart';

/// Home tab: Health Age gauge, overall risk, and top risk headline.
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.t('appName', locale)),
        actions: [
          BlocBuilder<InsightsCubit, InsightsState>(
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, state) {
              final busy = state.status == InsightsStatus.loading;
              return IconButton(
                tooltip: AppStrings.t('refresh', locale),
                onPressed: busy
                    ? null
                    : () {
                        final profile = context.read<ProfileCubit>().state.profile;
                        if (profile != null) context.read<InsightsCubit>().recalculate(profile);
                      },
                icon: const Icon(Icons.refresh),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<InsightsCubit, InsightsState>(
        buildWhen: (previous, current) => previous.insights != current.insights,
        builder: (context, state) {
          final insights = state.insights;
          if (insights == null) {
            return Center(
              child: Text(AppStrings.t('noInsights', locale), style: const TextStyle(fontSize: 16)),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              final userId = context.read<AuthCubit>().state.userId;
              if (userId != null) await context.read<InsightsCubit>().load(userId);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                BlocSelector<ProfileCubit, ProfileState, String>(
                  selector: (state) => state.profile?.fullName ?? '',
                  builder: (context, fullName) {
                    final displayName = fullName.isNotEmpty ? fullName : 'Friend';
                    return Text('Hi, $displayName', style: Theme.of(context).textTheme.titleLarge);
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.t('tagline', locale),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 20),
                HpCard(
                  child: Column(
                    children: [
                      Text(AppStrings.t('healthAge', locale), style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: HealthAgeGauge(
                          actualAge: insights.actualAge.toDouble(),
                          healthAge: insights.healthAge.toDouble(),
                          locale: locale,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${AppStrings.t('actualAge', locale)}: ${insights.actualAge}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        AppStrings.t('vsActual', locale),
                        style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                HpCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.t('overallRisk', locale),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            RiskChip(insights.overallRiskLevel),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '${insights.overallRiskScore}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const Text('/100', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                HpCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.t('topRisk', locale), style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Text(
                        insights.topRisk.localizedName(locale),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.primary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${AppStrings.t('yourRisk', locale)}: ${insights.topRisk.personalRisk}%  ·  '
                        '${AppStrings.t('nationalAvg', locale)}: ${insights.topRisk.nationalAverage}%',
                        style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
