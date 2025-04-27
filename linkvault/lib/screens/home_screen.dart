import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linkvault/models/bookmark_model.dart';
import 'package:linkvault/providers/auth_provider.dart';
import 'package:linkvault/providers/bookmark_provider.dart';
import 'package:linkvault/utils/theme.dart';
import 'package:linkvault/widgets/bookmark_card.dart';
import 'package:linkvault/widgets/responsive_container.dart';
import 'package:linkvault/widgets/shimmer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final bookmarkState = ref.watch(bookmarkNotifierProvider);
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LinkVault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(bookmarkNotifierProvider.notifier)
              .getBookmarks(refresh: true);
        },
        child: ResponsiveContainer(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: user?.avatarUrl != null
                                ? NetworkImage(user!.avatarUrl!)
                                : null,
                            child: user?.avatarUrl == null
                                ? Text(user?.name.substring(0, 1) ?? 'U')
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${user?.name ?? 'User'}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                'Your Bookmarks',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              if (bookmarkState.isLoading && bookmarkState.bookmarks.isEmpty)
                const SliverFillRemaining(
                  child: BookmarkShimmer(), // Show shimmer
                )
              else if (bookmarkState.bookmarks.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.bookmark_border,
                          size: 80,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No bookmarks yet',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first bookmark by tapping the + button',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == bookmarkState.bookmarks.length) {
                        // Show loading indicator at the bottom while loading more
                        return bookmarkState.isLoading && bookmarkState.hasMore
                            ? Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(),
                              )
                            : const SizedBox.shrink();
                      }

                      final bookmark = bookmarkState.bookmarks[index];
                      return BookmarkCard(
                        bookmark: bookmark,
                        onTap: () => context.push('/bookmark/${bookmark.id}'),
                        onDelete: () async {
                          await ref
                              .read(bookmarkNotifierProvider.notifier)
                              .deleteBookmark(bookmark.id!);
                        },
                      );
                    },
                    childCount: bookmarkState.bookmarks.length +
                        1, // +1 for the loading indicator
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/bookmark/create'),
        child: const Icon(Icons.add),
        tooltip: 'Add Bookmark',
      ),
    );
  }
}
