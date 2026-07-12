import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_session.dart';
import '../../core/design_system/design_system.dart';
import '../../core/errors/app_error.dart';
import 'widgets/auth_widgets.dart';

/// Request a password-reset email. Enumeration-safe: the confirmation is identical
/// whether or not the address has an account.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _email = TextEditingController();
  bool _busy = false;
  bool _done = false;
  AppError? _error;

  @override
  void dispose() {
    _email.dispose();
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
      await ref.read(authSessionProvider.notifier).forgotPassword(_email.text);
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
        title: 'Check your email',
        subtitle:
            'If that address has an account, we have sent a reset link. Enter the code from '
            'the email to choose a new password.',
        children: <Widget>[
          const SizedBox(height: AppSpacing.md),
          AuthPrimaryButton(
            label: 'Enter reset code',
            onPressed: () =>
                context.push('/reset-password', extra: _email.text.trim()),
          ),
          AuthLinkButton(
            label: 'Back to sign in',
            onPressed: () => context.go('/login'),
          ),
        ],
      );
    }

    final ValidationError? validation = _error is ValidationError
        ? _error! as ValidationError
        : null;
    return AuthScaffold(
      title: 'Reset password',
      subtitle: 'We will email you a code to reset it.',
      children: <Widget>[
        if (_error != null &&
            (validation == null || validation.fieldErrors.isEmpty))
          AuthErrorBanner(error: _error!),
        AuthTextField(
          controller: _email,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          errorText: validation?.firstFor('email'),
        ),
        const SizedBox(height: AppSpacing.sm),
        AuthPrimaryButton(
          label: 'Send reset link',
          busy: _busy,
          onPressed: _submit,
        ),
      ],
    );
  }
}
