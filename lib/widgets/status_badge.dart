import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Color-coded status badge
class StatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.getStatusColor(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        AppColors.getStatusLabel(status).toUpperCase(),
        style: TextStyle(
          color: status.toLowerCase() == 'izin' 
              ? AppColors.textPrimary 
              : AppColors.textWhite,
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
