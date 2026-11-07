// ============================================================================
// BloodNorms | bank_more_tab_view.dart
// Blood Bank Console: More Info & Team Settings Tab
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/screen_header.dart';

class BankMoreTabView extends StatelessWidget {
  const BankMoreTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.bgGrouped,
      appBar: const ScreenHeader(
        title: 'Bank Info & Team',
        showBackButton: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Text('Rotary Central Bank', style: BrandTypography.title1(color: BrandColors.textPrimary)),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: BrandColors.border, width: 2.0),
                boxShadow: const [
                  BoxShadow(
                    color: BrandColors.border,
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: BrandColors.greenTint,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: BrandColors.greenShadow, width: 1.5),
                          ),
                          child: const Icon(Icons.access_time_filled_rounded, color: BrandColors.green, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Operating Hours', style: BrandTypography.headline(color: BrandColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text('Open 24 Hours · 7 Days', style: BrandTypography.caption(color: BrandColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: BrandColors.border),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: BrandColors.redTint,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: BrandColors.redShadow, width: 1.5),
                          ),
                          child: const Icon(Icons.groups_rounded, color: BrandColors.red, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Team Staff Accounts', style: BrandTypography.headline(color: BrandColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text('3 active members · Invite by phone', style: BrandTypography.caption(color: BrandColors.textSecondary)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 20, color: BrandColors.textSecondary),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: BrandColors.border),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: BrandColors.greenTint,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: BrandColors.greenShadow, width: 1.5),
                          ),
                          child: const Icon(Icons.verified_rounded, color: BrandColors.green, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bank Trust Score', style: BrandTypography.headline(color: BrandColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text('Score: 85 (Reliable)', style: BrandTypography.caption(color: BrandColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: BrandColors.greenTint,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: BrandColors.greenShadow, width: 1.0),
                          ),
                          child: const Text(
                            'RELIABLE',
                            style: TextStyle(
                              fontFamily: BrandTypography.fontFamily,
                              color: BrandColors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ActionButton(
              label: 'EXIT CONSOLE',
              variant: ActionButtonVariant.secondary,
              onPressed: () => context.go('/'),
            ),
          ],
        ),
      ),
    );
  }
}
