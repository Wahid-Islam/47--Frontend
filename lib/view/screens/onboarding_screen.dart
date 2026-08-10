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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                    final isDesktop = constraints.maxWidth >= Breakpoints.desktop;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: CenteredPane(
                        maxWidth: isDesktop ? CenteredPane.wideWidth : CenteredPane.formWidth,
                        child: isDesktop ? const _DesktopHero() : const _StackedHero(),
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
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(flex: 6, child: _Pitch(large: true)),
          const SizedBox(width: 56),
          Expanded(
            flex: 5,
            child: const Card(
              child: Padding(padding: EdgeInsets.all(28), child: _Actions()),
            ),
          ),
        ],
      ),
    );
  }
}

class _StackedHero extends StatelessWidget {
  const _StackedHero();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const _Pitch(large: false), const SizedBox(height: 40), const _Actions()],
      ),
    );
  }
}

class _Pitch extends StatelessWidget {
  const _Pitch({required this.large});

  final bool large;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.t('appName', locale),
          style: large
              ? theme.textTheme.headlineMedium?.copyWith(fontSize: 56)
              : theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.t('tagline', locale),
          style: (large ? theme.textTheme.headlineSmall : theme.textTheme.titleMedium)?.copyWith(
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.t('onboardingSubtitle', locale),
          style: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
        ),
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
      buildWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage || previous.busy != current.busy,
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
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: TextButton.icon(
                onPressed: state.busy
                    ? null
                    : () async {
                        try {
                          await context.read<AuthCubit>().demoLogin();
                        } catch (_) {
                          // Error surfaced via AuthState.errorMessage.
                        }
                      },
                icon: state.busy
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.play_circle_outline),
                label: Text(AppStrings.t('demoLogin', locale)),
              ),
            ),
          ],
        );
      },
    );
  }
}
