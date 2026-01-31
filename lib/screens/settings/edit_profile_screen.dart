import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'change_avatar_sheet.dart';
import '../../services/avatar_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  File? _avatarFile;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ---------------- LOAD USER ----------------

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!doc.exists) return;

    final data = doc.data()!;
    nameController.text = data['name'] ?? '';
    emailController.text = data['email'] ?? '';
    _avatarUrl = data['avatarUrl'];

    setState(() {});
  }

  // ---------------- PICK + CROP IMAGE ----------------

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 90,
    );

    if (picked == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Avatar',
          toolbarColor: const Color(0xFF111827),
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Avatar',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (cropped == null) return;

    final file = File(cropped.path);

    setState(() {
      _avatarFile = file;
      _avatarUrl = null;
    });

    final url = await AvatarService.uploadAvatar(file);

    if (url != null) {
      setState(() => _avatarUrl = url);
    }
  }

  // ---------------- REMOVE AVATAR ----------------

  void _removeAvatar() async {
    Navigator.pop(context);

    setState(() {
      _avatarFile = null;
      _avatarUrl = null;
    });

    await AvatarService.removeAvatar();
  }

  void _openChangeAvatarSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeAvatarSheet(
        onCamera: () => _pickImage(ImageSource.camera),
        onGallery: () => _pickImage(ImageSource.gallery),
        onRemove: _removeAvatar,
      ),
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E1A),
        elevation: 0,
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(0xFF6366F1),
                  backgroundImage: _avatarFile != null
                      ? FileImage(_avatarFile!)
                      : (_avatarUrl != null
                          ? NetworkImage(_avatarUrl!)
                          : null) as ImageProvider?,
                  child: (_avatarFile == null && _avatarUrl == null)
                      ? const Icon(Icons.person,
                          size: 48, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _openChangeAvatarSheet,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF6366F1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _label('Name'),
            _input(controller: nameController),

            const SizedBox(height: 16),

            _label('Email'),
            _input(controller: emailController, enabled: false),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  final uid = FirebaseAuth.instance.currentUser!.uid;
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .update({
                    'name': nameController.text.trim(),
                  });
                  Navigator.pop(context);
                },
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------

  Widget _label(String text) => Align(
        alignment: Alignment.centerLeft,
        child:
            Text(text, style: const TextStyle(color: Colors.white70)),
      );

  Widget _input({
    required TextEditingController controller,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF1F2937),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
      ),
    );
  }
}
