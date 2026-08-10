import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../controller/cubits/auth_cubit.dart';
import '../../controller/cubits/habits_cubit.dart';
import '../../controller/cubits/insights_cubit.dart';
import '../../controller/cubits/locale_cubit.dart';
import '../../controller/cubits/profile_cubit.dart';
import '../../controller/repositories/questionnaire_repository.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/banners.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/centered_pane.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/scroll_number_field.dart';
import '../../model/profile.dart';

class ProfileWizardScreen extends StatefulWidget {
  const ProfileWizardScreen({super.key});

  @override
  State<ProfileWizardScreen> createState() => _ProfileWizardScreenState();
}

class _ProfileWizardScreenState extends State<ProfileWizardScreen> {
  final _formKey = GlobalKey<FormState>();
  int step = 0;
  late int _ageValue;
  late double _heightValue;
  late double _weightValue;
  late final TextEditingController _sleep;
  String? gender;
  String activity = 'moderate';
  String diet = 'average';
  String alcohol = 'none';
  bool smoking = false;
  bool highBloodPressure = false;
  bool diabetes = false;
  bool _submitting = false;
  String? _error;
  final QuestionnaireRepository _questionnaireRepository = QuestionnaireRepository();

  @override
  void initState() {
    super.initState();
    final seed = context.read<ProfileCubit>().state.profile;
    final editing = seed != null && seed.onboardingComplete;
    _ageValue = editing ? seed.age.clamp(18, 90) : 30;
    _heightValue = editing ? seed.heightCm.clamp(100, 250).roundToDouble() : 165;
    _weightValue = editing ? seed.weightKg.clamp(30, 250) : 65;
    // Keep half-kilogram steps for weight scrolling.
    _weightValue = (_weightValue * 2).round() / 2;
    _sleep = TextEditingController(
      text: editing ? seed.sleepHours.toString() : '',
    );
    gender = editing ? seed.gender : null;
    activity = seed?.activityLevel ?? 'moderate';
    diet = seed?.dietHabit ?? 'average';
    alcohol = seed?.alcohol ?? 'none';
    smoking = seed?.smoking ?? false;
    highBloodPressure = seed?.highBloodPressure ?? false;
    diabetes = seed?.diabetes ?? false;
  }

  @override
  void dispose() {
    _sleep.dispose();
    super.dispose();
  }

