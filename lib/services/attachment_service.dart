import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../constants/active_partner.dart';

class AttachmentService {
  static final _storage = FirebaseStorage.instance;
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<String> uploadAttachment({
    required File file,
    required String fileName,
  }) async {
    final uid = _auth.currentUser!.uid;
    final userName = await UserService.getUserName(uid);

    final ext = fileName.split('.').last.toLowerCase();
    final fileType = ext == 'pdf'
        ? 'pdf'
        : ['jpg', 'jpeg', 'png', 'webp'].contains(ext)
            ? 'image'
            : 'file';

    final storagePath =
        'attachments/$activePartnerId/$uid/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    final ref = _storage.ref(storagePath);
    final snap = await ref.putFile(file);
    final url = await ref.getDownloadURL();

    final doc = await _firestore.collection('attachments').add({
      'fileName': fileName,
      'fileUrl': url,
      'fileType': fileType,
      'fileSize': snap.totalBytes,
      'storagePath': storagePath,
      'uploadedByUid': uid,
      'uploadedByName': userName,
      'partnerId': activePartnerId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  static Future<void> deleteAttachment({
    required String docId,
    required String storagePath,
  }) async {
    await _storage.ref(storagePath).delete();
    await _firestore.collection('attachments').doc(docId).delete();
  }
}
