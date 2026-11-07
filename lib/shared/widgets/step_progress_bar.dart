// ============================================================================
// BloodNorms | step_progress_bar.dart
// Candy 3D horizontal progress bar with glossy reflection highlight
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
    this.fillColor = BrandColors.green,
    this.height = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth * clamped;
          if (barWidth <= 0) return const SizedBox.shrink();

          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: barWidth,
              height: height,
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 2, left: 6, right: 6),
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
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
