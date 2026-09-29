import 'package:flutter/material.dart';
import 'package:semarewards/app/theme/app_colors.dart';

class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<(T value, String label)> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.track,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: options.map((o) {
          final isActive = o.$1 == value;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: () => onChanged(o.$1),
              child: Container(
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.active : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  o.$2,
                  style: TextStyle(
                    fontFamily: 'Instrument Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
