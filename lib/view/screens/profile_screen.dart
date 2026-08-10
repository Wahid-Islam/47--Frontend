import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../controller/cubits/auth_cubit.dart';
import '../../controller/cubits/insights_cubit.dart';
import '../../controller/cubits/locale_cubit.dart';
import '../../controller/cubits/profile_cubit.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/l10n/localized.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/cards.dart';
import '../widgets/page_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const String _fallbackDisclaimerEn =
      'MySihat provides population-based statistical insights for education and prevention planning. '
      'It is not a medical diagnosis or clinical advice.';
  static const String _fallbackDisclaimerBm =
      'MySihat menyediakan pandangan statistik berasaskan populasi untuk pendidikan dan perancangan '
      'pencegahan. Ia bukan diagnosis perubatan atau nasihat klinikal.';
  static const String _fallbackDisclaimerZh =
      'MySihat 提供基于人群的统计洞察，用于教育与预防规划。'
      '它不是医学诊断或临床建议。';

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    final email = context.watch<AuthCubit>().state.email ?? '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          PageHeader(
            title: AppStrings.t('profileTitle', locale),
            subtitle: AppStrings.t('profileSubtitle', locale),
          ),
          HpCard(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.t('profileSectionTitle', locale), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  AppStrings.t('profileSectionSubtitle', locale),
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
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
                  child: Text(
                    AppStrings.t('profileNotice', locale),
                    style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF32684C)),
                  ),
                ),
                const SizedBox(height: 18),
                BlocBuilder<ProfileCubit, ProfileState>(
                  buildWhen: (previous, current) => previous.profile != current.profile,
                  builder: (context, state) {
                    final profile = state.profile;
                    String enumLabel(String? value, Map<String, String> keys) {
                      if (value == null || value.isEmpty) return '—';
                      final key = keys[value];
                      return key == null ? value : AppStrings.t(key, locale);
                    }

                    final fields = [
                      (AppStrings.t('fullName', locale), profile?.fullName.isNotEmpty == true ? profile!.fullName : '—'),
                      (AppStrings.t('email', locale), email.isEmpty ? '—' : email),
                      (AppStrings.t('age', locale), '${profile?.age ?? '—'}'),
                      (
                        AppStrings.t('sex', locale),
                        enumLabel(profile?.gender, {'male': 'male', 'female': 'female', 'other': 'other'}),
                      ),
                      (
                        AppStrings.t('smoking', locale),
                        profile == null
                            ? '—'
                            : (profile.smoking ? AppStrings.t('yes', locale) : AppStrings.t('no', locale)),
                      ),
                      (
                        AppStrings.t('highBp', locale),
                        profile == null
                            ? '—'
                            : (profile.highBloodPressure ? AppStrings.t('yes', locale) : AppStrings.t('no', locale)),
                      ),
                      (
                        AppStrings.t('diabetesDiagnosed', locale),
                        profile == null
                            ? '—'
                            : (profile.diabetes ? AppStrings.t('yes', locale) : AppStrings.t('no', locale)),
                      ),
                      (AppStrings.t('heightCm', locale), profile == null ? '—' : profile.heightCm.toStringAsFixed(0)),
                      (AppStrings.t('weightKg', locale), profile == null ? '—' : profile.weightKg.toStringAsFixed(0)),
                      (
                        AppStrings.t('activity', locale),
                        enumLabel(profile?.activityLevel, {
                          'low': 'low',
                          'moderate': 'moderate',
                          'high': 'high',
                        }),
                      ),
                      (
                        AppStrings.t('diet', locale),
                        enumLabel(profile?.dietHabit, {
                          'unhealthy': 'unhealthy',
                          'average': 'average',
                          'healthy': 'healthy',
                        }),
                      ),
                      (
                        AppStrings.t('alcohol', locale),
                        enumLabel(profile?.alcohol, {
                          'none': 'alcoholNone',
                          'occasional': 'alcoholOccasional',
                          'regular': 'alcoholRegular',
                        }),
                      ),
                      (AppStrings.t('sleepHours', locale), profile == null ? '—' : profile.sleepHours.toString()),
                      (AppStrings.t('bmi', locale), profile == null ? '—' : profile.bmi.toStringAsFixed(1)),
                    ];

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final twoCol = constraints.maxWidth >= 560;
                        if (!twoCol) {
                          return Column(
                            children: [
                              for (final f in fields) ...[
                                _ProfileField(label: f.$1, value: f.$2),
                                const SizedBox(height: 12),
                              ],
                            ],
                          );
                        }
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            for (final f in fields)
                              SizedBox(
                                width: (constraints.maxWidth - 16) / 2,
                                child: _ProfileField(label: f.$1, value: f.$2),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 240,
                    child: HpPrimaryButton(
                      label: AppStrings.t('editProfile', locale),
                      icon: Icons.edit_outlined,
                      onPressed: () => context.push('/profile-wizard'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionHeader(AppStrings.t('language', locale)),
          HpCard(
            child: Column(
              children: [
                for (final option in const [
                  ('en', 'english'),
                  ('bm', 'bahasaMelayu'),
                  ('zh', 'simplifiedChinese'),
                ])
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(AppStrings.t(option.$2, locale), style: const TextStyle(fontSize: 16)),
                    trailing: Icon(
                      locale == option.$1 ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: AppTheme.primary,
                    ),
                    onTap: () => _changeLocale(context, option.$1),
                    minVerticalPadding: 16,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionHeader(AppStrings.t('disclaimer', locale)),
          BlocBuilder<InsightsCubit, InsightsState>(
            buildWhen: (previous, current) => previous.insights != current.insights,
            builder: (context, state) {
              final disclaimer =
                  state.insights?.localizedDisclaimer(locale) ??
                  localizedText(
                    locale,
                    en: _fallbackDisclaimerEn,
                    bm: _fallbackDisclaimerBm,
                    zh: _fallbackDisclaimerZh,
                  );
              return HpCard(
                child: Text(
                  disclaimer,
                  style: const TextStyle(fontSize: 15, height: 1.4, color: AppTheme.textSecondary),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => context.read<AuthCubit>().logout(),
              icon: const Icon(Icons.logout),
              label: Text(AppStrings.t('logout', locale)),
            ),
          ),
        ],
      ),
    );
  }

  void _changeLocale(BuildContext context, String value) {
    context.read<LocaleCubit>().setLocale(value);
    final userId = context.read<AuthCubit>().state.userId;
    if (userId != null) {
      context.read<ProfileCubit>().updateLocale(userId, value);
    }
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.foreground)),
        const SizedBox(height: 7),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDFE7E3)),
          ),
          child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
