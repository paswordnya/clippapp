import 'package:flutter/material.dart';
import 'package:semarewards/app/theme/app_colors.dart';

class ExportButton extends StatelessWidget {
  const ExportButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onPrimary),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    final effectiveOnPressed = isLoading ? null : onPressed;

    return outlined
        ? OutlinedButton(onPressed: effectiveOnPressed, child: child)
        : ElevatedButton(onPressed: effectiveOnPressed, child: child);
  }
}
