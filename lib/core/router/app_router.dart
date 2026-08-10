import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../controller/cubits/auth_cubit.dart';
import '../../view/screens/clinics_screen.dart';
import '../../view/screens/home_shell.dart';
import '../../view/screens/insights_screen.dart';
import '../../view/screens/learn_screen.dart';
import '../../view/screens/login_screen.dart';
import '../../view/screens/onboarding_screen.dart';
import '../../view/screens/plan_screen.dart';
import '../../view/screens/profile_screen.dart';
import '../../view/screens/profile_wizard_screen.dart';
import '../../view/screens/register_screen.dart';
import '../../view/screens/splash_screen.dart';
import '../widgets/page_title.dart';

GoRouter buildAppRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final auth = authCubit.state;
      final location = state.matchedLocation;
      final onSplash = location == '/splash';
      final onOnboarding = location == '/onboarding';
      final onAuthForm = location == '/login' || location == '/register';
      final onWizard = location == '/profile-wizard';

      if (auth.status == AuthStatus.unknown) {
        return onSplash ? null : '/splash';
      }

      if (auth.status == AuthStatus.unauthenticated) {
        if (onOnboarding || onAuthForm) return null;
        return '/onboarding';
      }

      // Authenticated from here on.
      if (!auth.onboardingComplete) {
        return onWizard ? null : '/profile-wizard';
      }

      // Completed users may reopen /profile-wizard to edit their answers.
      if (onSplash || onOnboarding || onAuthForm) {
        return '/home';
      }

      // Legacy route aliases from the 5-tab shell.
      if (location == '/home/insights') return '/home';
      if (location == '/home/plan') return '/home/roadmap';
      if (location == '/home/progress') return '/home/roadmap';

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const PageTitle(titleKey: 'welcome', child: OnboardingScreen()),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const PageTitle(titleKey: 'signIn', child: LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const PageTitle(titleKey: 'register', child: RegisterScreen()),
      ),
      GoRoute(
        path: '/profile-wizard',
        builder: (context, state) =>
            const PageTitle(titleKey: 'healthQuestionnaire', child: ProfileWizardScreen()),
      ),
      GoRoute(
        path: '/clinics',
        builder: (context, state) => const PageTitle(titleKey: 'clinics', child: ClinicsScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) =>
                    const PageTitle(titleKey: 'home', child: InsightsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/roadmap',
                builder: (context, state) =>
                    const PageTitle(titleKey: 'plan', child: PlanScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/learn',
                builder: (context, state) => const PageTitle(titleKey: 'learn', child: LearnScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/profile',
                builder: (context, state) => const PageTitle(titleKey: 'profile', child: ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
