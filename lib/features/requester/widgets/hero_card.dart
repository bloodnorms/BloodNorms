// ============================================================================
// BloodNorms | hero_card.dart
// Clean, minimal hero card with quick Find Blood action pill
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';
import 'active_request_conflict_dialog.dart';
import 'blood_bag_painter.dart';

class HeroCard extends StatelessWidget {
  final Map<String, dynamic>? activeRequest;

  const HeroCard({
    super.key,
    required this.activeRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
        boxShadow: BrandColors.shadowCardHover,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need blood\nright now?',
                      style: BrandTypography.headline(color: BrandColors.textPrimary)
                          .copyWith(fontSize: 22, height: 1.25),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connect with verified volunteer donors and nearby blood banks in minutes.',
                      style: BrandTypography.body(color: BrandColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Expanded(
                flex: 4,
                child: SizedBox(
                  height: 110,
                  child: Center(
                    child: CustomPaint(
                      size: Size(70, 105),
                      painter: BloodBagPainter(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: AppPillButton(
              label: 'Find Blood Now',
              icon: Icons.search_rounded,
              variant: AppPillButtonVariant.primary,
              onPressed: () {
                if (activeRequest != null && activeRequest!['status'] == 'searching') {
                  showActiveRequestConflictDialog(context, activeRequest!);
                } else {
                  context.push('/group');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
