import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../controller/cubits/habits_cubit.dart';
import '../../controller/cubits/locale_cubit.dart';
import '../../controller/cubits/profile_cubit.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';

/// Prototype-style page top bar: greeting, title, subtitle, avatar.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  void _openNotifications(BuildContext context) {
    final locale = context.read<LocaleCubit>().state;
    final habitState = context.read<HabitsCubit>().state;
    final timeLabel =
        '${habitState.reminderHour.toString().padLeft(2, '0')}:${habitState.reminderMinute.toString().padLeft(2, '0')}';
    final reminderText = habitState.reminderEnabled
        ? AppStrings.t('reminderOnAt', locale).replaceAll('{time}', timeLabel)
        : AppStrings.t('reminderOff', locale);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.t('notificationsTitle', locale),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.t('notificationsSubtitle', locale),
                  style: const TextStyle(fontSize: 13, height: 1.4, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F8F7),
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
                              reminderText,
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      context.go('/home/roadmap');
                    },
                    child: Text(AppStrings.t('manageReminders', locale)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openProfile(BuildContext context) {
    context.go('/home/profile');
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileCubit>().state.profile;
    final name = (profile?.fullName.isNotEmpty ?? false) ? profile!.fullName.split(' ').first : 'there';
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
                      const TextSpan(text: 'Hello, '),
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
            tooltip: AppStrings.t('notificationsTitle', context.watch<LocaleCubit>().state),
            onPressed: () => _openNotifications(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE2E8E4)),
              fixedSize: const Size(40, 40),
            ),
            icon: const Icon(Icons.notifications_none_rounded, size: 20, color: Color(0xFF334154)),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: AppStrings.t('profile', context.watch<LocaleCubit>().state),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _openProfile(context),
                child: CircleAvatar(
                  radius: 19,
                  backgroundColor: AppTheme.softGreen,
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
