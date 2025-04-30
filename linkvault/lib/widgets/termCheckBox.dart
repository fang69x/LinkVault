import 'package:flutter/material.dart';

class TermsCheckbox extends StatelessWidget {
  final bool value;
  final Function(bool?) onChanged;

  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: Theme.of(context).copyWith(
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onBackground,
            ),
            children: [
              const TextSpan(text: 'I agree to the '),
              TextSpan(
                text: 'Terms of Service',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: ' and '),
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
