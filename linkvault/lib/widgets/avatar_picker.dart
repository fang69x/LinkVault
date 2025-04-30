import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AvatarPicker extends StatefulWidget {
  final File? avatarFile;
  final Function(File?) onAvatarPicked;

  const AvatarPicker({
    Key? key,
    required this.avatarFile,
    required this.onAvatarPicked,
  }) : super(key: key);

  @override
  _AvatarPickerState createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image != null) {
      widget.onAvatarPicked(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 50,
        backgroundImage:
            widget.avatarFile != null ? FileImage(widget.avatarFile!) : null,
        child: widget.avatarFile == null
            ? const Icon(Icons.person, size: 50)
            : null,
      ),
    );
  }
}
