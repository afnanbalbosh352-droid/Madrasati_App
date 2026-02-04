import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/widgets/app_footer.dart';

class EditAssignmentScreen extends StatefulWidget {
  final DocumentSnapshot doc;
  const EditAssignmentScreen({super.key, required this.doc});

  @override
  State<EditAssignmentScreen> createState() => _EditAssignmentScreenState();
}

class _EditAssignmentScreenState extends State<EditAssignmentScreen> {
  late TextEditingController titleCtrl;
  late TextEditingController descCtrl;
  final _formKey = GlobalKey<FormState>();

  static const Color _primary = Color(0xFF6C8CF5);
  static const Color _background = Color(0xFFF4F7FF);

  @override
  void initState() {
    super.initState();
    final data = widget.doc.data() as Map<String, dynamic>;
    titleCtrl = TextEditingController(text: data['title']);
    descCtrl = TextEditingController(text: data['description']);
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.doc.reference.update({
      'title': titleCtrl.text.trim(),
      'description': descCtrl.text.trim(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment updated')),
      );
      Navigator.pop(context);
    }
  }

  InputDecoration _inputStyle({required String label}) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primary,
        title: const Text(
          'Edit Assignment',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: titleCtrl,
                      decoration: _inputStyle(label: 'Title'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Title is required'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descCtrl,
                      maxLines: 4,
                      decoration: _inputStyle(label: 'Description'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Description is required'
                              : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: save,
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const AppFooter(lightBackground: true),
            ],
          ),
        ),
      ),
    );
  }
}
