import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AvatarPicker extends StatelessWidget {
  final File? avatarFile;
  final Function(File) onImageSelected;
  final Function(String) onError;

  const AvatarPicker({
    super.key,
    required this.avatarFile,
    required this.onImageSelected,
    required this.onError,
  });

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        onImageSelected(File(image.path));
      }
    } catch (e) {
      onError('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                image: avatarFile != null
                    ? DecorationImage(
                        image: FileImage(avatarFile!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: avatarFile == null
                  ? Icon(
                      Icons.person,
                      size: 50,
                      color:
                          theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
