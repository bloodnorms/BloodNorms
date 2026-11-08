// ============================================================================
// BloodNorms | blood_camps_admin_view.dart
// Modern Minimal Blood Camps Admin Roster & Drive Scheduling
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/models/blood_bank_model.dart';
import '../../../shared/models/camp_model.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';
import 'blood_camps_create_card.dart';

class BloodCampsAdminView extends StatelessWidget {
  final String subPage; // 'camps_list' | 'camps_create'
  final List<CampModel> campsList;
  final List<BloodBankModel> banksList;
  final VoidCallback onNavigateToCreate;
  final void Function(CampModel camp) onCampSelectedForBroadcast;
  final void Function(CampModel newCamp) onCampCreated;
  final void Function(String message) onShowToast;

  const BloodCampsAdminView({
    super.key,
    required this.subPage,
    required this.campsList,
    required this.banksList,
    required this.onNavigateToCreate,
    required this.onCampSelectedForBroadcast,
    required this.onCampCreated,
    required this.onShowToast,
  });

  @override
  Widget build(BuildContext context) {
    if (subPage == 'camps_create') {
      return BloodCampsCreateCard(
        banksList: banksList,
        onCampCreated: onCampCreated,
        onShowToast: onShowToast,
      );
    }
    return _buildCampsListPage();
  }

  Widget _buildCampsListPage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scheduled blood drives',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: BrandColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Voluntary donation camps organized across regions',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 13,
                      color: BrandColors.textSecondary,
                    ),
                  ),
                ],
              ),
              AppPillButton(
                label: 'Schedule new drive',
                icon: Icons.add_rounded,
                variant: AppPillButtonVariant.primary,
                onPressed: onNavigateToCreate,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...campsList.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BrandColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(BrandColors.radiusCard),
                  border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.title,
                          style: const TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: BrandColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${c.venue} · ${c.area}, ${c.city} · ${c.targetRadiusKm} km radius · Target: ${c.capacity} donors',
                          style: const TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            fontSize: 12,
                            color: BrandColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    AppPillButton(
                      label: 'Broadcast',
                      icon: Icons.campaign_outlined,
                      variant: AppPillButtonVariant.secondary,
                      onPressed: () => onCampSelectedForBroadcast(c),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
