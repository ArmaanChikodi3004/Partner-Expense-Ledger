// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import '../../constants/active_partner.dart';
// import 'attachment_viewer_screen.dart';

// class AttachmentsScreen extends StatelessWidget {
//   const AttachmentsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final uid = FirebaseAuth.instance.currentUser!.uid;

//     return Scaffold(
//       backgroundColor: const Color(0xFF0B0E1A), // ✅ DARK BACKGROUND
//       appBar: AppBar(
//         title: const Text('My Attachments'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('attachments')
//             .where('partnerId', isEqualTo: activePartnerId)
//             .where('userId', isEqualTo: uid)
//             .orderBy('createdAt', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           // 1️⃣ LOADING STATE
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }

//           // 2️⃣ ERROR STATE
//           if (snapshot.hasError) {
//             return const Center(
//               child: Text(
//                 'Failed to load attachments',
//                 style: TextStyle(color: Colors.white),
//               ),
//             );
//           }

//           // 3️⃣ EMPTY STATE (THIS FIXES THE BUFFER ISSUE)
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return _emptyState();
//           }

//           // 4️⃣ DATA STATE
//           final docs = snapshot.data!.docs;

//           return ListView.separated(
//             padding: const EdgeInsets.all(16),
//             itemCount: docs.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 12),
//             itemBuilder: (context, i) {
//               final data = docs[i].data() as Map<String, dynamic>;

//               return _attachmentTile(
//                 context,
//                 fileName: data['fileName'],
//                 fileType: data['fileType'],
//                 fileUrl: data['fileUrl'],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   // ───────────────── EMPTY STATE ─────────────────

//   static Widget _emptyState() {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: const [
//           Icon(
//             Icons.folder_open,
//             size: 64,
//             color: Colors.white38,
//           ),
//           SizedBox(height: 16),
//           Text(
//             'No attachments yet',
//             style: TextStyle(
//               color: Colors.white70,
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           SizedBox(height: 6),
//           Text(
//             'Receipts uploaded from expenses will appear here',
//             style: TextStyle(
//               color: Colors.white38,
//               fontSize: 13,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   // ───────────────── ATTACHMENT TILE ─────────────────

//   static Widget _attachmentTile(
//     BuildContext context, {
//     required String fileName,
//     required String fileType,
//     required String fileUrl,
//   }) {
//     return Material(
//       color: const Color(0xFF111827),
//       borderRadius: BorderRadius.circular(14),
//       child: ListTile(
//         leading: Icon(
//           fileType == 'pdf'
//               ? Icons.picture_as_pdf_rounded
//               : Icons.image_rounded,
//           color: fileType == 'pdf'
//               ? Colors.redAccent
//               : Colors.blueAccent,
//           size: 28,
//         ),
//         title: Text(
//           fileName,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         trailing: const Icon(
//           Icons.chevron_right,
//           color: Colors.white38,
//         ),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => AttachmentViewerScreen(
//                 url: fileUrl,
//                 type: fileType,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
