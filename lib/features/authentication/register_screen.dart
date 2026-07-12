import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_session.dart';
import '../../core/design_system/design_system.dart';
import '../../core/errors/app_error.dart';
import 'widgets/auth_widgets.dart';

/// Create an email/password account. The response is enumeration-safe, so success
/// shows a neutral confirmation and routes to sign-in rather than logging in.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _displayName = TextEditingController();
  bool _busy = false;
  bool _done = false;
  AppError? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _displayName.dispose();
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
          .register(
            _email.text,
            _password.text,
            displayName: _displayName.text.isEmpty ? null : _displayName.text,
          );
      if (mounted) {
        setState(() => _done = true);
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
    if (_done) {
      return AuthScaffold(
        title: 'Almost there',
        subtitle:
            'If that address is available, your account is ready. Sign in to continue — '
            'if it was already registered, we have emailed the owner instead.',
        children: <Widget>[
          const SizedBox(height: AppSpacing.md),
          AuthPrimaryButton(
            label: 'Go to sign in',
            onPressed: () => context.go('/login'),
          ),
        ],
      );
    }

    final ValidationError? validation = _error is ValidationError
        ? _error! as ValidationError
        : null;
    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Keep your progress across devices.',
      children: <Widget>[
        if (_error != null &&
            (validation == null || validation.fieldErrors.isEmpty))
          AuthErrorBanner(error: _error!),
        AuthTextField(
          controller: _email,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          errorText: validation?.firstFor('email'),
        ),
        AuthTextField(
          controller: _password,
          label: 'Password (min 8 characters)',
          obscureText: true,
          textInputAction: TextInputAction.next,
          errorText: validation?.firstFor('password'),
        ),
        AuthTextField(
          controller: _displayName,
          label: 'Display name (optional)',
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          errorText: validation?.firstFor('displayName'),
        ),
        const SizedBox(height: AppSpacing.sm),
        AuthPrimaryButton(
          label: 'Create account',
          busy: _busy,
          onPressed: _submit,
        ),
        AuthLinkButton(
          label: 'I already have an account',
          onPressed: _busy ? null : () => context.go('/login'),
        ),
      ],
    );
  }
}
