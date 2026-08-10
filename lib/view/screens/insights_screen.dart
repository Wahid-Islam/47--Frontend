import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../controller/cubits/insights_cubit.dart';
import '../../controller/cubits/locale_cubit.dart';
import '../../controller/services/mortality_insights.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cards.dart';
import '../../model/insights.dart';
import '../widgets/design_accents.dart';
import '../widgets/health_age_dual_gauge.dart';
import '../widgets/page_header.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  static List<RiskFactor> _topFactors(List<RiskFactor> factors) {
    final ranked = [...factors]..sort((a, b) => b.score.compareTo(a.score));
    return ranked.take(3).toList();
  }

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
          final factors = _topFactors(insights.factors);
          final group = MortalityInsights.ageGroupLabel(insights.actualAge);
          final killers = MortalityInsights.fromInsights(insights);

          return KlWatermarkBackdrop(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                PageHeader(
                  title: AppStrings.t('healthGlanceTitle', locale),
                  subtitle: AppStrings.t('healthGlanceSubtitle', locale),
                ),
                _HeroCard(insights: insights, factors: factors, locale: locale),
                const SizedBox(height: 18),
                _MortalityCard(ageGroup: group, killers: killers, locale: locale),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.insights, required this.factors, required this.locale});

  final Insights insights;
  final List<RiskFactor> factors;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final delta = insights.healthAgeDelta;
    final isBad = delta > 0;
    final width = MediaQuery.sizeOf(context).width;
    final stacked = width < 900;

    final ageSide = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.t('yourHealthAgeTitle', locale), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 18),
        HealthAgeDualGauge(healthAge: insights.healthAge, actualAge: insights.actualAge, locale: locale),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isBad ? AppTheme.softRed : const Color(0xFFF5F8F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isBad ? const Color(0xFFFFE3E1) : const Color(0xFFE2F1E7),
                ),
                child: Icon(
                  isBad ? Icons.north_east : (delta < 0 ? Icons.south_east : Icons.check),
                  size: 14,
                  color: isBad ? AppTheme.riskHigh : AppTheme.primary,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 14, height: 1.35, color: AppTheme.foreground),
                    children: [
                      TextSpan(text: '${AppStrings.t('healthAgeDeltaPrefix', locale)} '),
                      TextSpan(
                        text: delta == 0
                            ? AppStrings.t('healthAgeAligned', locale)
                            : AppStrings.tn(isBad ? 'healthAgeYearsAbove' : 'healthAgeYearsBelow', locale, delta.abs()),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: isBad ? AppTheme.riskHigh : const Color(0xFF196D45),
                        ),
                      ),
                      if (delta != 0) TextSpan(text: ' ${AppStrings.t('healthAgeDeltaSuffix', locale)}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          AppStrings.t('healthAgeDisclaimer', locale),
          style: const TextStyle(fontSize: 11.5, height: 1.45, color: Color(0xFF7B8490)),
        ),
      ],
    );

    final factorSide = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.t('factorsInfluencingTitle', locale), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          AppStrings.t('factorsInfluencingSubtitle', locale),
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 14),
        for (final factor in factors) ...[
          _FactorRow(factor: factor, locale: locale),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.go('/home/roadmap'),
            child: Text(AppStrings.t('viewMyRoadmap', locale)),
          ),
        ),
      ],
    );

    return HpCard(
      padding: EdgeInsets.all(stacked ? 20 : 28),
      child: stacked
          ? Column(
              children: [
                ageSide,
                const SizedBox(height: 24),
                const Divider(height: 1, color: AppTheme.border),
                const SizedBox(height: 24),
                factorSide,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 103, child: ageSide),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    height: 280,
                    child: VerticalDivider(width: 1, color: AppTheme.border),
                  ),
                ),
                Expanded(flex: 97, child: factorSide),
              ],
            ),
    );
  }
}

class _FactorRow extends StatelessWidget {
  const _FactorRow({required this.factor, required this.locale});

  final RiskFactor factor;
  final String locale;

  IconData get _icon {
    switch (factor.id) {
      case 'diet':
        return Icons.restaurant_outlined;
      case 'physical_inactivity':
        return Icons.directions_walk_outlined;
      case 'sleep':
        return Icons.bedtime_outlined;
      case 'smoking':
        return Icons.smoke_free_outlined;
      case 'alcohol':
        return Icons.local_bar_outlined;
      default:
        return Icons.monitor_heart_outlined;
    }
  }

  int get _filledBars {
    switch (factor.impact.toLowerCase()) {
      case 'high':
        return 4;
      case 'medium':
      case 'moderate':
        return 3;
      default:
        return 2;
    }
  }

