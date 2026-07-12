import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_session.dart';
import '../../core/design_system/design_system.dart';
import '../../core/errors/app_error.dart';
import 'widgets/auth_widgets.dart';

/// Sign in to an existing email/password account.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _busy = false;
  AppError? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authSessionProvider.notifier)
          .signIn(_email.text, _password.text);
      if (mounted) {
        context.go('/');
      }
    } on AppError catch (error) {
      if (mounted) {
        setState(() => _error = error);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ValidationError? validation = _error is ValidationError
        ? _error! as ValidationError
        : null;
    return AuthScaffold(
      title: 'Sign in',
      subtitle: 'Welcome back.',
      children: <Widget>[
        if (_error != null &&
            (validation == null || validation.fieldErrors.isEmpty))
          AuthErrorBanner(error: _error!),
        AuthTextField(
          controller: _email,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const <String>[
            AutofillHints.username,
            AutofillHints.email,
          ],
          errorText: validation?.firstFor('email'),
        ),
        AuthTextField(
          controller: _password,
          label: 'Password',
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          autofillHints: const <String>[AutofillHints.password],
          errorText: validation?.firstFor('password'),
        ),
        const SizedBox(height: AppSpacing.sm),
        AuthPrimaryButton(label: 'Sign in', busy: _busy, onPressed: _submit),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            AuthLinkButton(
              label: 'Create account',
              onPressed: _busy ? null : () => context.push('/register'),
            ),
            AuthLinkButton(
              label: 'Forgot password?',
              onPressed: _busy ? null : () => context.push('/forgot-password'),
            ),
          ],
        ),
      ],
    );
  }
}
