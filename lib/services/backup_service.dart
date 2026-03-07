import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart'; // for sharePdf — we reuse share sheet
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class BackupService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────
  // CREATE BACKUP
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> fetchBackupData({
    required String partnerId,
  }) async {
    // Fetch transactions
    final expensesSnap = await _db
        .collection('partners')
        .doc(partnerId)
        .collection('expenses')
        .where('isDeleted', isEqualTo: false)
        .get();

    final expenses = expensesSnap.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'title': data['title'] ?? '',
        'amount': data['amount'],
        'type': data['type'],
        'category': data['category'],
        'paidBy': data['paidBy'],
        'createdAt': (data['createdAt'] as Timestamp?)
                ?.toDate()
                .toIso8601String() ??
            DateTime.now().toIso8601String(),
      };
    }).toList();

    // Fetch custom categories
    final categoriesSnap = await _db
        .collection('partners')
        .doc(partnerId)
        .collection('customCategories')
        .get();

    final categories = categoriesSnap.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'type': data['type'] ?? 'expense',
      };
    }).toList();

    return {
      'version': 1,
      'partnerId': partnerId,
      'exportedAt': DateTime.now().toIso8601String(),
      'expenses': expenses,
      'customCategories': categories,
    };
  }

  // ─────────────────────────────────────────────
  // SHARE BACKUP AS JSON FILE
  // ─────────────────────────────────────────────
  static Future<void> createAndShareBackup({
    required String partnerId,
    required BuildContext context,
  }) async {
    final data = await fetchBackupData(partnerId: partnerId);
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final bytes = utf8.encode(jsonString);

    final dir = await getTemporaryDirectory();
    final fileName =
        'partner_ledger_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: 'Partner Ledger Backup',
      text: 'Partner Ledger backup file — $fileName',
    );
  }

  // ─────────────────────────────────────────────
  // RESTORE FROM JSON FILE
  // ─────────────────────────────────────────────
  static Future<RestoreResult> restoreFromFile({
    required String partnerId,
  }) async {
    try {
      // Pick JSON file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return RestoreResult(success: false, message: 'No file selected');
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> backupData = json.decode(jsonString);

      // Validate backup format
      if (!backupData.containsKey('expenses') ||
          !backupData.containsKey('version')) {
        return RestoreResult(
            success: false, message: 'Invalid backup file format');
      }

      int restoredExpenses = 0;
      int restoredCategories = 0;

      // Restore expenses
      final expenses = backupData['expenses'] as List<dynamic>;
      for (final expense in expenses) {
        final e = expense as Map<String, dynamic>;
        final docRef = _db
            .collection('partners')
            .doc(partnerId)
            .collection('expenses')
            .doc(e['id'] as String);

        final existing = await docRef.get();
        if (!existing.exists) {
          await docRef.set({
            'title': e['title'] ?? '',
            'amount': e['amount'],
            'type': e['type'],
            'category': e['category'],
            'paidBy': e['paidBy'],
            'createdAt': Timestamp.fromDate(
                DateTime.parse(e['createdAt'] as String)),
            'updatedAt': FieldValue.serverTimestamp(),
            'isDeleted': false,
          });
          restoredExpenses++;
        }
      }

      // Restore custom categories
      if (backupData.containsKey('customCategories')) {
        final categories =
            backupData['customCategories'] as List<dynamic>;
        for (final category in categories) {
          final c = category as Map<String, dynamic>;
          final docRef = _db
              .collection('partners')
              .doc(partnerId)
              .collection('customCategories')
              .doc(c['id'] as String);

          final existing = await docRef.get();
          if (!existing.exists) {
            await docRef.set({
              'name': c['name'],
              'type': c['type'],
              'createdAt': FieldValue.serverTimestamp(),
            });
            restoredCategories++;
          }
        }
      }

      return RestoreResult(
        success: true,
        message:
            'Restored $restoredExpenses transactions and $restoredCategories categories',
        restoredExpenses: restoredExpenses,
        restoredCategories: restoredCategories,
      );
    } catch (e) {
      return RestoreResult(
          success: false, message: 'Restore failed: ${e.toString()}');
    }
  }
}

class RestoreResult {
  final bool success;
  final String message;
  final int restoredExpenses;
  final int restoredCategories;

  RestoreResult({
    required this.success,
    required this.message,
    this.restoredExpenses = 0,
    this.restoredCategories = 0,
  });
}