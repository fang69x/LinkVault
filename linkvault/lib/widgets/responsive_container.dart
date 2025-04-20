import 'package:flutter/material.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool centerContent;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.centerContent = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if we're on a small screen
        final isSmallScreen = constraints.maxWidth < 600;

        // Calculate width based on screen size
        final double width = isSmallScreen
            ? constraints.maxWidth
            : constraints.maxWidth > 1200
                ? 1200
                : constraints.maxWidth * 0.8;

        return Center(
          child: SizedBox(
            width: width,
            child: Padding(
              padding: padding ?? EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
              child: centerContent ? Center(child: child) : child,
            ),
          ),
        );
      },
    );
  }
}
