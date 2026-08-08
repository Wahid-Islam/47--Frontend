import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../controller/cubits/auth_cubit.dart';
import '../../controller/cubits/insights_cubit.dart';
import '../../controller/cubits/locale_cubit.dart';
import '../../controller/cubits/profile_cubit.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/cards.dart';

/// Profile summary, language switch, disclaimer, and logout.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const String _fallbackDisclaimerEn =
      'HealthPath provides population-based statistical insights for education and prevention planning. '
      'It is not a medical diagnosis or clinical advice.';
  static const String _fallbackDisclaimerBm =
      'HealthPath menyediakan pandangan statistik berasaskan populasi untuk pendidikan dan perancangan '
      'pencegahan. Ia bukan diagnosis perubatan atau nasihat klinikal.';

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    final email = context.watch<AuthCubit>().state.email ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t('profile', locale))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          BlocBuilder<ProfileCubit, ProfileState>(
            buildWhen: (previous, current) => previous.profile != current.profile,
            builder: (context, state) {
              final profile = state.profile;
              return HpCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (profile?.fullName.isNotEmpty ?? false) ? profile!.fullName : 'HealthPath user',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(email, style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
                    const SizedBox(height: 12),
                    Text(
                      '${AppStrings.t('age', locale)}: ${profile?.age ?? '-'}  ·  '
                      '${AppStrings.t('state', locale)}: ${profile?.state ?? '-'}',
                      style: const TextStyle(fontSize: 15),
                    ),
                    Text(
                      'BMI ${profile?.bmi ?? '-'}  ·  ${AppStrings.t('activity', locale)}: ${profile?.activityLevel ?? '-'}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          HpPrimaryButton(
            label: AppStrings.t('editProfile', locale),
            icon: Icons.edit_outlined,
            onPressed: () => context.push('/profile-wizard'),
          ),
          const SizedBox(height: 20),
          SectionHeader(AppStrings.t('language', locale)),
          HpCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppStrings.t('english', locale), style: const TextStyle(fontSize: 16)),
                  trailing: Icon(
                    locale == 'en' ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: AppTheme.primary,
                  ),
                  onTap: () => _changeLocale(context, 'en'),
                  minVerticalPadding: 16,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppStrings.t('bahasaMelayu', locale), style: const TextStyle(fontSize: 16)),
                  trailing: Icon(
                    locale == 'bm' ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: AppTheme.primary,
                  ),
                  onTap: () => _changeLocale(context, 'bm'),
                  minVerticalPadding: 16,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(AppStrings.t('disclaimer', locale)),
          BlocBuilder<InsightsCubit, InsightsState>(
            buildWhen: (previous, current) => previous.insights != current.insights,
            builder: (context, state) {
              final disclaimer =
                  state.insights?.localizedDisclaimer(locale) ??
                  (locale == 'bm' ? _fallbackDisclaimerBm : _fallbackDisclaimerEn);
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
