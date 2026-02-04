import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:madrasati_app/core/widgets/app_footer.dart';
import 'package:madrasati_app/features/dahboard/student_dashboard_tile.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  static const Color _primary = Color(0xFF6C8CF5);
  static const Color _primaryDark = Color(0xFF4E6FE3);
  static const Color _background = Color(0xFFF4F7FF);
  static const Color _textMuted = Color(0xFF6C7A92);

  @override
  Widget build(BuildContext context) {
    final name = FirebaseAuth.instance.currentUser?.displayName ?? 'Mrs. Hanan Saleem';

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
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context, name),
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
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Teacher',
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
                  title: 'Attendance',
                  icon: Icons.fact_check_rounded,
                  enabled: true,
                  onTap: () => Navigator.pushNamed(context, '/teacherAttendance'),
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
                StudentDashboardTile(
                  title: 'Weekly Lessons',
                  icon: Icons.schedule_rounded,
                  enabled: false,
                  onTap: () => _showComingSoon(context),
                ),
                StudentDashboardTile(
                  title: 'Class Schedule',
                  icon: Icons.calendar_month_rounded,
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

  Widget _buildDrawer(BuildContext context, String name) {
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
                  backgroundImage: const AssetImage('assets/images/teacherprofile.png'),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Teacher',
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
                _drawerItem(context, Icons.school_rounded, 'My Classes'),
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
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Coming Soon'),
        content: const Text('This feature will be available later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
