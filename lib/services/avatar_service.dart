import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvatarService {
  static final _auth = FirebaseAuth.instance;
  static final _storage = FirebaseStorage.instance;
  static final _firestore = FirebaseFirestore.instance;

  /// Upload avatar and save URL
  static Future<String?> uploadAvatar(File file) async {
    final uid = _auth.currentUser!.uid;

    final ref = _storage.ref().child('avatars/$uid/avatar.jpg');

    await ref.putFile(file);

    final url = await ref.getDownloadURL();

    await _firestore.collection('users').doc(uid).update({
      'avatarUrl': url,
    });

    return url;
  }

  /// Remove avatar completely
  static Future<void> removeAvatar() async {
    final uid = _auth.currentUser!.uid;

    try {
      await _storage.ref('avatars/$uid/avatar.jpg').delete();
    } catch (_) {}

    await _firestore.collection('users').doc(uid).update({
      'avatarUrl': FieldValue.delete(),
    });
  }
}
