import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'controller/cubits/auth_cubit.dart';
import 'controller/cubits/clinics_cubit.dart';
import 'controller/cubits/habits_cubit.dart';
import 'controller/cubits/insights_cubit.dart';
import 'controller/cubits/locale_cubit.dart';
import 'controller/cubits/profile_cubit.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class HealthPathApp extends StatelessWidget {
  const HealthPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => ProfileCubit()),
        BlocProvider(create: (_) => InsightsCubit()),
        BlocProvider(create: (_) => HabitsCubit()),
        BlocProvider(create: (_) => ClinicsCubit()),
        BlocProvider(create: (_) => LocaleCubit()),
      ],
      child: const _HealthPathAppView(),
    );
  }
}

class _HealthPathAppView extends StatefulWidget {
  const _HealthPathAppView();

  @override
  State<_HealthPathAppView> createState() => _HealthPathAppViewState();
}

class _HealthPathAppViewState extends State<_HealthPathAppView> {
  late final GoRouter _router;
  String? _loadedForUserId;

  @override
  void initState() {
    super.initState();
    _router = buildAppRouter(context.read<AuthCubit>());
  }

  void _onAuthChanged(BuildContext context, AuthState state) {
    if (state.status == AuthStatus.authenticated && state.userId != null) {
      if (_loadedForUserId == state.userId) return;
      _loadedForUserId = state.userId;
      final userId = state.userId!;
      context.read<ProfileCubit>().load(userId);
      context.read<InsightsCubit>().load(userId);
      context.read<HabitsCubit>().loadToday(userId);
    } else if (state.status == AuthStatus.unauthenticated) {
      if (_loadedForUserId == null) return;
      _loadedForUserId = null;
      context.read<ProfileCubit>().clear();
      context.read<InsightsCubit>().clear();
      context.read<HabitsCubit>().clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.userId != current.userId || previous.status != current.status,
      listener: _onAuthChanged,
      child: MaterialApp.router(
        title: 'MySihat',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: _router,
      ),
    );
  }
}
