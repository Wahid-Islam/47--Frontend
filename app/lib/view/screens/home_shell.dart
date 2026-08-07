import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../controller/cubits/locale_cubit.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/widgets/responsive_shell.dart';

/// Bottom-nav (phone) / navigation-rail (tablet+) shell for the five main
/// authenticated tabs, wired to the `go_router` [StatefulShellRoute].
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    return ResponsiveShell(
      navigationShell: navigationShell,
      destinations: [
        ShellDestination(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: AppStrings.t('home', locale),
        ),
        ShellDestination(
          icon: Icons.insights_outlined,
          selectedIcon: Icons.insights,
          label: AppStrings.t('insights', locale),
        ),
        ShellDestination(
          icon: Icons.checklist_outlined,
          selectedIcon: Icons.checklist,
          label: AppStrings.t('plan', locale),
        ),
        ShellDestination(
          icon: Icons.donut_large_outlined,
          selectedIcon: Icons.donut_large,
          label: AppStrings.t('progress', locale),
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
