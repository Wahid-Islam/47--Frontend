import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/cubits/locale_cubit.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.riskHigh.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.riskHigh.withValues(alpha: 0.3)),
      ),
      child: Text(
        AppStrings.localizeError(message, locale),
        style: const TextStyle(color: AppTheme.riskHigh, fontSize: 16),
      ),
    );
  }
}
