import 'dart:ui';
import 'package:flutter/material.dart';

class buildPrimaryButton extends StatelessWidget {
  const buildPrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.isLoading,
    required this.theme,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        shadowColor: theme.colorScheme.primary.withOpacity(0.4),
      ),
      child: isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onPrimary,
              ),
            )
          : Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
