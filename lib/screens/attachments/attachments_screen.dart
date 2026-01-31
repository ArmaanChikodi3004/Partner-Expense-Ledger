import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttachmentsScreen extends StatelessWidget {
  const AttachmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('attachments')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'No attachments yet',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return ListTile(
              leading: Icon(
                data['fileType'] == 'pdf'
                    ? Icons.picture_as_pdf
                    : Icons.image,
                color: Colors.white,
              ),
              title: Text(
                data['fileName'],
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                data['uploadedByName'],
                style: const TextStyle(color: Colors.white54),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
