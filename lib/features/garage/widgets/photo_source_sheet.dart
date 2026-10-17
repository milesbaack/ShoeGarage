import 'package:flutter/material.dart';

enum PhotoAction { camera, gallery, remove }

Future<PhotoAction?> showPhotoActionSheet(BuildContext context, {bool canRemove = false}) {
  return showModalBottomSheet<PhotoAction>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Shoe Photo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take Photo'),
            onTap: () => Navigator.of(ctx).pop(PhotoAction.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from Library'),
            onTap: () => Navigator.of(ctx).pop(PhotoAction.gallery),
          ),
          if (canRemove) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.of(ctx).pop(PhotoAction.remove),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
