import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../controller/cubits/locale_cubit.dart';
import '../../controller/cubits/profile_cubit.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    final profile = context.watch<ProfileCubit>().state.profile;
    final name = (profile?.fullName.isNotEmpty ?? false)
        ? profile!.fullName.split(' ').first
        : AppStrings.t('helloThere', locale);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'M';

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 15, color: Color(0xFF334154), fontWeight: FontWeight.w600),
                    children: [
                      TextSpan(text: AppStrings.t('hello', locale)),
                      TextSpan(text: name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, height: 1.4, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: AppStrings.t('notifications', locale),
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE2E8E4)),
              fixedSize: const Size(40, 40),
            ),
            icon: const Icon(Icons.notifications_none_rounded, size: 20, color: Color(0xFF334154)),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppTheme.softGreen,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.go('/home/profile'),
              child: SizedBox(
                width: 38,
                height: 38,
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2C6D48)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
