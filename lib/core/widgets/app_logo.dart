import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const AppLogo({
    super.key,
    this.size = 80,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary.withAlpha(51),
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Icon(
        Icons.health_and_safety_rounded,
        size: size * 0.56,
        color: iconColor ?? AppColors.textWhite,
      ),
    );
  }
}
