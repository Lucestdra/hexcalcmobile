import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_session.dart';
import '../../core/design_system/design_system.dart';
import '../../core/errors/app_error.dart';
import 'widgets/auth_widgets.dart';

/// Complete a password reset with the emailed code. On success every session is
/// revoked server-side, so the user signs in again with the new password.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({this.initialEmail, super.key});

  final String? initialEmail;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  late final TextEditingController _email = TextEditingController(
    text: widget.initialEmail ?? '',
  );
  final TextEditingController _token = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _busy = false;
  bool _done = false;
  AppError? _error;

  @override
  void dispose() {
    _email.dispose();
    _token.dispose();
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
          .resetPassword(_email.text, _token.text, _password.text);
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
        title: 'Password updated',
        subtitle:
            'Your password has been reset. Sign in with your new password.',
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
      title: 'New password',
      subtitle: 'Enter the code from your email and a new password.',
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
          controller: _token,
          label: 'Reset code',
          textInputAction: TextInputAction.next,
          errorText: validation?.firstFor('token'),
        ),
        AuthTextField(
          controller: _password,
          label: 'New password (min 8 characters)',
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          errorText: validation?.firstFor('newPassword'),
        ),
        const SizedBox(height: AppSpacing.sm),
        AuthPrimaryButton(
          label: 'Update password',
          busy: _busy,
          onPressed: _submit,
        ),
      ],
    );
  }
}
