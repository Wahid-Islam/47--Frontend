import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/cubits/profile_cubit.dart';
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
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 19,
            backgroundColor: AppTheme.softGreen,
            child: Text(
              initial,
              style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2C6D48)),
            ),
          ),
        ],
      ),
    );
  }
}
