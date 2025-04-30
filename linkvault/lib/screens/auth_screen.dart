import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkvault/providers/auth_provider.dart';
import 'package:linkvault/widgets/authHeader.dart';
import 'package:linkvault/widgets/avatar_picker.dart';
import 'package:linkvault/widgets/loginForm.dart';
import 'package:linkvault/widgets/logo_builder.dart';
import 'package:linkvault/widgets/registerForm.dart';
import 'package:linkvault/widgets/responsive_container.dart';
import 'package:animate_do/animate_do.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final PageController _pageController = PageController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  File? _avatarFile;
  bool _isLogin = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final notifier = ref.read(authNotifierProvider.notifier);
    try {
      await notifier.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      _showErrorSnackBar('Login failed: $e');
    }
  }

  Future<void> _register() async {
    final notifier = ref.read(authNotifierProvider.notifier);
    try {
      await notifier.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        avatarPath: _avatarFile?.path,
      );
    } catch (e) {
      _showErrorSnackBar('Registration failed: $e');
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
                _buildBackgroundElements(theme),
                _buildMainContent(authState, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundElements(ThemeData theme) {
    return Stack(
      children: [
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
      ],
    );
  }

  Widget _buildMainContent(AuthState authState, ThemeData theme) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildLogo(theme),
            const SizedBox(height: 40),
            _buildAuthCard(authState, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: LogoBuilder(theme: ThemeData()), // Pass actual theme if needed
    );
  }

  Widget _buildAuthCard(AuthState authState, ThemeData theme) {
    return FadeInUp(
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
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.only(top: 20, bottom: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  AuthHeader(
                    tabController: _tabController,
                    isLogin: _isLogin,
                    onTabChanged: (index) {
                      _pageController.jumpToPage(index);
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildFormPageView(authState, theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormPageView(AuthState authState, ThemeData theme) {
    return SizedBox(
      height: _isLogin ? 450 : 600,
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          LoginForm(
            authState: authState,
            onLogin: _login,
            emailController: _emailController,
            passwordController: _passwordController,
            isLoading: authState.isLoading,
            theme: theme,
          ),
          RegisterForm(
            authState: authState,
            onRegister: _register,
            onError: _showErrorSnackBar,
            nameController: _nameController,
            emailController: _emailController,
            passwordController: _passwordController,
            confirmPasswordController: _confirmPasswordController,
            avatarFile: _avatarFile,
            onAvatarSelected: (file) => setState(() => _avatarFile = file),
          ),
        ],
      ),
    );
  }
}
