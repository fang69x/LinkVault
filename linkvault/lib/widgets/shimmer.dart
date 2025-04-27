import 'package:flutter/material.dart';
import 'package:linkvault/utils/theme.dart';

class BookmarkShimmer extends StatelessWidget {
  const BookmarkShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(), // No scroll while loading
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 6, // Show 6 shimmer placeholders
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}
