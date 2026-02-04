import 'package:flutter/material.dart';

/// Footer for app screens.
/// Use [professional] on login and role selection for the full tagline + copyright.
/// Use [lightBackground] on light screens for correct text color.
class AppFooter extends StatelessWidget {
  final bool lightBackground;
  final bool professional;

  const AppFooter({
    super.key,
    this.lightBackground = false,
    this.professional = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = lightBackground
        ? Colors.grey.shade600
        : Colors.white.withOpacity(0.8);

    if (professional) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Connecting parents and schools',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '© 2025. All rights reserved.',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: color.withOpacity(0.9),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          '© 2025',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: color,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
