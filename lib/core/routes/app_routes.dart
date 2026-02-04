import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/role_selection/role_selection_screen.dart';

import '../../features/auth/student_login_screen.dart';
import '../../features/auth/teacher_login_screen.dart';
import '../../features/auth/admin_login_screen.dart';

import '../../features/dahboard/student_dashboard_screen.dart';
import '../../features/dahboard/teacher_dashboard_screen.dart';
import '../../features/dahboard/admin_dashboard_screen.dart';

import '../../features/student/absence_log_screen.dart';
import '../../features/student/assignments_screen.dart';
import '../../features/student/notifications_screen.dart';

import '../../features/teacher/attendance_screen.dart';
import '../../features/teacher/choose_class.dart';
import '../../features/teacher/edit_assignment_screen.dart';
import '../../features/teacher/teacher_add_assignments_screen.dart';
import '../../features/teacher/teacher_assignments_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {

    '/splash': (context) => const SplashScreen(),
    '/roleSelection': (context) => const RoleSelectionScreen(),

    '/studentLogin': (context) => const StudentLoginScreen(),
    '/teacherLogin': (context) => const TeacherLoginScreen(),
    '/adminLogin': (context) => const AdminLoginScreen(),

    '/studentDashboard': (context) => const StudentDashboardScreen(),
    '/teacherDashboard': (context) => const TeacherDashboardScreen(),
    '/adminDashboard': (context) => const AdminDashboardScreen(),

    '/studentAbsence': (context) => const AbsenceLogScreen(),
    '/studentAssignments': (context) => const ViewAssignmentsScreen(),
    '/studentNotifications': (context) => const NotificationsScreen(),

    '/chooseClass': (context) =>
        const ChooseClassScreen(teacherUid: '', schoolId: ''),

    '/teacherAttendance': (context) => const AttendanceScreen(),
    '/teacherAddAssignment': (context) => const AddAssignmentScreen(),

    '/teacherAssignments': (context) => const TeacherAssignmentsScreen(),

    '/editAssignment': (context) {
      final doc = ModalRoute.of(context)!.settings.arguments as DocumentSnapshot;
      return EditAssignmentScreen(doc: doc);
    },
  };
}
