import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkvault/models/bookmark_model.dart';
import 'package:linkvault/providers/auth_provider.dart';
import 'package:linkvault/providers/bookmark_provider.dart';
import 'package:linkvault/services/api_services.dart';
import 'package:linkvault/services/auth_services.dart';
import 'package:linkvault/utils/theme.dart';

class CreateBookmarkScreen extends ConsumerStatefulWidget {
  final Bookmark? bookmark;

  const CreateBookmarkScreen({Key? key, this.bookmark}) : super(key: key);

  @override
  _CreateBookmarkScreenState createState() => _CreateBookmarkScreenState();
}

class _CreateBookmarkScreenState extends ConsumerState<CreateBookmarkScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final List<String> _tags = [];

  bool _isUrlValid = true;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.bookmark != null;
    if (_isEditMode) {
      _titleController.text = widget.bookmark!.title;
      _urlController.text = widget.bookmark!.url;
      if (widget.bookmark!.note != null) {
        _noteController.text = widget.bookmark!.note!;
      }
      _categoryController.text = widget.bookmark!.category;
      _tags.addAll(widget.bookmark!.tags);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _noteController.dispose();
    _categoryController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  bool _validateUrl(String url) {
    if (url.isEmpty) return false;

    // Add http:// prefix if missing
    String validateUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      validateUrl = 'https://$url';
    }

    try {
      final uri = Uri.parse(validateUrl);
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  void _validateUrlField() {
    setState(() {
      _isUrlValid = _validateUrl(_urlController.text);
    });
  }

  Future<void> _saveBookmark() async {
    if (!_formKey.currentState!.validate()) return;

    // Ensure URL has http:// or https:// prefix
    String url = _urlController.text;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final authService = ref.read(authServiceProvider);
    final user = await authService.getCurrentUser();
    final bookmark = Bookmark(
      id: _isEditMode ? widget.bookmark!.id : null,
      title: _titleController.text,
      url: url,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      category: _categoryController.text,
      tags: _tags,
      userId: user.id, // assuming user has an 'id' field
      createdAt: _isEditMode ? widget.bookmark!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (_isEditMode) {
        await ref.read(bookmarkNotifierProvider.notifier).updateBookmark(
              widget.bookmark!.id ?? '',
              bookmark,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bookmark updated successfully')),
          );
          Navigator.pop(context);
        }
      } else {
        await ref
            .read(bookmarkNotifierProvider.notifier)
            .createBookmark(bookmark);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bookmark created successfully')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookmarkNotifierProvider);
    final isSubmitting = state.isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Bookmark' : 'Create Bookmark'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter bookmark title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'URL',
                hintText: 'Enter website URL',
                prefixIcon: const Icon(Icons.link),
                errorText: _isUrlValid ? null : 'Please enter a valid URL',
              ),
              onChanged: (_) => _validateUrlField(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a URL';
                }
                if (!_validateUrl(value)) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'Enter a category',
                prefixIcon: Icon(Icons.category),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      labelText: 'Tags',
                      hintText: 'Add tags',
                      prefixIcon: Icon(Icons.tag),
                    ),
                    onFieldSubmitted: (_) => _addTag(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTag,
                  tooltip: 'Add Tag',
                ),
              ],
            ),
            if (_tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      onDeleted: () => _removeTag(tag),
                      backgroundColor: AppTheme.accentColor.withOpacity(0.2),
                      labelStyle: TextStyle(color: AppTheme.textPrimaryColor),
                      deleteIconColor: AppTheme.primaryColor,
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add notes about this bookmark',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isSubmitting ? null : _saveBookmark,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isEditMode ? 'Update Bookmark' : 'Save Bookmark'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
