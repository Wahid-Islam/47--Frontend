import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/cubits/auth_cubit.dart';
import '../../controller/cubits/locale_cubit.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/widgets/banners.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/centered_pane.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t('register', locale))),
      body: SafeArea(
        child: CenteredPane(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.t('createAccountSubtitle', locale),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthCubit, AuthState>(
                    buildWhen: (previous, current) => previous.errorMessage != current.errorMessage,
                    builder: (context, state) => state.errorMessage != null
                        ? ErrorBanner(state.errorMessage!)
                        : const SizedBox.shrink(),
                  ),
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.name],
                    decoration: InputDecoration(labelText: AppStrings.t('fullName', locale)),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? AppStrings.t('validationRequired', locale) : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(labelText: AppStrings.t('email', locale)),
                    validator: (v) =>
                        (v == null || !v.contains('@')) ? AppStrings.t('validationEmail', locale) : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(labelText: AppStrings.t('password', locale)),
                    validator: (v) => (v == null || v.length < 6)
                        ? AppStrings.t('validationPasswordMin', locale)
                        : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthCubit, AuthState>(
                    buildWhen: (previous, current) => previous.busy != current.busy,
                    builder: (context, state) {
                      return HpPrimaryButton(
                        label: AppStrings.t('register', locale),
                        loading: state.busy,
                        onPressed: _submit,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await context.read<AuthCubit>().register(_email.text.trim(), _password.text, _name.text.trim());
    } catch (_) {
      // Error surfaced via AuthState.errorMessage.
    }
  }
}
