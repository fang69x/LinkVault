import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppTheme.primaryColor.withOpacity(0.1),
        highlightColor: AppTheme.primaryColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.link_rounded,
                        size: 20, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                bookmark.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _CategoryChip(category: bookmark.category),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _UrlPreview(url: bookmark.url),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    onPressed: onDelete,
                    color: AppTheme.errorColor,
                    padding: EdgeInsets.zero,
                    tooltip: 'Delete bookmark',
                  ),
                ],
              ),
              if (bookmark.note?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                _NoteSection(note: bookmark.note!),
              ],
              if (bookmark.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                _TagSection(tags: bookmark.tags),
              ],
              const SizedBox(height: 8),
              _DateSection(
                createdAt: bookmark.createdAt,
                updatedAt: bookmark.updatedAt,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper Sub-components

class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(category),
      backgroundColor: AppTheme.accentColor.withOpacity(0.15),
      labelStyle: TextStyle(
        color: AppTheme.accentColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _UrlPreview extends StatelessWidget {
  final String url;

  const _UrlPreview({required this.url});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.onSurface.withOpacity(1),
                  Theme.of(context).colorScheme.onSurface.withOpacity(0)
                ],
                stops: const [0.8, 1.0],
                end: Alignment.centerRight,
              ).createShader(bounds);
            },
            blendMode: BlendMode.modulate,
            child: Text(
              url.replaceAll(RegExp(r'https?://'), ''),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                    fontSize: 13,
                  ),
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoteSection extends StatelessWidget {
  final String note;

  const _NoteSection({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Text(
        note,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              height: 1.4,
            ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _TagSection extends StatelessWidget {
  final List<String> tags;

  const _TagSection({required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags
          .map(
            (tag) => Chip(
              label: Text(tag),
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              labelStyle: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          )
          .toList(),
    );
  }
}

class _DateSection extends StatelessWidget {
  final dynamic createdAt;
  final dynamic updatedAt;

  const _DateSection({this.createdAt, this.updatedAt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.6),
      fontSize: 12,
    );

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (createdAt != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle_outline_rounded,
                  size: 12, color: textStyle?.color),
              const SizedBox(width: 4),
              Text('Added ${_formatDate(createdAt)}', style: textStyle),
            ],
          ),
        if (updatedAt != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_outlined, size: 12, color: textStyle?.color),
              const SizedBox(width: 4),
              Text('Updated ${_formatDate(updatedAt)}', style: textStyle),
            ],
          ),
      ],
    );
  }

  String _formatDate(dynamic dateValue) {
    final date =
        dateValue is String ? DateTime.parse(dateValue) : dateValue as DateTime;
    return DateFormat('MMM d, y').format(date);
  }
}
