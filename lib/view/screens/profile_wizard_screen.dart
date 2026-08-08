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

/// US 1.1 questionnaire: two-step demographics + lifestyle wizard backed
/// by a [Form]/[GlobalKey] with field-level validators. Because the
/// currently-hidden step's fields are not mounted, `_formKey.validate()`
/// only checks the step that's on screen, giving true per-step validation
/// without duplicating a [Form] per step.
///
/// On finish it saves the profile, inserts an immutable questionnaire
/// snapshot row (US 1.1), recomputes insights via [InsightsCubit],
/// refreshes today's habits, flips [AuthCubit.markOnboardingComplete],
/// and navigates straight to Personal Insights.
class ProfileWizardScreen extends StatefulWidget {
  const ProfileWizardScreen({super.key});

  @override
  State<ProfileWizardScreen> createState() => _ProfileWizardScreenState();
}

class _ProfileWizardScreenState extends State<ProfileWizardScreen> {
  final _formKey = GlobalKey<FormState>();
  int step = 0;
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _bmi;
  String? gender;
  String? stateValue;
  String activity = 'moderate';
  String diet = 'average';
  bool smoking = false;
  bool highBp = false;
  bool _submitting = false;
  String? _error;
  final QuestionnaireRepository _questionnaireRepository = QuestionnaireRepository();

  @override
  void initState() {
    super.initState();
    final seed = context.read<ProfileCubit>().state.profile;
    _name = TextEditingController(text: seed?.fullName ?? '');
    _age = TextEditingController(text: seed != null ? seed.age.toString() : '');
    _bmi = TextEditingController(text: seed != null ? seed.bmi.toString() : '');
    gender = seed?.gender;
    stateValue = (seed != null && malaysianStates.contains(seed.state)) ? seed.state : null;
    activity = seed?.activityLevel ?? 'moderate';
    diet = seed?.dietHabit ?? 'average';
    smoking = seed?.smoking ?? false;
    highBp = seed?.highBloodPressure ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _bmi.dispose();
    super.dispose();
  }

  Future<void> _submit(bool finish) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authState = context.read<AuthCubit>().state;
    final userId = authState.userId;
    if (userId == null) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    final current =
        context.read<ProfileCubit>().state.profile ?? Profile.empty(userId, email: authState.email);
    final age = int.parse(_age.text.trim());
    final bmi = double.parse(_bmi.text.trim());
    final updated = current.copyWith(
      id: userId,
      email: authState.email,
      fullName: _name.text.trim(),
      age: age,
      gender: gender,
      state: stateValue,
      activityLevel: activity,
      dietHabit: diet,
      smoking: smoking,
      bmi: bmi,
      highBloodPressure: highBp,
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
            'fullName': saved.fullName,
            'age': saved.age,
            'gender': saved.gender,
            'state': saved.state,
            'activityLevel': saved.activityLevel,
            'dietHabit': saved.dietHabit,
            'smoking': saved.smoking,
            'bmi': saved.bmi,
            'highBloodPressure': saved.highBloodPressure,
          },
        );
      } catch (_) {
        // Non-fatal: the mutable profile row (and thus Health Age) is
        // already saved; the questionnaire log is best-effort history.
      }

      await insightsCubit.recalculate(saved);
      await habitsCubit.refreshToday();
      authCubit.markOnboardingComplete();
      if (!mounted) return;
      context.go('/home/insights');
    } else {
      setState(() => step = 1);
    }

    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(step == 0 ? AppStrings.t('demographics', locale) : AppStrings.t('lifestyle', locale)),
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
                      child: step == 0 ? _demographics(context, locale) : _lifestyle(context, locale),
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

  Widget _demographics(BuildContext context, String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: AppStrings.t('fullName', locale)),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? AppStrings.t('validationRequired', locale) : null,
        ),
        const SizedBox(height: 14),
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
        Text(AppStrings.t('gender', locale), style: Theme.of(context).textTheme.labelLarge),
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
        const SizedBox(height: 16),
        FormField<String>(
          initialValue: stateValue,
          validator: (v) => v == null ? AppStrings.t('validationSelect', locale) : null,
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: stateValue,
                  decoration: InputDecoration(
                    labelText: AppStrings.t('state', locale),
                    errorText: field.errorText,
                  ),
                  items: malaysianStates
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() => stateValue = v);
                    field.didChange(v);
                  },
                ),
              ],
            );
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
        TextFormField(
          controller: _bmi,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: AppStrings.t('bmi', locale)),
          validator: (v) {
            final trimmed = v?.trim() ?? '';
            if (trimmed.isEmpty) return AppStrings.t('validationRequired', locale);
            final parsed = double.tryParse(trimmed);
            if (parsed == null || parsed < 10 || parsed > 60) {
              return AppStrings.t('validationBmiRange', locale);
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(AppStrings.t('smoking', locale), style: const TextStyle(fontSize: 16)),
          value: smoking,
          onChanged: (v) => setState(() => smoking = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(AppStrings.t('highBp', locale), style: const TextStyle(fontSize: 16)),
          value: highBp,
          onChanged: (v) => setState(() => highBp = v),
        ),
      ],
    );
  }
}
