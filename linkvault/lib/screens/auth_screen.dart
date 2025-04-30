import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkvault/providers/auth_provider.dart';
import 'package:linkvault/routes/app_routes.dart';
import 'package:linkvault/utils/form_validator.dart';
import 'package:linkvault/widgets/build_primary_button.dart';
import 'package:linkvault/widgets/responsive_container.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkvault/widgets/social_button.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  // Form controllers
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State variables
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLogin = true;
  File? _avatarFile;
  bool _agreeToTerms = true;

  // Animation controller for smooth transitions
  late TabController _tabController;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _isLogin = _tabController.index == 0;
          _pageController.animateToPage(
            _tabController.index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Pick avatar image from gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _avatarFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to pick image: $e');
      }
    }
  }

  // Handle login submission
  Future<void> _login() async {
    if (_loginFormKey.currentState!.validate()) {
      final notifier = ref.read(authNotifierProvider.notifier);

      try {
        await notifier.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } catch (e) {
        if (!mounted) return;
        _showErrorSnackBar('Login failed: ${e.toString()}');
      }
    }
  }

  // Handle registration submission
  Future<void> _register() async {
    if (_registerFormKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        _showErrorSnackBar('Please agree to the Terms and Privacy Policy');
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        _showErrorSnackBar('Passwords do not match');
        return;
      }

      final notifier = ref.read(authNotifierProvider.notifier);

      try {
        await notifier.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
          avatarPath: _avatarFile?.path,
        );
      } catch (e) {
        if (!mounted) return;
        _showErrorSnackBar('Registration failed: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: ResponsiveContainer(
          child: SafeArea(
            child: Stack(
              children: [
                // Background decorative elements
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -80,
                  left: -80,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Main content
                SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        // App Logo/Branding
                        FadeInDown(
                          duration: const Duration(milliseconds: 600),
                          child: _buildLogo(theme),
                        ),
                        const SizedBox(height: 40),
                        // Card for authentication forms
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 300),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    top: 20,
                                    bottom: 24,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface
                                        .withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      // Tab Bar for switching between login and register
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme.surfaceVariant
                                              .withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: TabBar(
                                          controller: _tabController,
                                          tabs: [
                                            Tab(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  color: _isLogin
                                                      ? theme
                                                          .colorScheme.primary
                                                      : Colors.transparent,
                                                ),
                                                child: Text(
                                                  'Login',
                                                  style: TextStyle(
                                                    color: _isLogin
                                                        ? theme.colorScheme
                                                            .onPrimary
                                                        : theme.colorScheme
                                                            .onSurfaceVariant,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Tab(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  color: !_isLogin
                                                      ? theme
                                                          .colorScheme.primary
                                                      : Colors.transparent,
                                                ),
                                                child: Text(
                                                  'Register',
                                                  style: TextStyle(
                                                    color: !_isLogin
                                                        ? theme.colorScheme
                                                            .onPrimary
                                                        : theme.colorScheme
                                                            .onSurfaceVariant,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                          dividerColor: Colors.transparent,
                                          indicatorColor: Colors.transparent,
                                          unselectedLabelColor: theme
                                              .colorScheme.onSurfaceVariant,
                                          labelColor:
                                              theme.colorScheme.onPrimary,
                                          labelPadding: EdgeInsets.zero,
                                          padding: EdgeInsets.zero,
                                          onTap: (index) {
                                            // Tab controller listener will handle this
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      // Page view for form content
                                      SizedBox(
                                        height: _isLogin ? 450 : 600,
                                        child: PageView(
                                          controller: _pageController,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          children: [
                                            _buildLoginForm(authState, theme),
                                            _buildRegisterForm(
                                                authState, theme),
                                          ],
                                          onPageChanged: (index) {
                                            setState(() {
                                              _isLogin = index == 0;
                                              if (_tabController.index !=
                                                  index) {
                                                _tabController.animateTo(index);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // App version
                        Text(
                          'LinkVault v1.0.0',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                theme.colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bookmark,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'LinkVault',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Organize your bookmarks seamlessly',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: theme.colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  // Login form
  Widget _buildLoginForm(AuthState authState, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email field
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'your.email@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: FormValidators.emailValidator,
              theme: theme,
            ),
            const SizedBox(height: 20),
            // Password field
            _buildTextField(
              controller: _passwordController,
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
              theme: theme,
            ),
            const SizedBox(height: 8),
            // Forgot password link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Implement forgot password functionality
                },
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: theme.colorScheme.primary,
                ),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Login button
            buildPrimaryButton(
                onPressed: authState.isLoading ? null : _login,
                label: 'Login',
                isLoading: authState.isLoading,
                theme: theme),
            const SizedBox(height: 24),
            // OR divider
            Row(
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
            ),
            const SizedBox(height: 24),
            // Social login buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SocialButton(
                    onPressed: () {
                      // Implement Google login
                    },
                    icon: 'assets/icons/google.svg',
                    label: 'Google',
                    theme: theme),
                SocialButton(
                    onPressed: () {
                      // Implement Facebook login
                    },
                    icon: 'assets/icons/facebook.svg',
                    label: 'Facebook',
                    theme: theme),
                SocialButton(
                    onPressed: () {
                      // Implement Apple login
                    },
                    icon: 'assets/icons/apple.svg',
                    label: 'Apple',
                    theme: theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Registration form
  Widget _buildRegisterForm(AuthState authState, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar picker
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        image: _avatarFile != null
                            ? DecorationImage(
                                image: FileImage(_avatarFile!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _avatarFile == null
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.5),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Name field
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'John Doe',
              icon: Icons.person_outline,
              validator: FormValidators.nameValidator,
              theme: theme,
            ),
            const SizedBox(height: 20),
            // Email field
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'your.email@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: FormValidators.emailValidator,
              theme: theme,
            ),
            const SizedBox(height: 20),
            // Password field
            _buildTextField(
              controller: _passwordController,
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
              theme: theme,
            ),
            const SizedBox(height: 20),
            // Confirm Password field
            _buildTextField(
              controller: _confirmPasswordController,
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
              theme: theme,
            ),
            const SizedBox(height: 20),
            // Terms and conditions checkbox
            Theme(
              data: Theme.of(context).copyWith(
                checkboxTheme: CheckboxThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              child: CheckboxListTile(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                },
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
            ),
            const SizedBox(height: 32),
            // Register button
            buildPrimaryButton(
                onPressed: authState.isLoading ? null : _register,
                label: 'Create Account',
                isLoading: authState.isLoading,
                theme: theme),
          ],
        ),
      ),
    );
  }

  // Common TextField widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ThemeData theme,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    VoidCallback? toggleObscureText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 16,
            color: theme.colorScheme.onBackground,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: theme.colorScheme.onBackground.withOpacity(0.5),
            ),
            prefixIcon: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            suffixIcon: toggleObscureText != null
                ? IconButton(
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                    onPressed: toggleObscureText,
                  )
                : null,
            filled: true,
            fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
