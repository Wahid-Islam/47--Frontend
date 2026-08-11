import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../controller/cubits/auth_cubit.dart';
import '../../controller/cubits/locale_cubit.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/banners.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/centered_pane.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE1F3E7), AppTheme.background, Color(0xFFD1FAE5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: PopupMenuButton<String>(
                    initialValue: locale,
                    onSelected: (value) => context.read<LocaleCubit>().setLocale(value),
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'en', child: Text(AppStrings.t('english', locale))),
                      PopupMenuItem(value: 'bm', child: Text(AppStrings.t('bahasaMelayu', locale))),
                      PopupMenuItem(value: 'zh', child: Text(AppStrings.t('simplifiedChinese', locale))),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            locale == 'bm'
                                ? 'BM'
                                : locale == 'zh'
                                ? '中文'
                                : 'ENG',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.expand_more, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final isDesktop = width >= Breakpoints.desktop;
                    final isTablet = width >= Breakpoints.tablet;
                    final maxContentWidth = isDesktop
                        ? CenteredPane.wideWidth
                        : isTablet
                        ? 640.0
                        : CenteredPane.formWidth;
                    final horizontalPad = width < 360 ? 16.0 : 24.0;

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 12),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxContentWidth),
                            child: isDesktop
                                ? const _DesktopHero()
                                : _StackedHero(compact: width < 400),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopHero extends StatelessWidget {
  const _DesktopHero();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(flex: 6, child: _Pitch(large: true, centered: false)),
          const SizedBox(width: 48),
          Expanded(
            flex: 5,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: const _Actions(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StackedHero extends StatelessWidget {
  const _StackedHero({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 16 : 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Pitch(large: false, centered: true, compact: compact),
          SizedBox(height: compact ? 28 : 36),
          const _Actions(),
        ],
      ),
    );
  }
}

class _Pitch extends StatelessWidget {
  const _Pitch({
    required this.large,
    required this.centered,
    this.compact = false,
  });

  final bool large;
  final bool centered;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    final theme = Theme.of(context);
    final align = centered ? TextAlign.center : TextAlign.start;
    final cross = centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    final titleStyle = large
        ? theme.textTheme.headlineMedium?.copyWith(fontSize: 52)
        : theme.textTheme.headlineMedium?.copyWith(fontSize: compact ? 32 : 36);
    final taglineStyle = (large ? theme.textTheme.headlineSmall : theme.textTheme.titleMedium)
        ?.copyWith(color: AppTheme.primary);
    final bodyStyle = theme.textTheme.bodyLarge?.copyWith(
      color: AppTheme.textSecondary,
      height: 1.45,
    );

    return Column(
      crossAxisAlignment: cross,
      children: [
        Text(AppStrings.t('appName', locale), style: titleStyle, textAlign: align),
        SizedBox(height: compact ? 8 : 12),
        Text(AppStrings.t('tagline', locale), style: taglineStyle, textAlign: align),
        SizedBox(height: compact ? 12 : 16),
        Text(AppStrings.t('onboardingSubtitle', locale), style: bodyStyle, textAlign: align),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions();

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;

    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) => previous.errorMessage != current.errorMessage,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.errorMessage != null) ErrorBanner(state.errorMessage!),
            HpPrimaryButton(
              label: AppStrings.t('getStarted', locale),
              onPressed: () => context.push('/register'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () => context.push('/login'),
                child: Text(AppStrings.t('haveAccount', locale)),
              ),
            ),
          ],
        );
      },
    );
  }
}
