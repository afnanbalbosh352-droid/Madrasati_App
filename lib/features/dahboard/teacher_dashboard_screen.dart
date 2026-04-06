import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // أضفنا مكتبة الفايرستور
import 'package:madrasati_app/core/widgets/app_footer.dart';
import 'package:madrasati_app/features/dahboard/student_dashboard_tile.dart';
import '../activities_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  // الألوان التي اخترتِها سابقاً للتصميم الاحترافي
  static const Color _primary = Color(0xFF6C8CF5);
  static const Color _primaryDark = Color(0xFF4E6FE3);
  static const Color _background = Color(0xFFF4F7FF);
  static const Color _textMuted = Color(0xFF6C7A92);

  String _teacherName = "Loading..."; // قيمة افتراضية لحين تحميل البيانات

  @override
  void initState() {
    super.initState();
    _fetchTeacherData(); // جلب بيانات المدرس فور فتح الصفحة
  }

  // دالة لجلب اسم المدرس من Firestore بناءً على الـ UID الخاص به
  Future<void> _fetchTeacherData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users') // المجموعة التي أنشأناها في Firestore
            .doc(user.uid)
            .get();

        if (userData.exists) {
          setState(() {
            _teacherName = userData['name'] ?? "Teacher"; // جلب الحقل 'Name' الذي أضفتِه
          });
        }
      }
    } catch (e) {
      setState(() { _teacherName = "Mrs. Hanan Saleem"; }); // fallback في حال حدوث خطأ
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primary,
        title: const Text(
          'Teacher Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 20),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context, _teacherName),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildWelcomeHeader(_teacherName),
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
                  title: 'Attendance',
                  icon: Icons.fact_check_rounded,
                  enabled: true,
                  onTap: () => Navigator.pushNamed(context, '/teacherAttendance'),
                ),
                StudentDashboardTile(
                  title: 'Activities', // تم تفعيل الأنشطة هنا أيضاً
                  icon: Icons.local_activity_rounded,
                  enabled: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ActivitiesScreen(userRole: 'Teacher', canAdd: false),
                    ),
                  ),
                ),
                StudentDashboardTile(
                  title: 'Add Assignments',
                  icon: Icons.assignment_outlined,
                  enabled: true,
                  onTap: () => Navigator.pushNamed(context, '/teacherAddAssignment'),
                ),
                StudentDashboardTile(
                  title: 'My Assignments',
                  icon: Icons.assignment_rounded,
                  enabled: true,
                  onTap: () => Navigator.pushNamed(context, '/teacherAssignments'),
                ),
                StudentDashboardTile(
                  title: 'Messages',
                  icon: Icons.chat_bubble_outline_rounded,
                  enabled: false,
                  onTap: () => _showComingSoon(context),
                ),
                StudentDashboardTile(
                  title: 'Grades',
                  icon: Icons.star_border_rounded,
                  enabled: false,
                  onTap: () => _showComingSoon(context),
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: AppFooter(lightBackground: true)),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, _primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back,', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('Teacher Account', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85))),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, String name) {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(name),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _drawerItem(context, Icons.person_outline_rounded, 'Profile'),
                _drawerItem(context, Icons.school_rounded, 'My Classes'),
                _drawerItem(
                  context,
                  Icons.local_activity_outlined,
                  'School Activities',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ActivitiesScreen(userRole: 'Teacher', canAdd: false),
                    ),
                  ),
                ),
                _drawerItem(context, Icons.settings_outlined, 'Settings'),
                const Divider(),
                _drawerItem(
                  context,
                  Icons.logout_rounded,
                  'Logout',
                  color: Colors.red,
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(context, '/roleSelection', (route) => false);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 48, bottom: 24, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [_primary, _primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Column(
        children: [
          const CircleAvatar(radius: 42, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 45, color: Colors.white)),
          const SizedBox(height: 14),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color ?? _textMuted, size: 22),
      title: Text(title, style: TextStyle(color: color ?? const Color(0xFF0B1930))),
      onTap: onTap ?? () => _showComingSoon(context),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('This feature is under development.'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }
}