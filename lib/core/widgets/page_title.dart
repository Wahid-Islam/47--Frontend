import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/cubits/locale_cubit.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

class PageTitle extends StatelessWidget {
  const PageTitle({super.key, required this.titleKey, required this.child});

  /// AppStrings key for the browser/window title.
  final String titleKey;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    final title = AppStrings.t(titleKey, locale);
    return Title(title: '$title · MySihat', color: AppTheme.primary, child: child);
  }
}
