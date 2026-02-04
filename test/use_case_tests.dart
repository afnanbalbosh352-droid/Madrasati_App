// =============================================================================
// MADRASATI APP — USE CASE TESTS
// =============================================================================
//
// These tests are grouped by USE CASE: a short description of what the user
// does and what the app should do. Easy to present in a defense.
//
// HOW TO RUN:
//   See HOW_TO_RUN_TESTS.md in the test folder, or run:
//     flutter test test/use_case_tests.dart
//   From project root:
//     flutter test
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:madrasati_app/features/splash/splash_screen.dart';
import 'package:madrasati_app/features/role_selection/role_selection_screen.dart';
import 'package:madrasati_app/features/auth/student_login_screen.dart';
import 'package:madrasati_app/features/auth/teacher_login_screen.dart';
import 'package:madrasati_app/features/auth/admin_login_screen.dart';
import 'package:madrasati_app/core/widgets/educational_pattern_background.dart';

// --- Helpers used across use cases (same logic as in the app) ---
bool canAttemptLogin(String id, String password) {
  return id.trim().isNotEmpty && password.trim().isNotEmpty;
}

String buildTeacherEmail(String nationalId) =>
    'teacher_${nationalId.trim()}@madrasati.edu';

String buildStudentEmail(String nationalId) =>
    'student_${nationalId.trim()}@madrasati.edu';

String buildAdminEmail(String schoolId) =>
    'admin@${schoolId.trim()}.edu.jo';

void main() {
  // -------------------------------------------------------------------------
  // USE CASE 1: User opens the app and sees the splash screen
  // -------------------------------------------------------------------------
  group('Use case 1: User opens app and sees splash', () {
    testWidgets('Splash shows app name Madrasati', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(),
          routes: {'/roleSelection': (context) => const SizedBox()},
        ),
      );
      expect(find.text('Madrasati'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('Splash shows tagline', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(),
          routes: {'/roleSelection': (context) => const SizedBox()},
        ),
      );
      expect(find.text('Your School Companion'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });
  });

  // -------------------------------------------------------------------------
  // USE CASE 2: User chooses how to log in (role selection)
  // -------------------------------------------------------------------------
  group('Use case 2: User chooses role', () {
    testWidgets('Role screen shows Madrasati and three options', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RoleSelectionScreen()),
      );
      expect(find.text('Madrasati'), findsOneWidget);
      expect(find.text('Choose how to continue'), findsOneWidget);
      expect(find.text('School Administration'), findsOneWidget);
      expect(find.text('Teacher'), findsOneWidget);
      expect(find.text('Parent'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // USE CASE 3: Teacher opens login screen
  // -------------------------------------------------------------------------
  group('Use case 3: Teacher opens login', () {
    test('Empty credentials must not allow login attempt', () {
      expect(canAttemptLogin('', ''), isFalse);
      expect(canAttemptLogin('123', ''), isFalse);
    });

    test('Teacher email is built from National ID', () {
      expect(buildTeacherEmail('999'), equals('teacher_999@madrasati.edu'));
    });

    testWidgets('Teacher login screen has title and Login button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: TeacherLoginScreen()),
      );
      expect(find.text('Login as a Teacher'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
    });
  });

  // -------------------------------------------------------------------------
  // USE CASE 4: Parent/Student opens login screen
  // -------------------------------------------------------------------------
  group('Use case 4: Parent/Student opens login', () {
    test('Valid ID and password allow login attempt', () {
      expect(canAttemptLogin('12345', 'pass'), isTrue);
    });

    test('Student email is built from National ID', () {
      expect(buildStudentEmail('888'), equals('student_888@madrasati.edu'));
    });

    testWidgets('Student login screen has title and Login button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: StudentLoginScreen()),
      );
      expect(find.text('Login as a Parent'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // USE CASE 5: Admin opens login screen
  // -------------------------------------------------------------------------
  group('Use case 5: Admin opens login', () {
    test('Admin email is built from School ID', () {
      expect(buildAdminEmail('school1'), contains('school1'));
    });

    testWidgets('Admin login screen has title and Login button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AdminLoginScreen()),
      );
      expect(find.text('Log in as an Admin'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // USE CASE 6: Student views absence log (date parsing for display)
  // -------------------------------------------------------------------------
  // Absence log screen needs Firebase; we test the use case via date logic.
  group('Use case 6: Student views absence log', () {
    DateTime? dateFromRecord(String? dateKey) {
      if (dateKey == null || dateKey.isEmpty) return null;
      final parts = dateKey.split('-');
      if (parts.length != 3) return null;
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y == null || m == null || d == null) return null;
      return DateTime(y, m, d);
    }

    test('Absence dateKey is parsed correctly for display', () {
      expect(dateFromRecord('2025-02-04'), isNotNull);
      expect(dateFromRecord('2025-02-04')!.day, equals(4));
      expect(dateFromRecord('invalid'), isNull);
      expect(dateFromRecord(''), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // USE CASE 7: App uses shared pattern background
  // -------------------------------------------------------------------------
  group('Use case 7: Shared UI — pattern background', () {
    testWidgets('Pattern background shows child content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EducationalPatternBackground(
              baseColor: Colors.blue,
              child: const Center(child: Text('Content')),
            ),
          ),
        ),
      );
      expect(find.text('Content'), findsOneWidget);
    });
  });
}
