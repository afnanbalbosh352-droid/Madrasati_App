import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/widgets/app_footer.dart';

class AddAssignmentScreen extends StatefulWidget {
  const AddAssignmentScreen({super.key});

  @override
  State<AddAssignmentScreen> createState() => _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends State<AddAssignmentScreen> {
  String? selectedClassId;
  String? selectedSubject;

  final _formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  final List<String> subjects = ['Math', 'Science', 'English'];

  Future<void> addAssignment() async {
    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance.collection('assignments').add({
      'classId': selectedClassId,
      'subject': selectedSubject,
      'title': titleCtrl.text.trim(),
      'description': descCtrl.text.trim(),
      'teacherId': FirebaseAuth.instance.currentUser!.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    titleCtrl.clear();
    descCtrl.clear();

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assignment submitted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teacherUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6C8CF5),
        title: const Text('Add Assignment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// 🔹 ADD FORM
            Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(teacherUid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const LinearProgressIndicator();
                        }
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>?;
                        final classes =
                            List<String>.from(data?['classes'] ?? []);

                        return DropdownButtonFormField<String>(
                          value: selectedClassId,
                          decoration: inputStyle(label: "Select Class"),
                          items: classes
                              .map((c) => DropdownMenuItem(
                                  value: c, child: Text(c)))
                              .toList(),
                          validator: (v) =>
                              v == null ? "Please select a class" : null,
                          onChanged: (v) =>
                              setState(() => selectedClassId = v),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedSubject,
                      decoration: inputStyle(label: "Select Subject"),
                      items: subjects
                          .map((s) => DropdownMenuItem(
                              value: s, child: Text(s)))
                          .toList(),
                      validator: (v) =>
                          v == null ? "Please select a subject" : null,
                      onChanged: (v) =>
                          setState(() => selectedSubject = v),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: titleCtrl,
                      decoration: inputStyle(label: "Title"),
                      validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? "Title is required"
                              : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: inputStyle(label: "Description"),
                      validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? "Description is required"
                              : null,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C8CF5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: addAssignment,
                child: const Text(
                  "Add Assignment",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 🔵 VIEW BUTTON
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/teacherAssignments');
              },
              child: const Text("View Added Assignments"),
            ),
            const AppFooter(lightBackground: true),
          ],
        ),
      ),
    );
  }

  InputDecoration inputStyle({required String label}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF2F4F8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
