import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/errors/app_error.dart';

/// A consistent, token-styled scaffold for the auth screens: near-black
/// background, a back affordance, a title, and a scrollable body that respects
/// the keyboard inset.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.children,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondaryText),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                title,
                style: AppTypography.title.copyWith(
                  fontSize: 28,
                  letterSpacing: 2,
                ),
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Text(subtitle!, style: AppTypography.body),
              ],
              const SizedBox(height: AppSpacing.xl),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// A token-styled text field with an optional server field error.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    required this.label,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.errorText,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? errorText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  /// Password-manager / autofill hints (e.g. `AutofillHints.email`).
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        autofillHints: autofillHints,
        // Credentials are never prose: no autocorrect/suggestions.
        autocorrect: false,
        enableSuggestions: false,
        style: AppTypography.body.copyWith(color: AppColors.primaryText),
        cursorColor: AppColors.neonBlue,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          errorText: errorText,
          labelStyle: AppTypography.body,
          filled: true,
          fillColor: AppColors.surface,
          enabledBorder: _border(AppColors.inactiveBorder),
          focusedBorder: _border(AppColors.neonBlue),
          errorBorder: _border(AppColors.warning),
          focusedErrorBorder: _border(AppColors.warning),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadii.md),
    borderSide: BorderSide(color: color, width: AppStroke.thin),
  );
}

/// The neon primary CTA, with an in-flight spinner that also disables the button.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    this.busy = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    // ElevatedButton already exposes button semantics; while busy the spinner
    // carries the label so screen readers still announce the action.
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: busy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonBlue,
          disabledBackgroundColor: AppColors.inactiveCell,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
        child: busy
            ? Semantics(
                label: label,
                child: const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.background,
                  ),
                ),
              )
            : Text(label, style: AppTypography.button),
      ),
    );
  }
}

/// A text button for secondary navigation ("Create account", "Forgot password?").
class AuthLinkButton extends StatelessWidget {
  const AuthLinkButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: AppTypography.body.copyWith(color: AppColors.neonBlue),
      ),
    );
  }
}

/// A non-field error banner. Offline failures read as informational; everything
/// else as a restrained warning. Never blames the player; never leaks internals.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({required this.error, super.key});

  final AppError error;

  @override
  Widget build(BuildContext context) {
    final bool offline = error.isOffline;
    final Color color = offline ? AppColors.secondaryText : AppColors.warning;
    // A live region so a screen reader announces the failure when it appears.
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: color, width: AppStroke.thin),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              color: color,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                error.message,
                style: AppTypography.body.copyWith(
                  color: AppColors.primaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
