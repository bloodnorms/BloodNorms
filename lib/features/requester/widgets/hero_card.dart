// ============================================================================
// BloodNorms | hero_card.dart
// 176px Red Gradient Hero Card with Illustrated Blood Bag & Find Blood Button
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/brand_typography.dart';
import '../providers/request_flow_provider.dart';
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
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE52E2E),
            Color(0xFFC71D1D),
            Color(0xFFA11313),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE52E2E).withValues(alpha: 0.32),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Need blood\nright now?',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.6,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Get in touch with donors and blood banks near you, in minutes.',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.normal,
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.38,
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                flex: 4,
                child: SizedBox(
                  height: 130,
                  child: Center(
                    child: CustomPaint(
                      size: Size(80, 120),
                      painter: BloodBagPainter(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (activeRequest != null && activeRequest!['status'] == 'searching') {
                  showActiveRequestConflictDialog(context, activeRequest!);
                } else {
                  context.push('/group');
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      color: Color(0xFFE52E2E),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Find Blood Now',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE52E2E),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
