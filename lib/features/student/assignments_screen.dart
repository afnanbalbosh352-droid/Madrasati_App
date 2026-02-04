import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/widgets/app_footer.dart';

class ViewAssignmentsScreen extends StatefulWidget {
  const ViewAssignmentsScreen({super.key});

  @override
  State<ViewAssignmentsScreen> createState() => _ViewAssignmentsScreenState();
}

class _ViewAssignmentsScreenState extends State<ViewAssignmentsScreen> {
  Map<String, dynamic>? selectedAssignment;

  Future<String?> getStudentClass() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;

    return data['classId']?.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedAssignment == null
            ? 'Assignments'
            : 'Assignment Details' , selectionColor: Color(0xFF007BFF),),
        leading: selectedAssignment != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => selectedAssignment = null),
              )
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: selectedAssignment == null
                ? _buildAssignmentsList()
                : _buildDetailsView(),
          ),
          const AppFooter(lightBackground: true),
        ],
      ),
    );
  }

  Widget _buildAssignmentsList() {
    return FutureBuilder<String?>(
      future: getStudentClass(),
      builder: (context, classSnap) {
        if (classSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (classSnap.data == null) {
          return const Center(child: Text('Student class not assigned'));
        }

        final classId = classSnap.data!;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('assignments')
              .where('classId', isEqualTo: classId)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snap.hasData || snap.data!.docs.isEmpty) {
              return const Center(child: Text('No assignments yet'));
            }

            return ListView.builder(
              itemCount: snap.data!.docs.length,
              itemBuilder: (context, i) {
                final raw =
                    snap.data!.docs[i].data() as Map<String, dynamic>;

                final subject = raw['subject']?.toString() ?? 'No Subject';
                final title = raw['title']?.toString() ?? 'No Title';
                final description =
                    raw['description']?.toString() ?? 'No Description';

                return InkWell(
                  onTap: () => setState(() => selectedAssignment = raw),
                  child: Card(
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(subject,
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(title,
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDetailsView() {
    final subject = selectedAssignment?['subject']?.toString() ?? 'No Subject';
    final title = selectedAssignment?['title']?.toString() ?? 'No Title';
    final description =
        selectedAssignment?['description']?.toString() ?? 'No Description';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subject,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue)),
          const SizedBox(height: 12),
          Text(title,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(description),
        ],
      ),
    );
  }
}
