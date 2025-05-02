import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:linkvault/models/bookmark_model.dart';
import 'package:linkvault/providers/auth_provider.dart';
import 'package:linkvault/providers/bookmark_provider.dart';
import 'package:linkvault/routes/app_routes.dart';
import 'package:linkvault/utils/constants.dart';
import 'package:linkvault/utils/theme.dart';
import 'package:linkvault/widgets/bookmark_card.dart';
import 'package:linkvault/widgets/homeScreen_widget/wavePainter.dart';
import 'package:linkvault/widgets/shimmer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  late TabController _tabController;
  String _currentCategory = 'All';
  final _animationDuration = const Duration(milliseconds: 300);

  // Animation controllers for wave effect
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();

    // Set up tab controller for category filtering
    _tabController = TabController(
      length:
          AppConstants.defaultCategories.length + 1, // +1 for "All" category
      vsync: this,
    );

    // Set up wave animation controller
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Load bookmarks when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookmarkNotifierProvider.notifier).getBookmarks();
    });

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  // Get the count of bookmarks from the last 7 days
  String _getRecentCount(List<Bookmark> bookmarks) {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentCount = bookmarks.where((bookmark) {
      if (bookmark.createdAt == null) return false;
      return bookmark.createdAt!.isAfter(oneWeekAgo);
    }).length;
    return '$recentCount';
  }

  // Build stat item widget for the app bar
  Widget _buildStatItem(
      BuildContext context, String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Build vertical divider for stats
  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withOpacity(0.2),
    );
  }

  // Build search button with animation
  Widget _buildSearchButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.search, color: Colors.white),
        tooltip: 'Search bookmarks',
        onPressed: () => context.go(AppRoutes.search),
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, end: 0);
  }

  // Build profile and options menu
  Widget _buildProfileMenu(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;

    return PopupMenuButton(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tooltip: 'Profile and options',
      icon: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: const Icon(
          Icons.more_vert,
          color: Colors.white,
        ),
      ),
      itemBuilder: (context) => <PopupMenuEntry>[
        PopupMenuItem(
          enabled: false,
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundImage: user?.avatarUrl != null
                    ? NetworkImage(user!.avatarUrl!)
                    : null,
                child: user?.avatarUrl == null
                    ? Text(user?.name?.substring(0, 1).toUpperCase() ?? 'U')
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  user?.name ?? 'User',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.settings_outlined),
              SizedBox(width: 12),
              Text('Settings'),
            ],
          ),
          onTap: () {
            Future.delayed(
              const Duration(milliseconds: 200),
              () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              ),
            );
          },
        ),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.help_outline),
              SizedBox(width: 12),
              Text('Help & Feedback'),
            ],
          ),
          onTap: () {
            Future.delayed(
              const Duration(milliseconds: 200),
              () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Feedback coming soon!')),
              ),
            );
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
          onTap: () async {
            Future.delayed(const Duration(milliseconds: 200), () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                await ref.read(authNotifierProvider.notifier).logout();
              }
            });
          },
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.2, end: 0);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final state = ref.read(bookmarkNotifierProvider);
      if (!state.isLoading && state.hasMore) {
        ref.read(bookmarkNotifierProvider.notifier).getBookmarks(
              page: state.currentPage + 1,
            );
      }
    }
  }

  List<Bookmark> _getFilteredBookmarks(List<Bookmark> bookmarks) {
    if (_currentCategory == 'All') {
      return bookmarks;
    }
    return bookmarks
        .where((bookmark) => bookmark.category == _currentCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkState = ref.watch(bookmarkNotifierProvider);
    final user = ref.watch(authNotifierProvider).user;
    final filteredBookmarks = _getFilteredBookmarks(bookmarkState.bookmarks);

    return Scaffold(
      body: RefreshIndicator(
        color: AppTheme.accentColor,
        backgroundColor: Theme.of(context).cardColor,
        onRefresh: () async {
          await ref
              .read(bookmarkNotifierProvider.notifier)
              .getBookmarks(refresh: true);
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Enhanced Custom App Bar
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              stretch: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.zero,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient background with pattern overlay
                    ShaderMask(
                      shaderCallback: (rect) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.9),
                            AppTheme.accentColor.withOpacity(0.85),
                          ],
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.srcATop,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          // image: DecorationImage(
                          //   image: AssetImage('assets/pattern.png'),
                          //   fit: BoxFit.cover,
                          //   opacity: 0.1,
                          // ),
                        ),
                      ),
                    ),

                    // Animated wave decoration
                    Positioned(
                      bottom: -5,
                      left: 0,
                      right: 0,
                      child: SizedBox(
                        height: 40,
                        child: CustomPaint(
                          painter: WavePainter(
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          child: Container(),
                        ),
                      ),
                    ),

                    // App Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 5, 16, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // App Logo + Title Row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.bookmark_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'LinkVault',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                    ),
                              ),
                              const Spacer(),
                              _buildSearchButton(context),
                              const SizedBox(width: 8),
                              _buildProfileMenu(context, ref),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Stats Row
                          FractionallySizedBox(
                            widthFactor: 0.75,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  context,
                                  'Total',
                                  '${bookmarkState.bookmarks.length}',
                                  Icons.link_rounded,
                                ),
                                _buildVerticalDivider(),
                                _buildStatItem(
                                  context,
                                  'Categories',
                                  '${AppConstants.defaultCategories.length}',
                                  Icons.category_rounded,
                                ),
                                _buildVerticalDivider(),
                                _buildStatItem(
                                  context,
                                  'Recent',
                                  _getRecentCount(bookmarkState.bookmarks),
                                  Icons.access_time_rounded,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(),
                  ],
                ),
              ),
            ),

            // User greeting section
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Hero(
                      tag: 'user_avatar',
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.accentColor,
                        backgroundImage: user?.avatarUrl != null
                            ? NetworkImage(user!.avatarUrl!)
                            : null,
                        child: user?.avatarUrl == null
                            ? Text(
                                user?.name?.substring(0, 1).toUpperCase() ??
                                    'U',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                          ),
                          Text(
                            user?.name ?? 'User',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bookmark,
                            size: 16,
                            color: AppTheme.accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${bookmarkState.bookmarks.length} links',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Category tabs
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: AppTheme.textSecondaryColor,
                  indicatorColor: AppTheme.primaryColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
                  onTap: (index) {
                    setState(() {
                      _currentCategory = index == 0
                          ? 'All'
                          : AppConstants.defaultCategories[index - 1];
                    });
                  },
                  tabs: [
                    const Tab(text: 'All'),
                    ...AppConstants.defaultCategories.map(
                      (category) => Tab(text: category),
                    ),
                  ],
                ),
              ),
            ),

            // Section title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_currentCategory Bookmarks',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (bookmarkState.bookmarks.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          // Add sort functionality here
                          // For now just show a snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Sorting functionality coming soon!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.sort, size: 16),
                        label: const Text('Sort'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Main content
            if (bookmarkState.isLoading && bookmarkState.bookmarks.isEmpty)
              const SliverFillRemaining(
                child: BookmarkShimmer(), // Show shimmer
              )
            else if (filteredBookmarks.isEmpty)
              SliverFillRemaining(
                child: EmptyStateWidget(
                  isFiltered: _currentCategory != 'All' &&
                      bookmarkState.bookmarks.isNotEmpty,
                  category: _currentCategory,
                  onAddNew: () => context.go(AppRoutes.createBookmark),
                  onClearFilter: () {
                    setState(() {
                      _currentCategory = 'All';
                      _tabController.animateTo(0);
                    });
                  },
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == filteredBookmarks.length) {
                      // Show loading indicator at the bottom while loading more
                      return bookmarkState.isLoading && bookmarkState.hasMore
                          ? Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(
                                color: AppTheme.accentColor,
                              ),
                            )
                          : const SizedBox.shrink();
                    }

                    final bookmark = filteredBookmarks[index];
                    return Hero(
                      tag: 'bookmark_${bookmark.id}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: BookmarkCard(
                          bookmark: bookmark,
                          onTap: () => context.go(
                            AppRoutes.bookmarkDetails
                                .replaceAll(':id', bookmark.id!),
                          ),
                          onDelete: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Bookmark'),
                                content: Text(
                                  'Are you sure you want to delete "${bookmark.title}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              await ref
                                  .read(bookmarkNotifierProvider.notifier)
                                  .deleteBookmark(bookmark.id!);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Bookmark deleted'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () {
                                      // Implement undo functionality if your API supports it
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Undo functionality coming soon!'),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: (50 * index).ms)
                        .slideY(
                            begin: 0.1,
                            end: 0,
                            duration: 300.ms,
                            delay: (50 * index).ms);
                  },
                  childCount:
                      filteredBookmarks.length + 1, // +1 for loading indicator
                ),
              ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 80), // Extra padding at bottom for FAB
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.createBookmark),
        tooltip: 'Add Bookmark',
        icon: const Icon(Icons.add),
        label: const Text('Add Bookmark'),
        elevation: 4,
      ).animate().scale(
            duration: 300.ms,
            delay: 200.ms,
            curve: Curves.elasticOut,
          ),
    );
  }
}

// Delegate for persistent header
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// Empty State Widget
class EmptyStateWidget extends StatelessWidget {
  final bool isFiltered;
  final String category;
  final VoidCallback onAddNew;
  final VoidCallback onClearFilter;

  const EmptyStateWidget({
    Key? key,
    required this.isFiltered,
    required this.category,
    required this.onAddNew,
    required this.onClearFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltered ? Icons.filter_list : Icons.bookmark_border,
                size: 60,
                color: AppTheme.primaryColor,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              isFiltered
                  ? 'No bookmarks in "$category" category'
                  : 'No bookmarks yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isFiltered
                  ? 'Try selecting a different category or add a new bookmark in this category'
                  : 'Start saving your favorite links by tapping the button below',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            isFiltered
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: onClearFilter,
                        icon: const Icon(Icons.filter_list_off),
                        label: const Text('Clear Filter'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: onAddNew,
                        icon: const Icon(Icons.add),
                        label: const Text('Add New'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  )
                : ElevatedButton.icon(
                    onPressed: onAddNew,
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Bookmark'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}
