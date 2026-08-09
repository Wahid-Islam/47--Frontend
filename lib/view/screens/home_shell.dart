import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../controller/cubits/locale_cubit.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/widgets/responsive_shell.dart';

/// Bottom-nav (phone) / sidebar (tablet+) shell for the four main tabs
/// matching the Finalprototype: My Health, My Roadmap, Learn, Profile.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    return ResponsiveShell(
      navigationShell: navigationShell,
      brandName: AppStrings.t('appName', locale),
      destinations: [
        ShellDestination(
          icon: Icons.favorite_border,
          selectedIcon: Icons.favorite,
          label: AppStrings.t('home', locale),
        ),
        ShellDestination(
          icon: Icons.checklist_outlined,
          selectedIcon: Icons.checklist,
          label: AppStrings.t('plan', locale),
        ),
        ShellDestination(
          icon: Icons.menu_book_outlined,
          selectedIcon: Icons.menu_book,
          label: AppStrings.t('learn', locale),
        ),
        ShellDestination(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: AppStrings.t('profile', locale),
        ),
      ],
    );
  }
}
