import 'package:flutter/material.dart';

class ChangeAvatarSheet extends StatelessWidget {
  const ChangeAvatarSheet({super.key});

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
          // -------- DRAG HANDLE --------
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Change Avatar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          _optionTile(
            icon: Icons.camera_alt,
            label: 'Take Photo',
            onTap: () {
              Navigator.pop(context);
            },
          ),

          _optionTile(
            icon: Icons.photo_library,
            label: 'Choose from Gallery',
            onTap: () {
              Navigator.pop(context);
            },
          ),

          _optionTile(
            icon: Icons.delete_outline,
            label: 'Remove Avatar',
            color: const Color(0xFFEF4444),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
