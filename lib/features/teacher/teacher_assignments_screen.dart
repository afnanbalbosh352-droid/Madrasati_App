import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/widgets/app_footer.dart';

class TeacherAssignmentsScreen extends StatelessWidget {
  const TeacherAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teacherId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Assignments"),
        backgroundColor: const Color(0xFF6C8CF5),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('assignments')
            .where('teacherId', isEqualTo: teacherId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No assignments yet"));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(data['title'] ?? ''),
                  subtitle: Text(data['description'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/editAssignment',
                            arguments: doc,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => doc.reference.delete(),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
            ),
          ),
          const AppFooter(lightBackground: true),
        ],
      ),
    );
  }
}
