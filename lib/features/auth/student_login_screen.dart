import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/widgets/app_footer.dart';
import '../../core/widgets/educational_pattern_background.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  static const Color _primary = Color(0xFF6C8CF5);
  static const Color _primaryDark = Color(0xFF4E6FE3);

  final idController = TextEditingController();
  final passController = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    if (idController.text.isEmpty || passController.text.isEmpty) return;

    setState(() => loading = true);

    try {
      final email = "student_${idController.text.trim()}@madrasati.edu";
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: passController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/studentDashboard');
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (mounted) setState(() => loading = false);
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Lottie.asset(
                                      'assets/animations/student.json',
                                      height: 180,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Login as a Parent',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    _input(Icons.badge, 'Student National ID', idController),
                                    const SizedBox(height: 16),
                                    _input(Icons.lock, 'Password', passController, true),
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
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/roleSelection'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(IconData icon, String hint, TextEditingController c,
      [bool ob = false]) {
    return TextField(
      controller: c,
      obscureText: ob,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: _primary),
        hintText: hint,
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
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: loading ? null : login,
        child: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6C8CF5)),
              )
            : const Text(
                'Login',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
