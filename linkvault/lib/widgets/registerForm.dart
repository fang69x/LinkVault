import 'dart:io';
import 'package:flutter/material.dart';
import 'package:linkvault/providers/auth_provider.dart';
import 'package:linkvault/utils/form_validator.dart';
import 'package:linkvault/widgets/avatar_picker.dart';
import 'package:linkvault/widgets/build_primary_button.dart';
import 'package:linkvault/widgets/custom_text.dart';
import 'package:linkvault/widgets/termCheckBox.dart';

class RegisterForm extends StatefulWidget {
  final AuthState authState;
  final Function() onRegister;
  final Function(String) onError;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final File? avatarFile;
  final Function(File) onAvatarSelected;

  const RegisterForm({
    super.key,
    required this.authState,
    required this.onRegister,
    required this.onError,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.avatarFile,
    required this.onAvatarSelected,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _registerFormKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AvatarPicker(
              avatarFile: widget.avatarFile,
              onImageSelected: widget.onAvatarSelected,
              onError: widget.onError,
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: widget.nameController,
              label: 'Full Name',
              hint: 'John Doe',
              icon: Icons.person_outline,
              validator: FormValidators.nameValidator,
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            CustomTextField(
              controller: widget.confirmPasswordController,
              label: 'Confirm Password',
              hint: '••••••••',
              icon: Icons.lock_outline,
              obscureText: _obscureConfirmPassword,
              toggleObscureText: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              validator: FormValidators.passwordValidator,
            ),
            const SizedBox(height: 20),
            TermsCheckbox(
              value: _agreeToTerms,
              onChanged: (value) {
                setState(() {
                  _agreeToTerms = value ?? false;
                });
              },
            ),
            const SizedBox(height: 32),
            buildPrimaryButton(
              onPressed: () {
                if (_registerFormKey.currentState!.validate()) {
                  if (!_agreeToTerms) {
                    widget.onError(
                        'Please agree to the Terms and Privacy Policy');
                    return;
                  }

                  if (widget.passwordController.text !=
                      widget.confirmPasswordController.text) {
                    widget.onError('Passwords do not match');
                    return;
                  }

                  widget.onRegister();
                }
              },
              label: 'Create Account',
              isLoading: widget.authState.isLoading,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}
