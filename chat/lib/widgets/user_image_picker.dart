// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickedimage});
  final void Function(File pickedimage) onPickedimage;
  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedimagefile;

  Future _pickimage(ImageSource source) async {
    final pickedimage = await ImagePicker()
        .pickImage(source: source, imageQuality: 50, maxWidth: 150);

    setState(
      () {
        if (pickedimage != null) {
          _pickedimagefile = File(pickedimage.path);
        }
      },
    );
    widget.onPickedimage(_pickedimagefile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {},
          child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              foregroundImage: _pickedimagefile != null
                  ? FileImage(_pickedimagefile!)
                  : null),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
                onPressed: () => _pickimage(ImageSource.gallery),
                icon: const Icon(Icons.image),
                label: Text(
                  'Gallery',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                )),
            const SizedBox(width: 10),
            TextButton.icon(
                onPressed: () => _pickimage(ImageSource.camera),
                icon: const Icon(Icons.camera),
                label: Text(
                  'Add Image',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                )),
          ],
        )
      ],
    );
  }
}
