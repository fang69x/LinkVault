import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linkvault/models/bookmark_model.dart';
import 'package:linkvault/providers/auth_provider.dart';
import 'package:linkvault/providers/bookmark_provider.dart';
import 'package:linkvault/routes/app_routes.dart';
import 'package:linkvault/utils/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:unicons/unicons.dart';

class CreateBookmarkScreen extends ConsumerStatefulWidget {
  final Bookmark? bookmark;

  const CreateBookmarkScreen({Key? key, this.bookmark}) : super(key: key);

  @override
  ConsumerState<CreateBookmarkScreen> createState() =>
      _CreateBookmarkScreenState();
}

class _CreateBookmarkScreenState extends ConsumerState<CreateBookmarkScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final List<String> _tags = [];
  bool _isEditMode = false;
  bool _isLoading = false;
  bool _showTagInput = false;
  bool _isUrlValid = true;

  final categories = [
    'Work',
    'Personal',
    'Education',
    'Entertainment',
    'Technology',
    'Health',
    'Finance',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.bookmark != null;
    if (_isEditMode) {
      _urlController.text = widget.bookmark!.url;
      _titleController.text = widget.bookmark!.title;
      _categoryController.text = widget.bookmark!.category;
      _noteController.text = widget.bookmark!.note ?? '';
      _tags.addAll(widget.bookmark!.tags);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final bookmark = Bookmark(
        id: _isEditMode ? widget.bookmark!.id : null,
        url: _urlController.text,
        title: _titleController.text,
        category: _categoryController.text,
        note: _noteController.text,
        tags: _tags,
        createdAt: _isEditMode ? widget.bookmark!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
        userId: user.id,
      );

      final notifier = ref.read(bookmarkNotifierProvider.notifier);
      if (_isEditMode) {
        await notifier.updateBookmark(bookmark.id!, bookmark);
      } else {
        await notifier.createBookmark(bookmark);
        await notifier.getBookmarks(refresh: true);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(_isEditMode ? 'Bookmark updated!' : 'Bookmark saved!'),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(12),
            duration: const Duration(seconds: 2),
          ),
        );
        context.go(AppRoutes.home);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(12),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
        _showTagInput = false;
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _validateUrl(String url) {
    final RegExp urlRegex = RegExp(
      r'^(http|https)://[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,}(:[0-9]{1,5})?(\/.*)?$',
      caseSensitive: false,
      multiLine: false,
    );
    setState(() {
      _isUrlValid = url.isEmpty || urlRegex.hasMatch(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          if (_isEditMode)
            FadeInRight(
              duration: 500.ms,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  // Show delete confirmation dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      title: const Text('Delete Bookmark?'),
                      content: const Text('This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            if (widget.bookmark?.id != null) {
                              await ref
                                  .read(bookmarkNotifierProvider.notifier)
                                  .deleteBookmark(widget.bookmark!.id!);
                              if (mounted) context.go(AppRoutes.home);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
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
                  child: const Icon(Icons.delete_outline, color: Colors.red),
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
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with animation
                    FadeInDown(
                      duration: 600.ms,
                      child: Row(
                        children: [
                          Lottie.network(
                            'https://assets9.lottiefiles.com/packages/lf20_szlepvdh.json',
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
                                  _isEditMode
                                      ? 'Edit Bookmark'
                                      : 'New Bookmark',
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                Text(
                                  _isEditMode
                                      ? 'Update your saved link'
                                      : 'Save a link to access later',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Form container
                    FadeInUp(
                      duration: 800.ms,
                      delay: 300.ms,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.8),
                                  Colors.white.withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // URL Field with validation
                                  TextFormField(
                                    controller: _urlController,
                                    style: const TextStyle(
                                        color: AppTheme.primaryColor),
                                    onChanged: _validateUrl,
                                    decoration: InputDecoration(
                                      labelText: 'URL',
                                      hintText: 'https://example.com',
                                      prefixIcon: const Icon(UniconsLine.link,
                                          color: AppTheme.primaryColor),
                                      suffixIcon: _isUrlValid
                                          ? const Icon(Icons.check_circle,
                                              color: Colors.green)
                                          : const Icon(Icons.error,
                                              color: Colors.red),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'URL is required';
                                      }
                                      if (!_isUrlValid) {
                                        return 'Please enter a valid URL';
                                      }
                                      return null;
                                    },
                                  )
                                      .animate()
                                      .fadeIn(delay: 100.ms)
                                      .slideX(begin: -0.1, end: 0),

                                  const SizedBox(height: 20),

                                  // Title Field
                                  TextFormField(
                                    controller: _titleController,
                                    style: const TextStyle(
                                        color: AppTheme.primaryColor),
                                    decoration: InputDecoration(
                                      labelText: 'Title',
                                      hintText: 'Give your bookmark a name',
                                      prefixIcon: const Icon(UniconsLine.book,
                                          color: AppTheme.primaryColor),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                    ),
                                    validator: (val) =>
                                        val == null || val.isEmpty
                                            ? 'Title is required'
                                            : null,
                                  )
                                      .animate()
                                      .fadeIn(delay: 200.ms)
                                      .slideX(begin: 0.1, end: 0),

                                  const SizedBox(height: 20),

                                  // Category Dropdown
                                  DropdownButtonFormField<String>(
                                    value: _categoryController.text.isNotEmpty
                                        ? _categoryController.text
                                        : null,
                                    decoration: InputDecoration(
                                      labelText: 'Category',
                                      hintText: 'Select a category',
                                      prefixIcon: const Icon(UniconsLine.folder,
                                          color: AppTheme.primaryColor),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                    ),
                                    items: categories.map((String category) {
                                      return DropdownMenuItem<String>(
                                        value: category,
                                        child: Text(category),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _categoryController.text =
                                            newValue ?? '';
                                      });
                                    },
                                  )
                                      .animate()
                                      .fadeIn(delay: 300.ms)
                                      .slideX(begin: -0.1, end: 0),

                                  const SizedBox(height: 20),

                                  // Tags Section
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tags',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          ..._tags.map((tag) => Chip(
                                                label: Text(tag,
                                                    style: const TextStyle(
                                                        fontSize: 12)),
                                                deleteIcon: const Icon(
                                                    Icons.close,
                                                    size: 14),
                                                onDeleted: () =>
                                                    _removeTag(tag),
                                                backgroundColor: AppTheme
                                                    .accentColor
                                                    .withOpacity(0.2),
                                                deleteIconColor:
                                                    Colors.red.shade400,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                visualDensity:
                                                    VisualDensity.compact,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 0),
                                              )),
                                          if (_showTagInput)
                                            Container(
                                              width: size.width * 0.6,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: TextField(
                                                      controller:
                                                          _tagController,
                                                      decoration:
                                                          const InputDecoration(
                                                        hintText: 'Add tag...',
                                                        border:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        16),
                                                      ),
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                      onSubmitted: (_) =>
                                                          _addTag(),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.check,
                                                        size: 18),
                                                    onPressed: _addTag,
                                                    color:
                                                        AppTheme.primaryColor,
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.close,
                                                        size: 18),
                                                    onPressed: () => setState(
                                                        () => _showTagInput =
                                                            false),
                                                    color: Colors.red.shade400,
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(),
                                                  ),
                                                ],
                                              ),
                                            )
                                          else
                                            InkWell(
                                              onTap: () => setState(
                                                  () => _showTagInput = true),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                      color:
                                                          Colors.grey.shade300),
                                                ),
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.add,
                                                        size: 16,
                                                        color: AppTheme
                                                            .primaryColor),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Add Tag',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: AppTheme
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ).animate().fadeIn(delay: 400.ms),

                                  const SizedBox(height: 20),

                                  // Notes Field
                                  TextFormField(
                                    controller: _noteController,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                      labelText: 'Notes',
                                      hintText:
                                          'Any additional information about this link...',
                                      alignLabelWithHint: true,
                                      prefixIcon: const Padding(
                                        padding: EdgeInsets.only(bottom: 64),
                                        child: Icon(UniconsLine.notes,
                                            color: AppTheme.primaryColor),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: const Color.fromARGB(
                                          255, 245, 245, 245),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(delay: 500.ms)
                                      .slideX(begin: 0.1, end: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => context.go(AppRoutes.home),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                    color:
                                        AppTheme.primaryColor.withOpacity(0.3)),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: AppTheme.primaryColor),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 600.ms)
                              .scale(begin: const Offset(0.9, 0.9)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _save,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 5,
                              shadowColor:
                                  AppTheme.primaryColor.withOpacity(0.5),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(_isEditMode
                                          ? Icons.update
                                          : Icons.bookmark_add),
                                      const SizedBox(width: 8),
                                      Text(_isEditMode
                                          ? 'Update Bookmark'
                                          : 'Save Bookmark'),
                                    ],
                                  ),
                          )
                              .animate()
                              .fadeIn(delay: 700.ms)
                              .scale(begin: const Offset(0.9, 0.9)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
