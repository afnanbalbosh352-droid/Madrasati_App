import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:madrasati_app/core/widgets/app_footer.dart';
import 'package:madrasati_app/features/dahboard/student_dashboard_tile.dart';
import '../student/notifications_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  String studentName = '';
  String? uid;

  static const Color _primary = Color(0xFF6C8CF5);
  static const Color _primaryDark = Color(0xFF4E6FE3);
  static const Color _background = Color(0xFFF4F7FF);
  static const Color _textMuted = Color(0xFF6C7A92);

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid;
    loadName();
  }

  Future<void> loadName() async {
    if (uid == null) return;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return;
    setState(() {
      studentName = data['name']?.toString() ?? data['fullName']?.toString() ?? 'Student';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primary,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('notifications')
                      .where('userId', isEqualTo: uid)
                      .where('read', isEqualTo: false)
                      .snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData || snap.data!.docs.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final count = snap.data!.docs.length;
                    return Container(
                      padding: const EdgeInsets.all(5),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          count > 99 ? '99+' : count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primary, _primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    studentName.isEmpty ? 'Student' : studentName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Student',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.92,
              ),
              delegate: SliverChildListDelegate([
                StudentDashboardTile(
                  title: 'Absence Log',
                  icon: Icons.event_busy_rounded,
                  enabled: true,
                  onTap: () => Navigator.pushNamed(context, '/studentAbsence'),
                ),
                StudentDashboardTile(
                  title: 'View Assignments',
                  icon: Icons.assignment_rounded,
                  enabled: true,
                  onTap: () => Navigator.pushNamed(context, '/studentAssignments'),
                ),
                StudentDashboardTile(
                  title: 'Activities',
                  icon: Icons.event_rounded,
                  enabled: false,
                ),
                StudentDashboardTile(
                  title: 'Subjects',
                  icon: Icons.menu_book_rounded,
                  enabled: false,
                ),
                StudentDashboardTile(
                  title: 'Exam Schedule',
                  icon: Icons.schedule_rounded,
                  enabled: false,
                ),
                StudentDashboardTile(
                  title: 'Grades',
                  icon: Icons.star_border_rounded,
                  enabled: false,
                ),
                StudentDashboardTile(
                  title: 'Message Teacher',
                  icon: Icons.chat_bubble_outline_rounded,
                  enabled: false,
                ),
                StudentDashboardTile(
                  title: 'Monthly Assessment',
                  icon: Icons.bar_chart_rounded,
                  enabled: false,
                ),
                StudentDashboardTile(
                  title: 'Class Schedule',
                  icon: Icons.calendar_month_rounded,
                  enabled: false,
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: AppFooter(lightBackground: true)),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 48, bottom: 24, left: 24, right: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_primary, _primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  backgroundImage: const AssetImage('assets/images/studentprofile.png'),
                ),
                const SizedBox(height: 14),
                Text(
                  studentName.isEmpty ? 'Student' : studentName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Student',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _drawerItem(context, Icons.person_outline_rounded, 'Profile'),
                _drawerItem(context, Icons.settings_outlined, 'Settings'),
                _drawerItem(context, Icons.school_rounded, 'My School Info'),
                _drawerItem(context, Icons.notifications_outlined, 'Notification Settings'),
                _drawerItem(context, Icons.help_outline_rounded, 'Help Center'),
                _drawerItem(context, Icons.info_outline_rounded, 'About App'),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _drawerItem(
              context,
              Icons.logout_rounded,
              'Logout',
              color: Colors.red,
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/roleSelection',
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title, {
    Color? color,
    VoidCallback? onTap,
  }) {
    final isRed = color == Colors.red;
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? _textMuted,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? const Color(0xFF0B1930),
          fontWeight: isRed ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
      onTap: onTap ?? () => _showComingSoon(context),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Coming Soon'),
        content: const Text('This feature will be available later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
