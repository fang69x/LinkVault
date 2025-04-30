import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final TabController tabController;
  final bool isLogin;
  final Function(int) onTabChanged;

  const AuthHeader({
    super.key,
    required this.tabController,
    required this.isLogin,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(50),
      ),
      child: TabBar(
        controller: tabController,
        tabs: [
          _buildTabItem('Login', isLogin, theme),
          _buildTabItem('Register', !isLogin, theme),
        ],
        dividerColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelColor: theme.colorScheme.onPrimary,
        labelPadding: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        onTap: onTabChanged,
      ),
    );
  }

  Widget _buildTabItem(String label, bool isActive, ThemeData theme) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: isActive ? theme.colorScheme.primary : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
