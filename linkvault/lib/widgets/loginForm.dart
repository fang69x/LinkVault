import 'package:flutter/material.dart';
import 'package:linkvault/providers/auth_provider.dart';
import 'package:linkvault/utils/form_validator.dart';
import 'package:linkvault/widgets/build_primary_button.dart';
import 'package:linkvault/widgets/custom_text.dart';
import 'package:linkvault/widgets/socialLoginButton.dart';

class LoginForm extends StatefulWidget {
  final AuthState authState;
  final Function() onLogin;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginForm({
    super.key,
    required this.authState,
    required this.onLogin,
    required this.emailController,
    required this.passwordController,
    required bool isLoading,
    required ThemeData theme,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _loginFormKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: widget.emailController,
              label: 'Email',
              hint: 'your.email@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: FormValidators.emailValidator,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: widget.passwordController,
              label: 'Password',
              hint: '••••••••',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              toggleObscureText: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              validator: FormValidators.passwordValidator,
            ),
            const SizedBox(height: 8),
            _buildForgotPasswordLink(theme),
            const SizedBox(height: 32),
            buildPrimaryButton(
              onPressed: () {
                if (_loginFormKey.currentState!.validate()) {
                  widget.onLogin();
                }
              },
              label: 'Login',
              isLoading: widget.authState.isLoading,
              theme: theme,
            ),
            const SizedBox(height: 24),
            const SocialLoginButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPasswordLink(ThemeData theme) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // Implement forgot password functionality
        },
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          foregroundColor: theme.colorScheme.primary,
        ),
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
