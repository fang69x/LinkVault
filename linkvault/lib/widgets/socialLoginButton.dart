import 'package:flutter/material.dart';
import 'package:linkvault/widgets/social_button.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildDivider(theme),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SocialButton(
              onPressed: () {
                // Implement Google login
              },
              icon: 'assets/icons/google.svg',
              label: 'Google',
              theme: theme,
            ),
            SocialButton(
              onPressed: () {
                // Implement Facebook login
              },
              icon: 'assets/icons/facebook.svg',
              label: 'Facebook',
              theme: theme,
            ),
            SocialButton(
              onPressed: () {
                // Implement Apple login
              },
              icon: 'assets/icons/apple.svg',
              label: 'Apple',
              theme: theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: theme.colorScheme.onBackground.withOpacity(0.2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR CONTINUE WITH',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onBackground.withOpacity(0.5),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: theme.colorScheme.onBackground.withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}
