import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/app_footer.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), backgroundColor: Colors.blue,),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications'));
          }

          return ListView.builder(
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, i) {
              final d = snap.data!.docs[i];
              final title = d['title'] ?? '';
              final body = d['body'] ?? '';
              final read = d['read'] ?? false;

              final ts = d['createdAt'];
              String timeStr = '';
              if (ts != null) {
                timeStr =
                    DateFormat('yyyy-MM-dd – HH:mm').format(ts.toDate());
              }

              return ListTile(
                tileColor: read ? null : Colors.blue.withOpacity(0.08),
                title: Text(title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(body),
                    const SizedBox(height: 4),
                    Text(timeStr,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),
                  ],
                ),
                trailing: !read
                    ? const Icon(Icons.circle, size: 10, color: Colors.blue)
                    : null,
                onTap: () async {
                  await d.reference.update({'read': true});
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
