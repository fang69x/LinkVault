import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linkvault/models/bookmark_model.dart';
import 'package:linkvault/providers/bookmark_provider.dart';
import 'package:linkvault/routes/app_routes.dart';
import 'package:linkvault/utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';

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
          SnackBar(content: Text('Could not launch $url')),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Bookmarks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go(AppRoutes.createBookmark),
          )
        ],
      ),
      body: Column(
        children: [
          _buildSearchInput(context, hasSearched),
          Expanded(
            child: isSearching && searchResults.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(child: Text('Error: $error'))
                    : !hasSearched
                        ? Center(
                            child: Text(
                              'Search for bookmarks',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          )
                        : searchResults.isEmpty
                            ? Center(
                                child: Text(
                                  'No bookmarks found',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              )
                            : NotificationListener<ScrollNotification>(
                                onNotification: (scrollInfo) {
                                  if (!isSearching &&
                                      scrollInfo.metrics.pixels ==
                                          scrollInfo.metrics.maxScrollExtent) {
                                    _loadMore();
                                  }
                                  return true;
                                },
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
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
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }

                                    final bookmark = searchResults[index];
                                    return BookmarkCard(
                                      bookmark: bookmark,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/bookmark-details',
                                          arguments: bookmark.id,
                                        );
                                      },
                                      onCategoryTap: _applyCategory,
                                      onLaunchUrl: _launchURL,
                                    );
                                  },
                                ),
                              ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput(BuildContext context, bool hasSearched) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search bookmarks',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
          const SizedBox(height: 16),
          if (_selectedCategory != null)
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: Text('Category: $_selectedCategory'),
                  selected: true,
                  onSelected: (_) => _clearCategory(),
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  showCheckmark: false,
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: _clearCategory,
                ),
              ],
            ),
          if (_recentSearches.isNotEmpty && !hasSearched)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: _recentSearches.map((search) {
                    return ActionChip(
                      label: Text(search),
                      onPressed: () {
                        _searchController.text = search;
                        _performSearch();
                      },
                      avatar: const Icon(Icons.history, size: 18),
                    );
                  }).toList(),
                ),
              ],
            ),
        ],
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
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bookmark.title,
                style: Theme.of(context).textTheme.displaySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => onLaunchUrl(bookmark.url),
                child: Text(
                  bookmark.url,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => onCategoryTap(bookmark.category),
                    child: Chip(
                      label: Text(bookmark.category),
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  Text(
                    _formatDate(bookmark.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              if (bookmark.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    ...bookmark.tags.take(3).map((tag) => Chip(
                          label:
                              Text(tag, style: const TextStyle(fontSize: 11)),
                          backgroundColor:
                              AppTheme.accentColor.withOpacity(0.2),
                          labelStyle: TextStyle(color: AppTheme.accentColor),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        )),
                    if (bookmark.tags.length > 3)
                      Chip(
                        label: Text('+${bookmark.tags.length - 3}',
                            style: const TextStyle(fontSize: 11)),
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        labelStyle: const TextStyle(color: Colors.grey),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
              ],
            ],
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
