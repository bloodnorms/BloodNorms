// ============================================================================
// BloodNorms | step_progress_bar.dart
// Clean, modern horizontal progress bar with smooth transition
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';

class StepProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color fillColor;
  final double height;

  const StepProgressBar({
    super.key,
    required this.progress,
    this.fillColor = BrandColors.primaryAction,
    this.height = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: BrandColors.surfaceMuted,
        borderRadius: BorderRadius.circular(BrandColors.radiusPill),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth * clamped;
          if (barWidth <= 0) return const SizedBox.shrink();

          return Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: barWidth,
              height: height,
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(BrandColors.radiusPill),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Backward compatibility alias
typedef DuoProgressBar = StepProgressBar;
