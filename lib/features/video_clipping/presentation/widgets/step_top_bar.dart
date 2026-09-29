import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:semarewards/app/theme/app_colors.dart';
import 'package:semarewards/features/video_clipping/presentation/state/video_clipping_state.dart';

class StepTopBar extends StatelessWidget {
  const StepTopBar({
    super.key,
    required this.currentStep,
    required this.onBack,
    required this.onStepSelected,
    required this.onNext,
    required this.nextLabel,
  });

  final EditorStep currentStep;
  final VoidCallback onBack;
  final ValueChanged<EditorStep> onStepSelected;
  final VoidCallback onNext;
  final String nextLabel;

  static const _steps = [
    (EditorStep.trim, 'Trim'),
    (EditorStep.frame, 'Frame'),
    (EditorStep.caption, 'Caption'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _GlassCircleButton(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
        const Spacer(),
        _StepPills(currentStep: currentStep, onStepSelected: onStepSelected),
        const Spacer(),
        _NextButton(label: nextLabel, onTap: onNext),
      ],
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  const _GlassCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: AppColors.glass,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, size: 18, color: AppColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepPills extends StatelessWidget {
  const _StepPills({required this.currentStep, required this.onStepSelected});

  final EditorStep currentStep;
  final ValueChanged<EditorStep> onStepSelected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.glass,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: StepTopBar._steps.map((s) {
              final isActive = s.$1 == currentStep;
              return InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () => onStepSelected(s.$1),
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.textPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    s.$2,
                    style: TextStyle(
                      fontFamily: 'Instrument Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: isActive
                          ? AppColors.background
                          : AppColors.textPrimary.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Instrument Sans',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
