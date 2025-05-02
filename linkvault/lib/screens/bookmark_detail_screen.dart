import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkvault/models/bookmark_model.dart';
import 'package:linkvault/providers/bookmark_provider.dart';
import 'package:linkvault/utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class BookmarkDetailScreen extends ConsumerStatefulWidget {
  final String bookmarkId;

  const BookmarkDetailScreen({Key? key, required this.bookmarkId})
      : super(key: key);

  @override
  _BookmarkDetailScreenState createState() => _BookmarkDetailScreenState();
}

class _BookmarkDetailScreenState extends ConsumerState<BookmarkDetailScreen> {
  bool _isHoveringUrl = false;
  bool _isMobile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(bookmarkNotifierProvider.notifier)
          .getBookmarkDetails(widget.bookmarkId);
    });
  }

  @override
  void dispose() {
    super.dispose();
    ref.read(bookmarkNotifierProvider.notifier).clearSelectedBookmark();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $url'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _shareBookmark(Bookmark bookmark) {
    Share.share(
      '${bookmark.title}\n${bookmark.url}',
      subject: 'Check out this bookmark!',
    );
  }

  void _deleteBookmark(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Bookmark',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text('Are you sure you want to delete this bookmark?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(bookmarkNotifierProvider.notifier)
                  .deleteBookmark(id)
                  .then((_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Bookmark deleted successfully'),
                    backgroundColor: Colors.green.shade800,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${error.toString()}'),
                    backgroundColor: Colors.red.shade800,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookmarkNotifierProvider);
    final bookmark = state.selectedBookmark;
    final isLoading = state.isLoading;
    final error = state.error;

    // Check screen size
    final screenWidth = MediaQuery.of(context).size.width;
    _isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark Details'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        centerTitle: true,
        actions: [
          if (bookmark != null) ...[
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share',
              onPressed: () => _shareBookmark(bookmark),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Bookmark',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/edit-bookmark',
                  arguments: bookmark,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete Bookmark',
              onPressed: () {
                if (bookmark.id != null) {
                  _deleteBookmark(context, bookmark.id!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Bookmark ID is null'),
                      backgroundColor: Colors.red.shade800,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ],
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade800,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $error',
                        style: TextStyle(color: Colors.red.shade800),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(bookmarkNotifierProvider.notifier)
                              .getBookmarkDetails(widget.bookmarkId);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : bookmark == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            color: Colors.grey.shade400,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Bookmark not found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildBookmarkContent(context, bookmark),
    );
  }

  Widget _buildBookmarkContent(BuildContext context, Bookmark bookmark) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner with Hero Animation
              Hero(
                tag: 'bookmark-${bookmark.id}',
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.8),
                        AppTheme.accentColor.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Center(
                          child: Icon(
                            Icons.bookmark,
                            size: 64,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bookmark.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(bookmark.createdAt),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Main Content Card
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        bookmark.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),

                      const SizedBox(height: 16),

                      // URL
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.link,
                            size: 20,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: MouseRegion(
                              onEnter: (_) =>
                                  setState(() => _isHoveringUrl = true),
                              onExit: (_) =>
                                  setState(() => _isHoveringUrl = false),
                              child: InkWell(
                                onTap: () => _launchURL(bookmark.url),
                                child: Text(
                                  bookmark.url,
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    decoration: _isHoveringUrl
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.open_in_browser),
                            tooltip: 'Open in browser',
                            onPressed: () => _launchURL(bookmark.url),
                            style: IconButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              backgroundColor:
                                  AppTheme.primaryColor.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Category and Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            avatar: const Icon(
                              Icons.category,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                            label: Text(bookmark.category),
                            backgroundColor:
                                AppTheme.primaryColor.withOpacity(0.1),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            labelStyle: const TextStyle(
                              color: AppTheme.primaryColor,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                          ),
                          ...bookmark.tags.map((tag) {
                            return Chip(
                              avatar: const Icon(
                                Icons.tag,
                                size: 16,
                                color: AppTheme.accentColor,
                              ),
                              label: Text(tag),
                              backgroundColor:
                                  AppTheme.accentColor.withOpacity(0.1),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelStyle: const TextStyle(
                                color: AppTheme.accentColor,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                            );
                          }).toList(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Notes Section
              if (bookmark.note != null && bookmark.note!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.notes,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Notes',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            bookmark.note!,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      height: 1.5,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Timeline Information
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Timeline',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Created At
                      Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 20,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Created:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDateDetailed(bookmark.createdAt),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),

                      if (bookmark.createdAt != bookmark.updatedAt) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.update,
                              size: 20,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Updated:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDateDetailed(bookmark.updatedAt),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Action Buttons for Mobile
              if (_isMobile) ...[
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchURL(bookmark.url),
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text('Open URL'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _shareBookmark(bookmark),
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: AppTheme.accentColor),
                          foregroundColor: AppTheme.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'No date';
    final date =
        dateValue is String ? DateTime.parse(dateValue) : dateValue as DateTime;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _formatDateDetailed(dynamic dateValue) {
    if (dateValue == null) return 'No date';
    final date =
        dateValue is String ? DateTime.parse(dateValue) : dateValue as DateTime;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} at $hour:$minute';
  }
}
