// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // أضفنا مكتبة الفايرستور للتحقق من الدور
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/widgets/app_footer.dart';
import '../../core/widgets/educational_pattern_background.dart';

class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  static const Color _primary = Color(0xFF6C8CF5);
  static const Color _primaryDark = Color(0xFF4E6FE3);

  final idController = TextEditingController();
  final passController = TextEditingController();
  bool loading = false;

  // الدالة المعدلة للتحقق من الحساب والدور
  Future<void> login() async {
    if (idController.text.isEmpty || passController.text.isEmpty) {
      _showSnackBar('Please fill all fields', isError: true);
      return;
    }

    setState(() => loading = true);

    try {
      // 1. تسجيل الدخول عبر Firebase Auth
      final email = "teacher_${idController.text.trim()}@madrasati.edu";
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: passController.text.trim(),
      );

      // 2. جلب بيانات المستخدم من Firestore للتأكد من أنه "Teacher"
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users') // تأكدي أن المجموعة في الفايربيس اسمها users
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        String role = userDoc['role'] ?? ''; // قراءة حقل role من Firestore

        if (role.toLowerCase() == 'teacher') {
          if (!mounted) return;
          // تم التحقق بنجاح، ننتقل للداشبورد
          Navigator.pushReplacementNamed(context, '/teacherDashboard');
        } else {
          // إذا كان الحساب موجوداً ولكن ليس لمدرس (طالب مثلاً)
          await FirebaseAuth.instance.signOut();
          _showSnackBar('Access Denied: You are not a Teacher.', isError: true);
        }
      } else {
        _showSnackBar('User profile not found in database.', isError: true);
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? 'Login failed', isError: true);
    } catch (e) {
      _showSnackBar('An error occurred. Please try again.', isError: true);
    }

    if (mounted) setState(() => loading = false);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    idController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EducationalPatternBackground(
        baseColor: _primary,
        gradient: const LinearGradient(
          colors: [_primary, _primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        iconOpacity: 0.06,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 400),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Lottie.asset(
                                      'assets/animations/teacher.json',
                                      height: 180,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Log in as a Teacher',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    _input(Icons.badge_outlined, 'Teacher ID / National ID', idController),
                                    const SizedBox(height: 16),
                                    _input(Icons.lock_outline_rounded, 'Password', passController, true),
                                    const SizedBox(height: 24),
                                    _button(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const AppFooter(professional: true),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pushReplacementNamed(context, '/roleSelection'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(IconData icon, String hint, TextEditingController c, [bool ob = false]) {
    return TextField(
      controller: c,
      obscureText: ob,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: _primary, size: 22),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _button() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _primaryDark,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: loading ? null : login,
        child: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: _primaryDark),
              )
            : const Text(
                'Login',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
