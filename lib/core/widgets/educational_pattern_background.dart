import 'package:flutter/material.dart';

/// Professional background: solid or gradient base with subtle faded
/// educational icons in a 2×3 grid. Icon color adapts to the background.
class EducationalPatternBackground extends StatelessWidget {
  /// Base color when [gradient] is null.
  final Color baseColor;

  /// Opacity of the overlay icons (0.0–1.0). Typical: 0.12–0.2 for subtle.
  final double iconOpacity;

  /// Optional. When set, drawn on top of [baseColor]; icons use white fade.
  final Gradient? gradient;

  /// Optional icon color. If null, uses white with [iconOpacity] (good for colored/gradient backgrounds).
  final Color? iconColor;

  /// Child to stack on top of the background.
  final Widget child;

  static const List<IconData> _icons = [
    Icons.school_rounded,
    Icons.menu_book_rounded,
    Icons.calculate_rounded,
    Icons.science_rounded,
    Icons.edit_rounded,
    Icons.bookmark_rounded,
  ];

  const EducationalPatternBackground({
    super.key,
    required this.baseColor,
    required this.child,
    this.iconOpacity = 0.06,
    this.gradient,
    this.iconColor,
  });

  static const double _iconSize = 20.0;
  static const double _spacing = 36.0;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? Colors.white.withOpacity(iconOpacity);

    return Container(
      decoration: BoxDecoration(
        color: baseColor,
        gradient: gradient,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = (constraints.maxWidth / _spacing).floor().clamp(1, 25);
              final rows = (constraints.maxHeight / _spacing).floor().clamp(1, 30);
              final itemCount = cols * rows;

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisExtent: _spacing,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                ),
                itemCount: itemCount,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Center(
                    child: Icon(
                      _icons[index % _icons.length],
                      size: _iconSize,
                      color: effectiveIconColor,
                    ),
                  );
                },
              );
            },
          ),
          child,
        ],
      ),
    );
  }
}
