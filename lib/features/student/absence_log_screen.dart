import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/app_footer.dart';
import '../../data/services/firestore_service.dart';

class AbsenceLogScreen extends StatelessWidget {
  const AbsenceLogScreen({super.key});

  static const Color _primary = Color(0xFF6C8CF5);
  static const Color _primaryDark = Color(0xFF4E6FE3);
  static const Color _background = Color(0xFFF4F7FF);
  static const Color _textMuted = Color(0xFF6C7A92);

  @override
  Widget build(BuildContext context) {
    final studentUid = FirebaseAuth.instance.currentUser!.uid;

    // Fetch absences from attendance records (same data that triggers the absence notification)
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text(
          'Absence Log',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.instance.studentAbsenceStream(studentUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Something went wrong. ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _textMuted),
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return _buildEmptyState(
              icon: Icons.celebration_rounded,
              message: 'No absences recorded. Keep it up!',
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primary, _primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Text(
                  'Your absence history',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _AbsenceTable(absenceDocs: docs),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
            ),
          ),
          const AppFooter(lightBackground: true),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: _primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: _textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AbsenceTable extends StatelessWidget {
  const _AbsenceTable({required this.absenceDocs});

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> absenceDocs;

  static const Color _primary = Color(0xFF6C8CF5);
  static const Color _primaryDark = Color(0xFF4E6FE3);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _absentRed = Color(0xFFE53935);
  static const Color _textMuted = Color(0xFF6C7A92);
  static const Color _border = Color(0xFFE8ECF4);

  static const double _minTableWidth = 320;
  static const double _colDay = 100;
  static const double _colDate = 120;
  static const double _colStatus = 90;

  /// Parse dateKey (e.g. "2025-02-04") to DateTime for display.
  static DateTime? _dateFromRecord(Map<String, dynamic> data) {
    final dateKey = data['dateKey'] as String?;
    if (dateKey == null || dateKey.isEmpty) return null;
    final parts = dateKey.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: _minTableWidth),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(color: _border, width: 1),
          ),
          columnWidths: const {
            0: FixedColumnWidth(_colDay),
            1: FixedColumnWidth(_colDate),
            2: FixedColumnWidth(_colStatus),
          },
        children: [
          TableRow(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primary, _primaryDark],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            children: [
              _tableHeaderCell('Day'),
              _tableHeaderCell('Date'),
              _tableHeaderCell('Status'),
            ],
          ),
          ...absenceDocs.map((doc) {
            final data = doc.data();
            final date = _dateFromRecord(data);
            final dayName = date != null
                ? DateFormat('EEEE').format(date)
                : data['dateKey']?.toString() ?? '—';
            final dateStr = date != null
                ? DateFormat('d MMM yyyy').format(date)
                : data['dateKey']?.toString() ?? '—';
            return TableRow(
              decoration: BoxDecoration(
                color: absenceDocs.indexOf(doc) % 2 == 1
                    ? _primary.withOpacity(0.04)
                    : _surface,
              ),
              children: [
                _tableCell(dayName, isBold: true),
                _tableCell(dateStr),
                _tableCell('Absent', statusColor: _absentRed),
              ],
            );
          }),
        ],
      ),
    ),
    );
  }

  Widget _tableHeaderCell(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _tableCell(String text, {bool isBold = false, Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
          color: statusColor ?? _textMuted,
        ),
      ),
    );
  }
}
