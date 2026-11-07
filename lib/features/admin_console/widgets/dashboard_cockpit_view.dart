// ============================================================================
// BloodNorms | dashboard_cockpit_view.dart
// Modern Minimal Operations Dashboard & KPI Cards Overview
// ============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/models/blood_bank_model.dart';
import '../../../shared/models/camp_model.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_pill_button.dart';
import 'cockpit_kpi_cards_row.dart';

export 'cockpit_kpi_cards_row.dart';

class DashboardCockpitView extends StatelessWidget {
  final List<Map<String, dynamic>> liveRequests;
  final List<BloodBankModel> banksList;
  final List<Map<String, dynamic>> donorsList;
  final List<CampModel> campsList;
  final Map<String, dynamic> dailySpend;
  final VoidCallback onOpenRadar;
  final void Function(String id, double currentKm) onWidenRequest;
  final void Function(String id) onCloseRequest;

  const DashboardCockpitView({
    super.key,
    required this.liveRequests,
    required this.banksList,
    required this.donorsList,
    required this.campsList,
    required this.dailySpend,
    required this.onOpenRadar,
    required this.onWidenRequest,
    required this.onCloseRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CockpitKPICardsRow(
          liveRequests: liveRequests,
          banksList: banksList,
          donorsList: donorsList,
          campsList: campsList,
          dailySpend: dailySpend,
        ),
        const SizedBox(height: 20),
        Container(
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
                        'Live emergencies',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: BrandColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Real-time donor matching in pilot network',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontSize: 13,
                          color: BrandColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  AppPillButton(
                    label: 'Open radar',
                    icon: Icons.radar_rounded,
                    variant: AppPillButtonVariant.secondary,
                    onPressed: onOpenRadar,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (liveRequests.isEmpty)
                const AppEmptyState(
                  icon: Icons.health_and_safety_outlined,
                  title: 'No active emergencies right now',
                  description: 'The network is standing by and monitoring all hospital requests.',
                )
              else
                ...liveRequests.take(3).map((r) => _buildEmergencyRow(r)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyRow(Map<String, dynamic> req) {
    final id = req['id']?.toString() ?? '';
    final hosp = req['hospital_name'] ?? 'Hospital';
    final bg = req['blood_group'] ?? 'O+';
    final units = req['units_needed'] ?? 1;
    final phone = req['requester_phone'] ?? '';
    final ringKm = (req['current_ring_km'] as num?)?.toDouble() ?? 1.5;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: BrandColors.surfaceSoft,
          borderRadius: BorderRadius.circular(BrandColors.radiusCard),
          border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: BrandColors.statusErrorTint,
                    borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                  ),
                  child: Text(
                    bg,
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: FontWeight.w600,
                      color: BrandColors.statusError,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$hosp · $units Units',
                      style: const TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: BrandColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Search ring: ${ringKm.toStringAsFixed(1)} km · $phone',
                      style: const TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 12,
                        color: BrandColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                if (phone.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.phone_outlined, size: 18, color: BrandColors.statusSuccess),
                    tooltip: 'Call requester',
                    onPressed: () async {
                      final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
                      if (await canLaunchUrl(uri)) await launchUrl(uri);
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.zoom_out_map_rounded, size: 18, color: BrandColors.accent),
                  tooltip: 'Widen search (+2 km)',
                  onPressed: () => onWidenRequest(id, ringKm),
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18, color: BrandColors.statusSuccess),
                  tooltip: 'Resolve crisis',
                  onPressed: () => onCloseRequest(id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
