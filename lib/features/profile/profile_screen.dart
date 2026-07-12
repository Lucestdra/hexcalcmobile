import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/dtos.dart';
import '../../core/auth/auth_session.dart';
import '../../core/design_system/design_system.dart';
import '../../core/errors/app_error.dart';
import '../../core/networking/error_mapper.dart';
import '../authentication/widgets/auth_widgets.dart';

/// The current player's profile. Re-fetches only when the session kind/user
/// changes (not on every busy/error emission).
final meProfileProvider = FutureProvider.autoDispose<PlayerProfile?>((
  ref,
) async {
  final (AuthKind kind, String? _) = ref.watch(
    authSessionProvider.select((AuthState s) => (s.kind, s.userId)),
  );
  if (kind == AuthKind.none) {
    return null;
  }
  return ref.read(hexcalcApiProvider).getMe();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState auth = ref.watch(authSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Profile',
          style: AppTypography.body.copyWith(color: AppColors.primaryText),
        ),
        iconTheme: const IconThemeData(color: AppColors.secondaryText),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: auth.isBootstrapping
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.neonBlue),
                )
              : _body(context, ref, auth),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, AuthState auth) {
    final AsyncValue<PlayerProfile?> profile = ref.watch(meProfileProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ProfileHeader(auth: auth, profile: profile),
        const SizedBox(height: AppSpacing.md),
        // The profile fetch can fail independently of the session; surface it with
        // a retry rather than a permanent placeholder.
        if (auth.hasServerSession && profile.hasError)
          _ProfileFetchError(
            error: toAppError(profile.error!),
            onRetry: () => ref.invalidate(meProfileProvider),
          ),
        const SizedBox(height: AppSpacing.md),
        ..._actions(context, ref, auth),
      ],
    );
  }

  List<Widget> _actions(BuildContext context, WidgetRef ref, AuthState auth) {
    switch (auth.kind) {
      case AuthKind.none:
        return <Widget>[
          if (auth.error != null) AuthErrorBanner(error: auth.error!),
          const _Hint(
            'Playing offline. Sign in or create an account to sync your progress.',
          ),
          const SizedBox(height: AppSpacing.md),
          AuthPrimaryButton(
            label: 'Sign in',
            onPressed: () => context.push('/login'),
          ),
          AuthLinkButton(
            label: 'Create account',
            onPressed: () => context.push('/register'),
          ),
        ];
      case AuthKind.guest:
        return <Widget>[
          const _Hint(
            'You are playing as a guest. Link an account to keep your progress safe.',
          ),
          const SizedBox(height: AppSpacing.md),
          AuthPrimaryButton(
            label: 'Link an account',
            onPressed: () => context.push('/link-account'),
          ),
          AuthLinkButton(
            label: 'Sign in instead',
            onPressed: () => context.push('/login'),
          ),
        ];
      case AuthKind.account:
        return <Widget>[
          const _Hint('Your progress syncs to your account.'),
          const SizedBox(height: AppSpacing.md),
          AuthPrimaryButton(
            label: 'Sign out',
            onPressed: () => ref.read(authSessionProvider.notifier).signOut(),
          ),
        ];
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.auth, required this.profile});

  final AuthState auth;
  final AsyncValue<PlayerProfile?> profile;

  @override
  Widget build(BuildContext context) {
    final String label = switch (auth.kind) {
      AuthKind.account => 'Signed in',
      AuthKind.guest => 'Guest',
      AuthKind.none => 'Offline',
    };
    final String name = profile.when(
      data: (PlayerProfile? p) =>
          p?.displayName ?? (auth.hasServerSession ? '—' : '—'),
      loading: () => auth.hasServerSession ? '…' : '—',
      error: (_, _) => '—',
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: AppColors.inactiveBorder,
          width: AppStroke.thin,
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.person_rounded, color: AppColors.neonBlue, size: 40),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: AppTypography.body.copyWith(
                    color: AppColors.primaryText,
                    fontSize: 20,
                  ),
                ),
                Text(label, style: AppTypography.hudLabel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileFetchError extends StatelessWidget {
  const _ProfileFetchError({required this.error, required this.onRetry});

  final AppError error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AuthErrorBanner(error: error),
        AuthLinkButton(label: 'Try again', onPressed: onRetry),
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: AppTypography.body);
}
