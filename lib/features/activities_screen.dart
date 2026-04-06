import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivitiesScreen extends StatelessWidget {
  final String userRole; // 'Admin' or 'Teacher' or 'Student'
  final bool canAdd;

  const ActivitiesScreen({
    super.key, 
    required this.userRole, 
    this.canAdd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        title: const Text('School Activities', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6C8CF5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // زر الإضافة يظهر فقط للأدمن (أو حسب رغبتك)
      floatingActionButton: canAdd 
          ? FloatingActionButton(
              onPressed: () => _showAddActivityDialog(context),
              backgroundColor: const Color(0xFF6C8CF5),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: StreamBuilder<QuerySnapshot>(
        // جلب البيانات من مجموعة 'activities' في Firestore
        stream: FirebaseFirestore.instance.collection('activities').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Something went wrong'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No activities found yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index];
              return _buildActivityCard(
                title: data['title'] ?? 'No Title',
                description: data['description'] ?? '',
                imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/150',
                date: data['date'] ?? '',
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActivityCard({required String title, required String description, required String imageUrl, required String date}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150, 
                color: Colors.grey[200], 
                child: const Icon(Icons.broken_image, size: 50, color: Colors.grey)
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(description, style: TextStyle(color: Colors.grey[600], height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddActivityDialog(BuildContext context) {
    // سنقوم ببرمجة دالة الإضافة لاحقاً للأدمن
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add Activity Feature coming soon!')));
  }
}