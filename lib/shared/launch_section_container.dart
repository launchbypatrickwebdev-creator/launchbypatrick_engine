// lib/shared/launch_section_container.dart

import 'package:flutter/material.dart';

class LaunchSectionContainer extends StatelessWidget {
  final Widget child;
  final double maxContentWidth;
  final bool useHorizontalPadding;
  final double? mobileHeight; // ✅ NEW: Optional mobile height override
  final double? desktopHeight; // ✅ NEW: Optional desktop height override

  const LaunchSectionContainer({
    super.key,
    required this.child,
    this.maxContentWidth = 1400,
    this.useHorizontalPadding = true,
    this.mobileHeight,
    this.desktopHeight,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    // 🛠️ The Uniform Traction Engine
    double dynamicPadding;
    if (screenWidth < 600) {
      dynamicPadding = 20.0;
    } else if (screenWidth < 1200) {
      dynamicPadding = 32.0;
    } else {
      dynamicPadding = 60.0;
    }

    return Center(
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: maxContentWidth,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: useHorizontalPadding ? dynamicPadding : 0.0,
        ),
        // ✅ NEW: Mobile containers are square-ish, desktop stay rectangular
        height: isMobile && mobileHeight != null
            ? mobileHeight
            : (!isMobile && desktopHeight != null ? desktopHeight : null),
        child: child,
      ),
    );
  }
}