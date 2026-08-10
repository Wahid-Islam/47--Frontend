import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/cubits/insights_cubit.dart';
import '../../controller/cubits/locale_cubit.dart';
import '../../controller/services/mortality_insights.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cards.dart';
import '../widgets/page_header.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    final narrow = MediaQuery.sizeOf(context).width < 720;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<InsightsCubit, InsightsState>(
        buildWhen: (p, c) => p.insights != c.insights,
        builder: (context, state) {
          final insights = state.insights;
          if (insights == null) {
            return Center(child: Text(AppStrings.t('noInsights', locale)));
          }
          final cards = MortalityInsights.learnCards(insights, locale);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              PageHeader(
                title: AppStrings.t('learnTitle', locale),
                subtitle: AppStrings.t('learnSubtitle', locale),
              ),
              HpCard(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.t('learnSectionTitle', locale), style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.t('learnSectionSubtitle', locale),
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 22),
                    if (narrow)
                      Column(
                        children: [
                          for (final c in cards) ...[
                            _InsightCard(data: c),
                            const SizedBox(height: 14),
                          ],
                        ],
                      )
                    else
                      Column(
                        children: [
                          for (var row = 0; row < cards.length; row += 2) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _InsightCard(data: cards[row])),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: row + 1 < cards.length
                                      ? _InsightCard(data: cards[row + 1])
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                            if (row + 2 < cards.length) const SizedBox(height: 14),
                          ],
                        ],
                      ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7F3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDCECE2)),
                      ),
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(fontSize: 12, height: 1.45, color: Color(0xFF32684C)),
                          children: [
                            TextSpan(
                              text: '${AppStrings.t('whyThisMatters', locale)}: ',
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            TextSpan(text: AppStrings.t('learnWhyBody', locale)),
                          ],
                        ),
                      ),
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

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.data});

  final ({String eyebrow, String title, String stat, String body, String source}) data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE4E9E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.eyebrow.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 7),
          Text(data.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          if (data.stat.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              data.stat,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.primary),
            ),
            const SizedBox(height: 3),
          ] else
            const SizedBox(height: 10),
          Text(data.body, style: const TextStyle(fontSize: 12, height: 1.55, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          Text(data.source, style: const TextStyle(fontSize: 10, color: Color(0xFF89938F))),
        ],
      ),
    );
  }
}
