import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/widgets/app_footer.dart';

class ChooseClassScreen extends StatelessWidget {
  final String teacherUid;
  final String schoolId;

  const ChooseClassScreen({
    super.key,
    required this.teacherUid,
    required this.schoolId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Class')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('classes')
                  .where('schoolId', isEqualTo: schoolId)
                  .where('teacherAuthUid', isEqualTo: teacherUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No classes found'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, i) {
                    final doc = snapshot.data!.docs[i];
                    final className = doc['name'] ?? doc.id;

                    return ListTile(
                      title: Text(className),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.pop(context, doc.id);
                      },
                    );
                  },
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
