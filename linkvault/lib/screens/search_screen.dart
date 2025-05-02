import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linkvault/models/bookmark_model.dart';
import 'package:linkvault/providers/bookmark_provider.dart';
import 'package:linkvault/routes/app_routes.dart';
import 'package:linkvault/utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:unicons/unicons.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  final List<String> _recentSearches = [];
  final int _maxRecentSearches = 5;
  bool _isSearchFocused = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch({bool reset = true}) {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      if (!_recentSearches.contains(query)) {
        setState(() {
          _recentSearches.insert(0, query);
          if (_recentSearches.length > _maxRecentSearches) {
            _recentSearches.removeLast();
          }
        });
      }
    }

    ref.read(bookmarkNotifierProvider.notifier).searchBookmarks(
          query: query.isEmpty ? null : query,
          category: _selectedCategory,
          reset: reset,
        );
  }

  void _loadMore() {
    final state = ref.read(bookmarkNotifierProvider);
    if (!state.isSearching &&
        state.currentSearchPage < state.totalSearchPages) {
      ref.read(bookmarkNotifierProvider.notifier).searchBookmarks(
            query: state.searchQuery,
            category: state.searchCategory,
            page: state.currentSearchPage + 1,
            reset: false,
          );
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
    });
  }

  void _applyCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _performSearch();
  }

  void _clearCategory() {
    setState(() {
      _selectedCategory = null;
    });
    _performSearch();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $url'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(12),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookmarkNotifierProvider);
    final searchResults = state.searchResults;
    final isSearching = state.isSearching;
    final error = state.error;
    final hasSearched =
        state.searchQuery != null || state.searchCategory != null;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => context.go(AppRoutes.home),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          ),
        ),
        actions: [
          FadeInRight(
            duration: 500.ms,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.go(AppRoutes.createBookmark),
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: AppTheme.primaryColor),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.accentColor.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background circles
              Positioned(
                top: -size.height * 0.1,
                right: -size.width * 0.2,
                child: Container(
                  width: size.width * 0.5,
                  height: size.width * 0.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -size.height * 0.1,
                left: -size.width * 0.2,
                child: Container(
                  width: size.width * 0.6,
                  height: size.width * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentColor.withOpacity(0.1),
                  ),
                ),
              ),

              // Content
              Column(
                children: [
                  // Title with animation
                  FadeInDown(
                    duration: 600.ms,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Row(
                        children: [
                          Lottie.network(
                            'https://assets2.lottiefiles.com/packages/lf20_kk62um5v.json',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Search Bookmarks',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                ),
                                Text(
                                  'Find your saved links',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Search Input
                  FadeInUp(
                    duration: 700.ms,
                    delay: 200.ms,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isSearchFocused
                                    ? AppTheme.primaryColor.withOpacity(0.5)
                                    : Colors.white.withOpacity(0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Focus(
                              onFocusChange: (hasFocus) {
                                setState(() {
                                  _isSearchFocused = hasFocus;
                                });
                              },
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(
                                    color: AppTheme.primaryColor),
                                decoration: InputDecoration(
                                  hintText: 'Search bookmarks...',
                                  prefixIcon: const Icon(UniconsLine.search,
                                      color: AppTheme.primaryColor),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear,
                                              color: Colors.grey),
                                          onPressed: _clearSearch,
                                        )
                                      : const Icon(UniconsLine.enter,
                                          color: AppTheme.primaryColor),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                ),
                                onSubmitted: (_) => _performSearch(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Filters & Recent searches
                  FadeInUp(
                    duration: 800.ms,
                    delay: 300.ms,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_selectedCategory != null)
                            Wrap(
                              spacing: 8,
                              children: [
                                Chip(
                                  label: Text(_selectedCategory!),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: _clearCategory,
                                  backgroundColor:
                                      AppTheme.primaryColor.withOpacity(0.2),
                                  labelStyle: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.primaryColor),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ],
                            ),
                          if (_recentSearches.isNotEmpty && !hasSearched) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Recent Searches',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _recentSearches.map((search) {
                                return ActionChip(
                                  label: Text(search),
                                  avatar: const Icon(Icons.history, size: 18),
                                  backgroundColor:
                                      Colors.white.withOpacity(0.7),
                                  onPressed: () {
                                    _searchController.text = search;
                                    _performSearch();
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                );
                              }).toList(),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Results
                  Expanded(
                    child: isSearching && searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.primaryColor),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Searching...',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          )
                        : error != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline,
                                        size: 64, color: Colors.red.shade300),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Error: $error',
                                      style:
                                          TextStyle(color: Colors.red.shade700),
                                    ),
                                    TextButton(
                                      onPressed: _performSearch,
                                      child: const Text('Try Again'),
                                    ),
                                  ],
                                ),
                              )
                            : !hasSearched
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Search for your bookmarks',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: Colors.grey.shade700,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Enter keywords, URL or title',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.grey.shade500,
                                              ),
                                        ),
                                      ],
                                    ),
                                  )
                                : searchResults.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'No bookmarks found',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey.shade700,
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Try a different search term',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Colors.grey.shade500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : NotificationListener<ScrollNotification>(
                                        onNotification: (scrollInfo) {
                                          if (!isSearching &&
                                              scrollInfo.metrics.pixels ==
                                                  scrollInfo.metrics
                                                      .maxScrollExtent) {
                                            _loadMore();
                                          }
                                          return true;
                                        },
                                        child: ListView.builder(
                                          padding: const EdgeInsets.fromLTRB(
                                              24, 0, 24, 24),
                                          itemCount: searchResults.length +
                                              (state.currentSearchPage <
                                                      state.totalSearchPages
                                                  ? 1
                                                  : 0),
                                          itemBuilder: (context, index) {
                                            if (index == searchResults.length) {
                                              return const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(16.0),
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              );
                                            }

                                            final bookmark =
                                                searchResults[index];
                                            return FadeInUp(
                                              duration: 400.ms,
                                              delay: Duration(
                                                  milliseconds:
                                                      100 * (index % 5)),
                                              child: BookmarkCard(
                                                bookmark: bookmark,
                                                onTap: () {
                                                  context.go(
                                                    AppRoutes.bookmarkDetails
                                                        .replaceAll(':id',
                                                            bookmark.id!),
                                                  );
                                                },
                                                onCategoryTap: _applyCategory,
                                                onLaunchUrl: _launchURL,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookmarkCard extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback onTap;
  final Function(String) onCategoryTap;
  final Function(String) onLaunchUrl;

  const BookmarkCard({
    Key? key,
    required this.bookmark,
    required this.onTap,
    required this.onCategoryTap,
    required this.onLaunchUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.8),
                  Colors.white.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              UniconsLine.link,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bookmark.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => onLaunchUrl(bookmark.url),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        UniconsLine.external_link_alt,
                                        size: 14,
                                        color: AppTheme.primaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          bookmark.url,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.primaryColor,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (bookmark.note != null &&
                          bookmark.note!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                UniconsLine.notes,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  bookmark.note!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => onCategoryTap(bookmark.category),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    UniconsLine.folder,
                                    size: 14,
                                    color: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    bookmark.category,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(bookmark.createdAt),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                          ),
                        ],
                      ),
                      if (bookmark.tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ...bookmark.tags.take(3).map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentColor
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          UniconsLine.tag_alt,
                                          size: 12,
                                          color: AppTheme.accentColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          tag,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.accentColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            if (bookmark.tags.length > 3)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '+${bookmark.tags.length - 3}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                          ],
                        )
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No date';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
