import 'dart:ui';
import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.theme,
  });

  final VoidCallback onPressed;
  final String icon;
  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    bool useIconFallback =
        true; // Toggle to true if SVG assets aren't available

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Use icon fallback if SVG assets aren't available
          if (useIconFallback)
            Icon(
              label == 'Google'
                  ? Icons.g_mobiledata
                  : label == 'Facebook'
                      ? Icons.facebook
                      : Icons.apple,
              size: 24,
              color: theme.colorScheme.primary,
            )
        ],
      ),
    );
  }
}