  double? _parseDecimal(String raw) {
    final text = raw.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  Future<void> _submit(bool finish) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authState = context.read<AuthCubit>().state;
    final userId = authState.userId;
    if (userId == null) return;
    final editingExisting = authState.onboardingComplete;

    setState(() {
      _submitting = true;
      _error = null;
    });

    final current =
        context.read<ProfileCubit>().state.profile ?? Profile.empty(userId, email: authState.email);

    final age = _ageValue;
    final height = _heightValue;
    final weight = _weightValue;
    final sleep = _parseDecimal(_sleep.text) ?? current.sleepHours;
    final bmi = Profile.bmiFromHeightWeight(height, weight) ?? current.bmi;

    if (finish) {
      final locale = context.read<LocaleCubit>().state;
      if (age < 18 || age > 90) {
        setState(() {
          _submitting = false;
          _error = AppStrings.t('validationAgeRange', locale);
        });
        return;
      }
      if (bmi < 10 || bmi > 60) {
        setState(() {
          _submitting = false;
          _error = AppStrings.t('validationHeightWeight', locale);
        });
        return;
      }
    }

    final updated = current.copyWith(
      id: userId,
      email: authState.email,
      // Keep the name collected at registration — never overwrite from this form.
      fullName: current.fullName,
      age: age,
      gender: gender,
      activityLevel: activity,
      dietHabit: diet,
      smoking: smoking,
      heightCm: height,
      weightKg: weight,
      bmi: double.parse(bmi.toStringAsFixed(1)),
      alcohol: alcohol,
      sleepHours: sleep,
      highBloodPressure: highBloodPressure,
      diabetes: diabetes,
      onboardingComplete: finish,
      locale: context.read<LocaleCubit>().state,
    );

    final profileCubit = context.read<ProfileCubit>();
    final insightsCubit = context.read<InsightsCubit>();
    final habitsCubit = context.read<HabitsCubit>();
    final authCubit = context.read<AuthCubit>();

    final saved = await profileCubit.save(updated);
    if (!mounted) return;

    if (saved == null) {
      setState(() {
        _submitting = false;
        _error = profileCubit.state.errorMessage;
      });
      return;
    }

    if (finish) {
      try {
        await _questionnaireRepository.submit(
          userId: userId,
          answers: {
            'age': saved.age,
            'sex': saved.gender,
            'smoking': saved.smoking,
            'heightCm': saved.heightCm,
            'weightKg': saved.weightKg,
            'bmi': saved.bmi,
            'activityLevel': saved.activityLevel,
            'diet': saved.dietHabit,
            'alcohol': saved.alcohol,
            'sleepHours': saved.sleepHours,
            'highBloodPressure': saved.highBloodPressure,
            'diabetes': saved.diabetes,
          },
        );
      } catch (_) {
        // Non-fatal: profile + Health Age already saved.
      }

      await insightsCubit.recalculate(saved);
      await habitsCubit.refreshToday();
      authCubit.markOnboardingComplete();
      if (!mounted) return;
      context.go(editingExisting ? '/home/profile' : '/home');
    } else {
      setState(() => step = 1);
    }

    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;

    final canLeave = context.read<AuthCubit>().state.onboardingComplete;

    return Scaffold(
      appBar: AppBar(
        title: Text(step == 0 ? AppStrings.t('demographics', locale) : AppStrings.t('lifestyle', locale)),
        leading: canLeave
            ? IconButton(
                icon: const Icon(Icons.close),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home/profile');
                  }
                },
              )
            : null,
      ),
      body: SafeArea(
        child: CenteredPane(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: (step + 1) / 2,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 20),
                  if (_error != null) ErrorBanner(_error!),
                  Expanded(
                    child: SingleChildScrollView(
                      child: step == 0 ? _basics(context, locale) : _lifestyle(context, locale),
                    ),
                  ),
                  Row(
                    children: [
                      if (step > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _submitting ? null : () => setState(() => step = 0),
                            child: Text(AppStrings.t('back', locale)),
                          ),
                        ),
                      if (step > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: HpPrimaryButton(
                          label: step == 0 ? AppStrings.t('next', locale) : AppStrings.t('finish', locale),
                          loading: _submitting,
                          onPressed: () => _submit(step == 1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _basics(BuildContext context, String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScrollNumberField(
          label: AppStrings.t('age', locale),
          value: _ageValue.toDouble(),
          min: 18,
          max: 90,
          step: 1,
          onChanged: (v) => setState(() => _ageValue = v.round()),
          validator: (v) {
            if (v < 18 || v > 90) return AppStrings.t('validationAgeRange', locale);
            return null;
          },
        ),
        const SizedBox(height: 16),
        Text(AppStrings.t('sex', locale), style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        FormField<String>(
          initialValue: gender,
          validator: (v) => v == null ? AppStrings.t('validationSelect', locale) : null,
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChoiceChipRow(
                  value: gender,
                  onChanged: (v) {
                    setState(() => gender = v);
                    field.didChange(v);
                  },
                  options: [
                    (value: 'male', label: AppStrings.t('male', locale)),
                    (value: 'female', label: AppStrings.t('female', locale)),
                    (value: 'other', label: AppStrings.t('other', locale)),
                  ],
                ),
                if (field.hasError) _fieldError(field.errorText!),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(AppStrings.t('smoking', locale), style: const TextStyle(fontSize: 16)),
          value: smoking,
          onChanged: (v) => setState(() => smoking = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(AppStrings.t('highBp', locale), style: const TextStyle(fontSize: 16)),
          value: highBloodPressure,
          onChanged: (v) => setState(() => highBloodPressure = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(AppStrings.t('diabetesDiagnosed', locale), style: const TextStyle(fontSize: 16)),
          value: diabetes,
          onChanged: (v) => setState(() => diabetes = v),
        ),
        const SizedBox(height: 8),
        ScrollNumberField(
          label: AppStrings.t('heightCm', locale),
          value: _heightValue,
          min: 100,
          max: 250,
          step: 1,
          suffix: 'cm',
          onChanged: (v) => setState(() => _heightValue = v),
          validator: (v) {
            if (v < 100 || v > 250) return AppStrings.t('validationHeightRange', locale);
            return null;
          },
        ),
        const SizedBox(height: 14),
        ScrollNumberField(
          label: AppStrings.t('weightKg', locale),
          value: _weightValue,
          min: 30,
          max: 250,
          step: 0.5,
          decimals: 1,
          suffix: 'kg',
          onChanged: (v) => setState(() => _weightValue = v),
          validator: (v) {
            if (v < 30 || v > 250) return AppStrings.t('validationWeightRange', locale);
            return null;
          },
        ),
      ],
    );
  }

  Widget _fieldError(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(text, style: const TextStyle(color: AppTheme.riskHigh, fontSize: 13)),
    );
  }

  Widget _lifestyle(BuildContext context, String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.t('activity', locale), style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        FormField<String>(
          initialValue: activity,
          validator: (v) => (v == null || v.isEmpty) ? AppStrings.t('validationSelect', locale) : null,
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChoiceChipRow(
                  value: activity,
                  onChanged: (v) {
                    setState(() => activity = v);
                    field.didChange(v);
                  },
                  options: [
                    (value: 'low', label: AppStrings.t('low', locale)),
                    (value: 'moderate', label: AppStrings.t('moderate', locale)),
                    (value: 'high', label: AppStrings.t('high', locale)),
                  ],
                ),
                if (field.hasError) _fieldError(field.errorText!),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Text(AppStrings.t('diet', locale), style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        FormField<String>(
          initialValue: diet,
          validator: (v) => (v == null || v.isEmpty) ? AppStrings.t('validationSelect', locale) : null,
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChoiceChipRow(
                  value: diet,
                  onChanged: (v) {
                    setState(() => diet = v);
                    field.didChange(v);
                  },
                  options: [
                    (value: 'unhealthy', label: AppStrings.t('unhealthy', locale)),
                    (value: 'average', label: AppStrings.t('average', locale)),
                    (value: 'healthy', label: AppStrings.t('healthy', locale)),
                  ],
                ),
                if (field.hasError) _fieldError(field.errorText!),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Text(AppStrings.t('alcohol', locale), style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        FormField<String>(
          initialValue: alcohol,
          validator: (v) => (v == null || v.isEmpty) ? AppStrings.t('validationSelect', locale) : null,
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChoiceChipRow(
                  value: alcohol,
                  onChanged: (v) {
                    setState(() => alcohol = v);
                    field.didChange(v);
                  },
                  options: [
                    (value: 'none', label: AppStrings.t('alcoholNone', locale)),
                    (value: 'occasional', label: AppStrings.t('alcoholOccasional', locale)),
                    (value: 'regular', label: AppStrings.t('alcoholRegular', locale)),
                  ],
                ),
                if (field.hasError) _fieldError(field.errorText!),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _sleep,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: AppStrings.t('sleepHours', locale)),
          validator: (v) {
            final parsed = _parseDecimal(v ?? '');
            if (parsed == null) return AppStrings.t('validationRequired', locale);
            if (parsed < 3 || parsed > 14) return AppStrings.t('validationSleepRange', locale);
            return null;
          },
        ),
      ],
    );
  }
}
