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
import '../../model/profile.dart';

/// Post-registration questionnaire.
///
/// Name/email/password were already collected at sign-up, so this wizard
/// never asks for full name again.
///
/// Step 0: Age, Sex, Smoking, Height, Weight
/// Step 1: Physical activity, Diet, Alcohol, Sleep
class ProfileWizardScreen extends StatefulWidget {
  const ProfileWizardScreen({super.key});

  @override
  State<ProfileWizardScreen> createState() => _ProfileWizardScreenState();
}

class _ProfileWizardScreenState extends State<ProfileWizardScreen> {
  final _formKey = GlobalKey<FormState>();
  int step = 0;
  late final TextEditingController _age;
  late final TextEditingController _height;
  late final TextEditingController _weight;
  late final TextEditingController _sleep;
  String? gender;
  String activity = 'moderate';
  String diet = 'average';
  String alcohol = 'none';
  bool smoking = false;
  bool _submitting = false;
  String? _error;
  final QuestionnaireRepository _questionnaireRepository = QuestionnaireRepository();

  @override
  void initState() {
    super.initState();
    final seed = context.read<ProfileCubit>().state.profile;
    _age = TextEditingController(text: seed != null && seed.onboardingComplete ? seed.age.toString() : '');
    _height = TextEditingController(
      text: seed != null && seed.onboardingComplete ? seed.heightCm.toStringAsFixed(0) : '',
    );
    _weight = TextEditingController(
      text: seed != null && seed.onboardingComplete ? seed.weightKg.toStringAsFixed(1) : '',
    );
    _sleep = TextEditingController(
      text: seed != null && seed.onboardingComplete ? seed.sleepHours.toString() : '',
    );
    gender = seed?.onboardingComplete == true ? seed!.gender : null;
    activity = seed?.activityLevel ?? 'moderate';
    diet = seed?.dietHabit ?? 'average';
    alcohol = seed?.alcohol ?? 'none';
    smoking = seed?.smoking ?? false;
  }

  @override
  void dispose() {
    _age.dispose();
    _height.dispose();
    _weight.dispose();
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

    final age = int.tryParse(_age.text.trim()) ?? current.age;
    final height = _parseDecimal(_height.text) ?? current.heightCm;
    final weight = _parseDecimal(_weight.text) ?? current.weightKg;
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
        TextFormField(
          controller: _age,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: AppStrings.t('age', locale)),
          validator: (v) {
            final trimmed = v?.trim() ?? '';
            if (trimmed.isEmpty) return AppStrings.t('validationRequired', locale);
            final parsed = int.tryParse(trimmed);
            if (parsed == null || parsed < 18 || parsed > 90) {
              return AppStrings.t('validationAgeRange', locale);
            }
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
        const SizedBox(height: 8),
        TextFormField(
          controller: _height,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: AppStrings.t('heightCm', locale)),
          validator: (v) {
            final parsed = _parseDecimal(v ?? '');
            if (parsed == null) return AppStrings.t('validationRequired', locale);
            if (parsed < 100 || parsed > 250) return AppStrings.t('validationHeightRange', locale);
            return null;
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _weight,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: AppStrings.t('weightKg', locale)),
          validator: (v) {
            final parsed = _parseDecimal(v ?? '');
            if (parsed == null) return AppStrings.t('validationRequired', locale);
            if (parsed < 30 || parsed > 250) return AppStrings.t('validationWeightRange', locale);
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
