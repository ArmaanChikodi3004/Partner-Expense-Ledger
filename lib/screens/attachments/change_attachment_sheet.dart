import 'package:flutter/material.dart';

class ChangeAttachmentSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onDocument;

  const ChangeAttachmentSheet({
    super.key,
    required this.onCamera,
    required this.onGallery,
    required this.onDocument,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tile(Icons.camera_alt, 'Take Photo', onCamera),
          _tile(Icons.photo_library, 'Choose from Gallery', onGallery),
          _tile(Icons.description, 'Choose Document', onDocument),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
