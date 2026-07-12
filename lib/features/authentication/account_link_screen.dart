import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_session.dart';
import '../../core/design_system/design_system.dart';
import '../../core/errors/app_error.dart';
import 'widgets/auth_widgets.dart';

/// Merge the current guest into an existing account. Progress is preserved and
/// carried into the account; a failure never deletes local progress.
class AccountLinkScreen extends ConsumerStatefulWidget {
  const AccountLinkScreen({super.key});

  @override
  ConsumerState<AccountLinkScreen> createState() => _AccountLinkScreenState();
}

class _AccountLinkScreenState extends ConsumerState<AccountLinkScreen> {
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
          .linkAccount(_email.text, _password.text);
      if (mounted) {
        context.go('/profile');
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
      title: 'Link your account',
      subtitle:
          'Sign in with your existing account to merge this device into it. Your local '
          'progress is kept — nothing is deleted if linking fails.',
      children: <Widget>[
        if (_error != null &&
            (validation == null || validation.fieldErrors.isEmpty))
          AuthErrorBanner(error: _error!),
        AuthTextField(
          controller: _email,
          label: 'Account email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          errorText: validation?.firstFor('email'),
        ),
        AuthTextField(
          controller: _password,
          label: 'Account password',
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          errorText: validation?.firstFor('password'),
        ),
        const SizedBox(height: AppSpacing.sm),
        AuthPrimaryButton(
          label: 'Link account',
          busy: _busy,
          onPressed: _submit,
        ),
        const SizedBox(height: AppSpacing.sm),
        AuthLinkButton(
          label: 'Need an account? Create one first',
          onPressed: _busy ? null : () => context.push('/register'),
        ),
      ],
    );
  }
}
