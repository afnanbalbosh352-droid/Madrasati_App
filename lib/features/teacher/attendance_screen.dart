import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/app_footer.dart';
import '../../data/services/firestore_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool loading = false;

  String? schoolId;
  String? selectedClassId;

  /// List of {id, name} for dropdown
  List<Map<String, String>> classes = [];
  bool classesLoading = true;

  List<Map<String, dynamic>> students = [];
  final Map<String, bool> presentMap = {};
  DateTime selectedDate = DateTime.now();

  static const Color _primary = Color(0xFF6C8CF5);
  static const Color _primaryDark = Color(0xFF4E6FE3);
  static const Color _background = Color(0xFFF4F7FF);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF0B1930);
  static const Color _textMuted = Color(0xFF6C7A92);
  static const Color _border = Color(0xFFE8ECF4);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final teacherUid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirestoreService.instance.getUserDoc(teacherUid);
    setState(() {
      schoolId = (userDoc?['schoolId'] ?? '').toString();
    });
    await _loadClasses();
  }

  Future<void> _loadClasses() async {
    final teacherUid = FirebaseAuth.instance.currentUser!.uid;
    final sid = schoolId;
    if (sid == null || sid.isEmpty) {
      setState(() => classesLoading = false);
      return;
    }
    setState(() => classesLoading = true);
    final snapshot = await FirebaseFirestore.instance
        .collection('classes')
        .where('schoolId', isEqualTo: sid)
        .where('teacherAuthUid', isEqualTo: teacherUid)
        .get();
    final list = snapshot.docs.map((doc) {
      final name = doc['name'] ?? doc.id;
      return {'id': doc.id, 'name': name.toString()};
    }).toList();
    setState(() {
      classes = list;
      classesLoading = false;
    });
  }

  Future<void> _loadStudents() async {
    if (selectedClassId == null) return;
    setState(() => loading = true);

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('classId', isEqualTo: selectedClassId)
        .get();

    students = query.docs.map((doc) {
      final data = doc.data();
      return {
        'authUid': doc.id,
        'name': data['name'] ?? data['fullName'] ?? 'Student',
        'nationalId': data['nationalId'] ?? '',
      };
    }).toList();

    presentMap.clear();
    for (final s in students) {
      presentMap[s['authUid']] = true;
    }

    setState(() => loading = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primary,
              onPrimary: Colors.white,
              surface: _surface,
              onSurface: _textPrimary,
              secondary: _primaryDark,
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: _surface,
              elevation: 8,
              shadowColor: _primary.withOpacity(0.2),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  void _markAll({required bool present}) {
    setState(() {
      for (final s in students) {
        presentMap[s['authUid']] = present;
      }
    });
  }

  Future<void> _submit() async {
    if (selectedClassId == null || schoolId == null || schoolId!.isEmpty) return;

    final teacherUid = FirebaseAuth.instance.currentUser!.uid;
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

    final absent = <String>[];
    presentMap.forEach((uid, isPresent) {
      if (!isPresent) absent.add(uid);
    });

    setState(() => loading = true);

    for (final entry in presentMap.entries) {
      await FirestoreService.instance.submitAttendance(
        schoolId: schoolId!,
        classId: selectedClassId!,
        date: selectedDate,
        studentAuthUid: entry.key,
        recordedByUid: teacherUid,
        recordedByRole: 'teacher',
        isPresent: entry.value,
      );
    }

    if (absent.isNotEmpty) {
      final batch = FirebaseFirestore.instance.batch();
      for (final uid in absent) {
        final ref = FirebaseFirestore.instance.collection('notifications').doc();
        batch.set(ref, {
          'userId': uid,
          'title': 'Absence Recorded',
          'body': 'You were marked absent on $dateStr',
          'type': 'absence',
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }

    setState(() => loading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance submitted successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primary,
        title: const Text(
          'Take Attendance',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Date & Class selector card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_primary, _primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Date & Class',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _outlinedChip(
                        icon: Icons.calendar_month_rounded,
                        label: DateFormat('d MMM yyyy').format(selectedDate),
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _classDropdown(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Mark all buttons
          if (students.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _markAll(present: true),
                    icon: const Icon(Icons.check_circle_outline, size: 18, color: _primary),
                    label: const Text('Mark all present'),
                    style: TextButton.styleFrom(
                      foregroundColor: _primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _markAll(present: false),
                    icon: const Icon(Icons.cancel_outlined, size: 18, color: _textMuted),
                    label: const Text('Mark all absent'),
                    style: TextButton.styleFrom(
                      foregroundColor: _textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Table card
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator(color: _primary))
                : students.isEmpty
                    ? _buildEmptyState()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        child: SingleChildScrollView(
                          child: _buildTable(),
                        ),
                      ),
          ),

          // Submit button
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: students.isEmpty || loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _textMuted.withOpacity(0.3),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Submit Attendance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const AppFooter(lightBackground: true),
        ],
      ),
    );
  }

  Widget _classDropdown() {
    String displayLabel = 'Select Class';
    if (classesLoading) {
      displayLabel = 'Loading...';
    } else if (selectedClassId != null) {
      for (final c in classes) {
        if (c['id'] == selectedClassId) {
          displayLabel = c['name']!;
          break;
        }
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedClassId,
          isExpanded: true,
          dropdownColor: _surface,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.9), size: 24),
          hint: Row(
            children: [
              Icon(Icons.school_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  displayLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          selectedItemBuilder: (context) {
            return [
              ...classes.map((c) => Row(
                    children: [
                      const Icon(Icons.school_rounded, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          c['name']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )),
            ];
          },
          items: classes
              .map((c) => DropdownMenuItem<String>(
                    value: c['id'],
                    child: Row(
                      children: [
                        Icon(Icons.school_rounded, color: _primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            c['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: _textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: classesLoading || classes.isEmpty
              ? null
              : (String? id) {
                  if (id != null) {
                    setState(() => selectedClassId = id);
                    _loadStudents();
                  }
                },
        ),
      ),
    );
  }

  Widget _outlinedChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.8), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_rounded,
              size: 64,
              color: _primary.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              classes.isEmpty && !classesLoading
                  ? 'No classes assigned to you'
                  : 'Select a class from the dropdown above',
              style: TextStyle(
                fontSize: 16,
                color: _textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static const double _colIndex = 56;
  static const double _colName = 220;
  static const double _colPresent = 96;
  static const double _tableMinWidth = _colIndex + _colName + _colPresent;

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: _tableMinWidth),
        child: Container(
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _primary.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Table(
            border: TableBorder(
              horizontalInside: BorderSide(color: _border, width: 1),
            ),
            columnWidths: const {
              0: FixedColumnWidth(_colIndex),
              1: FixedColumnWidth(_colName),
              2: FixedColumnWidth(_colPresent),
            },
            children: [
              // Header: # | Student Name | Present
              TableRow(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primary, _primaryDark],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                children: [
                  _tableHeaderCell('#'),
                  _tableHeaderCell('Student Name'),
                  _tableHeaderCell('Present'),
                ],
              ),
              ...List.generate(students.length, (i) {
                final s = students[i];
                final uid = s['authUid'] as String;
                final name = s['name'] as String? ?? 'Student';
                final isPresent = presentMap[uid] ?? true;
                return TableRow(
                  decoration: BoxDecoration(
                    color: i.isOdd ? _primary.withOpacity(0.04) : _surface,
                  ),
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _textMuted,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Checkbox(
                          value: isPresent,
                          onChanged: (v) {
                            setState(() => presentMap[uid] = v ?? true);
                          },
                          activeColor: _primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableHeaderCell(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
    );
  }
}
