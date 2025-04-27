import 'package:flutter/material.dart';
import 'package:linkvault/models/bookmark_model.dart';
import 'package:linkvault/utils/theme.dart';

class BookmarkCard extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const BookmarkCard({
    super.key,
    required this.bookmark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: theme.cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row with icon, title, category chip and delete button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.link,
                        size: 24, color: AppTheme.primaryColor),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + Category Chip
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                bookmark.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(bookmark.category),
                              backgroundColor:
                                  AppTheme.accentColor.withOpacity(0.1),
                              labelStyle: const TextStyle(
                                color: AppTheme.accentColor,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bookmark.url.replaceAll(RegExp(r'https?://'), ''),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    color: AppTheme.errorColor,
                  ),
                ],
              ),

              // Optional note
              if (bookmark.note?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  bookmark.note!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Tags section
              if (bookmark.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: bookmark.tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          backgroundColor:
                              AppTheme.primaryColor.withOpacity(0.1),
                          labelStyle: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ],

              // Created & Updated Dates
              const SizedBox(height: 8),
              Row(
                children: [
                  if (bookmark.createdAt != null)
                    Text(
                      'Added: ${_formatDate(bookmark.createdAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  if (bookmark.updatedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        'Updated: ${_formatDate(bookmark.updatedAt!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
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

  String _formatDate(dynamic dateValue) {
    final date =
        dateValue is String ? DateTime.parse(dateValue) : dateValue as DateTime;
    final now = DateTime.now();
    final difference = now.difference(date);
    return '${date.day}/${date.month}/${date.year}';
  }
}
