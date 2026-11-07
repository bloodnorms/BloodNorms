// ============================================================================
// BloodNorms | dashboard_cockpit_view.dart
// Executive Operations Dashboard & KPI Cards Overview
// ============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/models/blood_bank_model.dart';
import '../../../shared/models/camp_model.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.radar_rounded, color: BrandColors.red),
                      SizedBox(width: 8),
                      Text(
                        'Active Live Emergencies (Rajahmundry Pilot Area)',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: onOpenRadar,
                    child: const Text(
                      'Open Radar',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontWeight: FontWeight.bold,
                        color: BrandColors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (liveRequests.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No active emergencies. Standing by.',
                      style: TextStyle(color: BrandColors.textSecondary),
                    ),
                  ),
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: BrandColors.red,
                    borderRadius: BorderRadius.circular(6)),
                child: Text(
                  bg,
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$hosp · $units Units',
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: BrandColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Search Ring: ${ringKm.toStringAsFixed(1)} km · Phone: $phone',
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 11,
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
                  icon: const Icon(Icons.phone_rounded,
                      size: 18, color: BrandColors.green),
                  onPressed: () async {
                    final uri =
                        Uri.parse('tel:${phone.replaceAll(' ', '')}');
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  },
                ),
              IconButton(
                icon: const Icon(Icons.zoom_out_map_rounded,
                    size: 18, color: BrandColors.red),
                tooltip: 'Widen Search Ring (+2km)',
                onPressed: () => onWidenRequest(id, ringKm),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle_outline_rounded,
                    size: 18, color: BrandColors.green),
                tooltip: 'Resolve Crisis',
                onPressed: () => onCloseRequest(id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
