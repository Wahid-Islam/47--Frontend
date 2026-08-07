import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../controller/cubits/insights_cubit.dart';
import '../../controller/cubits/locale_cubit.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/cards.dart';
import '../../model/insights.dart';
import '../widgets/health_age_dual_gauge.dart';
import '../widgets/risk_bars.dart';

/// US 1.2 + US 1.3: "Personal Insights" — the Health Age headline, the top
/// 3 contributing factors, and the national/peer comparison — with a
/// primary CTA that hands off to the Action Roadmap (`/home/plan`).
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  /// Prefers Activity ("physical_inactivity"), Diet, and Sleep factors
  /// (per the mysihat Personal Insights spec) when present in
  /// [insights.factors], falling back to the next-highest-scored factors
  /// so the card always shows exactly 3 rows.
  static List<RiskFactor> _topFactors(List<RiskFactor> factors) {
    const preferredIds = ['physical_inactivity', 'diet', 'sleep'];
    final byId = {for (final f in factors) f.id: f};
    final selected = <RiskFactor>[
      for (final id in preferredIds)
        if (byId[id] != null) byId[id]!,
    ];
    if (selected.length < 3) {
      final remaining = factors.where((f) => !selected.contains(f)).toList()
        ..sort((a, b) => b.score.compareTo(a.score));
      for (final f in remaining) {
        if (selected.length >= 3) break;
        selected.add(f);
      }
    }
    return selected.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t('insights', locale))),
      body: BlocBuilder<InsightsCubit, InsightsState>(
        buildWhen: (previous, current) => previous.insights != current.insights,
        builder: (context, state) {
          final insights = state.insights;
          if (insights == null) {
            return Center(child: Text(AppStrings.t('noInsights', locale)));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Text(
                AppStrings.t('insightsSubtitle', locale),
                style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 18),
              _HealthAgeCard(insights: insights, locale: locale),
              const SizedBox(height: 18),
              SectionHeader(AppStrings.t('topFactorsTitle', locale)),
              HpCard(
                child: Column(
                  children: [
                    for (final factor in _topFactors(insights.factors))
                      FactorBar(
                        label: factor.localizedLabel(locale),
                        score: factor.score,
                        impact: factor.impact,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SectionHeader(AppStrings.t('nationalComparisonTitle', locale)),
              HpCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insights.localizedNationalComparisonHeadline(locale),
                      style: const TextStyle(fontSize: 16, height: 1.45),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.t('healthAgeCompareLabel', locale),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 10),
                    RiskCompareBar(
                      personal: insights.healthAge.toDouble(),
                      national: insights.peerAverageHealthAge.toDouble(),
                      personalLabel: AppStrings.t('you', locale),
                      nationalLabel: AppStrings.t('nationalAvg', locale),
                      suffix: '',
                      decimals: 0,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      insights.topRisk.localizedName(locale),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 10),
                    RiskCompareBar(
                      personal: insights.topRisk.personalRisk,
                      national: insights.topRisk.nationalAverage,
                      personalLabel: AppStrings.t('yourRisk', locale),
                      nationalLabel: AppStrings.t('nationalAvg', locale),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      insights.localizedPeerComparison(locale),
                      style: const TextStyle(fontSize: 15, height: 1.4, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              HpPrimaryButton(
                label: AppStrings.t('nextActionRoadmap', locale),
                icon: Icons.arrow_forward,
                onPressed: () => context.go('/home/plan'),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The "Your Health Age" card: dual circular Health Age vs. actual age
/// comparison plus a localized success/caution message driven by
/// [Insights.healthAgeDelta].
class _HealthAgeCard extends StatelessWidget {
  const _HealthAgeCard({required this.insights, required this.locale});

  final Insights insights;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final delta = insights.healthAgeDelta;
    final String message;
    final Color messageColor;
    if (delta < 0) {
      message = AppStrings.tn('healthAgeYoungerMsg', locale, delta.abs());
      messageColor = AppTheme.riskLow;
    } else if (delta > 0) {
      message = AppStrings.tn('healthAgeOlderMsg', locale, delta);
      messageColor = AppTheme.riskModerate;
    } else {
      message = AppStrings.t('healthAgeSameMsg', locale);
      messageColor = AppTheme.primary;
    }

    return HpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.t('yourHealthAgeTitle', locale), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          HealthAgeDualGauge(healthAge: insights.healthAge, actualAge: insights.actualAge, locale: locale),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: messageColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: messageColor.withValues(alpha: 0.3)),
            ),
            child: Text(message, style: TextStyle(fontSize: 15, height: 1.4, color: messageColor)),
          ),
        ],
      ),
    );
  }
}
