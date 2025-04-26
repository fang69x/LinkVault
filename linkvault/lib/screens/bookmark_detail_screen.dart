import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkvault/models/bookmark_model.dart';
import 'package:linkvault/providers/bookmark_provider.dart';
import 'package:linkvault/utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class BookmarkDetailScreen extends ConsumerStatefulWidget {
  final String bookmarkId;

  const BookmarkDetailScreen({Key? key, required this.bookmarkId})
      : super(key: key);

  @override
  _BookmarkDetailScreenState createState() => _BookmarkDetailScreenState();
}

class _BookmarkDetailScreenState extends ConsumerState<BookmarkDetailScreen> {
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
    ref.read(bookmarkNotifierProvider.notifier).clearSelectedBookmark();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
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
        title: const Text('Delete Bookmark'),
        content: const Text('Are you sure you want to delete this bookmark?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(bookmarkNotifierProvider.notifier)
                  .deleteBookmark(id)
                  .then((_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Bookmark deleted successfully')),
                );
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${error.toString()}')),
                );
              });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark Details'),
        actions: [
          if (bookmark != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/edit-bookmark',
                  arguments: bookmark,
                );
              },
            ),
          if (bookmark != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                if (bookmark.id != null) {
                  _deleteBookmark(context, bookmark.id!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bookmark ID is null')),
                  );
                }
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : bookmark == null
                  ? const Center(child: Text('Bookmark not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bookmark.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () => _launchURL(bookmark.url),
                                    child: Text(
                                      bookmark.url,
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Chip(
                                        backgroundColor: AppTheme.primaryColor
                                            .withOpacity(0.2),
                                        label: Text(
                                          bookmark.category,
                                          style: TextStyle(
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.share),
                                        onPressed: () =>
                                            _shareBookmark(bookmark),
                                        tooltip: 'Share',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.open_in_browser),
                                        onPressed: () =>
                                            _launchURL(bookmark.url),
                                        tooltip: 'Open in browser',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (bookmark.note != null &&
                              bookmark.note!.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Text(
                              'Notes',
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 8),
                            Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  bookmark.note!,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          ],
                          if (bookmark.tags.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Text(
                              'Tags',
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: bookmark.tags.map((tag) {
                                return Chip(
                                  backgroundColor:
                                      AppTheme.accentColor.withOpacity(0.2),
                                  label: Text(
                                    tag,
                                    style: TextStyle(
                                      color: AppTheme.accentColor,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 24),
                          Text(
                            'Added on',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatDate(bookmark.createdAt as String),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (bookmark.createdAt != bookmark.updatedAt) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Last updated on',
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatDate(bookmark.updatedAt as String),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