  String get _badgeLabel {
    switch (factor.impact.toLowerCase()) {
      case 'high':
        return AppStrings.t('impactHigh', locale);
      case 'medium':
      case 'moderate':
        return AppStrings.t('impactModerate', locale);
      default:
        return AppStrings.t('impactLower', locale);
    }
  }

  String get _subLabel {
    switch (factor.impact.toLowerCase()) {
      case 'high':
        return AppStrings.t('impactHighSub', locale);
      case 'medium':
      case 'moderate':
        return AppStrings.t('impactModerateSub', locale);
      default:
        return AppStrings.t('impactLowerSub', locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.riskColor(factor.impact);
    final soft = AppTheme.riskSoft(factor.impact);
    final filled = _filledBars;

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: soft, shape: BoxShape.circle),
              child: Icon(_icon, size: 20, color: color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(factor.localizedLabel(locale), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(_subLabel, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(8)),
              child: Text(
                _badgeLabel,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 55),
          child: Row(
            children: [
              for (var i = 0; i < 6; i++)
                Expanded(
                  child: Container(
                    height: 7,
                    margin: EdgeInsets.only(right: i == 5 ? 0 : 5),
                    decoration: BoxDecoration(
                      color: i < filled ? color : const Color(0xFFE8EAED),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MortalityCard extends StatelessWidget {
  const _MortalityCard({
    required this.ageGroup,
    required this.killers,
    required this.locale,
  });

  final String ageGroup;
  final List<MortalityKiller> killers;
  final String locale;

  static const _styles = [
    (bg: AppTheme.softRed, fg: Color(0xFFB83D38), pct: Color(0xFFDC554F)),
    (bg: AppTheme.softOrange, fg: Color(0xFFB86B12), pct: Color(0xFFC97918)),
    (bg: AppTheme.softGreen, fg: Color(0xFF27804D), pct: Color(0xFF23804B)),
  ];

  @override
  Widget build(BuildContext context) {
    final tiles = [
      for (var i = 0; i < killers.length; i++)
        (
          rank: '${i + 1}',
          rankBg: _styles[i % _styles.length].bg,
          rankFg: _styles[i % _styles.length].fg,
          icon: killers[i].icon,
          title: killers[i].localizedTitle(locale),
          body: killers[i].localizedBody(locale, ageGroup),
          pct: killers[i].percentLabel,
          pctColor: _styles[i % _styles.length].pct,
          meta: killers[i].localizedMeta(locale),
        ),
    ];

    final narrow = MediaQuery.sizeOf(context).width < 720;

    return HpCard(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2, right: 8),
                child: MalaysiaFlagMark(size: 16),
              ),
              Expanded(
                child: Text(
                  AppStrings.t('mortalityTitle', locale).replaceAll('{group}', ageGroup),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/home/learn'),
                child: Text(AppStrings.t('exploreInsights', locale)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.t('mortalitySubtitle', locale),
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 18),
          if (narrow)
            Column(
              children: [
                for (final k in tiles) ...[
                  _KillerTile(data: k, ofDeathsLabel: AppStrings.t('ofDeaths', locale)),
                  const SizedBox(height: 12),
                ],
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  if (i > 0) const SizedBox(width: 14),
                  Expanded(
                    child: _KillerTile(
                      data: tiles[i],
                      ofDeathsLabel: AppStrings.t('ofDeaths', locale),
                    ),
                  ),
                ],
              ],
            ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE8ECEE)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.t('mortalitySource', locale),
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF727D88)),
                  ),
                ),
                Text(
                  AppStrings.t('lastUpdated', locale),
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF9AA3AD)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KillerTile extends StatelessWidget {
  const _KillerTile({required this.data, required this.ofDeathsLabel});

  final ({
    String rank,
    Color rankBg,
    Color rankFg,
    IconData icon,
    String title,
    String body,
    String pct,
    Color pctColor,
    String meta,
  }) data;
  final String ofDeathsLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7EBED)),
        boxShadow: const [BoxShadow(color: Color(0x0F223948), blurRadius: 18, offset: Offset(0, 8))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 88,
            child: IgnorePointer(
              child: CustomPaint(painter: const KlSkylinePainter(opacity: 0.12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: data.rankBg, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      data.rank,
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: data.rankFg),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: data.rankBg.withValues(alpha: 0.55),
                  ),
                  child: Icon(data.icon, size: 28, color: data.rankFg),
                ),
                const SizedBox(height: 12),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, height: 1.25),
                ),
                const SizedBox(height: 7),
                Text(
                  data.body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, height: 1.45, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 14),
                Text(
                  data.pct,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: data.pctColor, height: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  ofDeathsLabel,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5F6B78)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
