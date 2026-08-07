import 'package:flutter/material.dart';

/// Full-width primary call-to-action button with a min 48px tap target and
/// a built-in busy spinner, used across onboarding/auth/profile flows.
class HpPrimaryButton extends StatelessWidget {
  const HpPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, size: 22), const SizedBox(width: 8)],
                  Text(label),
                ],
              ),
      ),
    );
  }
}
