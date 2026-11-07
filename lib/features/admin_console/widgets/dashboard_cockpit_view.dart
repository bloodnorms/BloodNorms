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
        _buildCockpitKPIs(),
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

  Widget _buildCockpitKPIs() {
    final activeCrises = liveRequests.where((r) => r['status'] == 'searching').length;
    final totalStock = banksList.fold<int>(0, (sum, b) => sum + b.stockUnits);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildKPICard('Active Donors', '${donorsList.length}', '+8.4% vs yesterday', Icons.people_rounded, const Color(0xFF6366F1), const [Color(0xFFEEF2FF), Color(0xFFE0E7FF)]),
          const SizedBox(width: 12),
          _buildKPICard('Active Crises', '$activeCrises', 'Realtime Radar', Icons.radar_rounded, BrandColors.red, const [Color(0xFFFEF2F2), Color(0xFFFEE2E2)]),
          const SizedBox(width: 12),
          _buildKPICard('Blood Centers', '${banksList.length}', 'Pilot Active', Icons.local_hospital_rounded, const Color(0xFF0EA5E9), const [Color(0xFFECFEFF), Color(0xFFCFFAFE)]),
          const SizedBox(width: 12),
          _buildKPICard('Units in Stock', '$totalStock', '8 Groups Total', Icons.inventory_2_rounded, const Color(0xFF10B981), const [Color(0xFFECFDF5), Color(0xFFD1FAE5)]),
          const SizedBox(width: 12),
          _buildKPICard('Camps Scheduled', '${campsList.length}', '+12.3% this month', Icons.event_available_rounded, const Color(0xFFF59E0B), const [Color(0xFFFFFBEB), Color(0xFFFEF3C7)]),
          const SizedBox(width: 12),
          _buildKPICard('Telecom Spend', '₹${dailySpend['total_cost_inr'] ?? 482}', 'Auto-budgeted', Icons.currency_rupee_rounded, const Color(0xFFD946EF), const [Color(0xFFFDF4FF), Color(0xFFFAE8FF)]),
        ],
      ),
    );
  }

  Widget _buildKPICard(String title, String value, String trend, IconData icon, Color color, List<Color> gradient) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 16, color: color)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)), child: Text(trend, style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 9, fontWeight: FontWeight.bold, color: color))),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 11, color: BrandColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 22, fontWeight: FontWeight.bold, color: BrandColors.textPrimary)),
        ],
      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: BrandColors.red, borderRadius: BorderRadius.circular(6)),
                child: Text(bg, style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$hosp · $units Units', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13, color: BrandColors.textPrimary)),
                  Text('Search Ring: ${ringKm.toStringAsFixed(1)} km · Phone: $phone', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 11, color: BrandColors.textSecondary)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              if (phone.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.phone_rounded, size: 18, color: BrandColors.green),
                  onPressed: () async {
                    final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  },
                ),
              IconButton(
                icon: const Icon(Icons.zoom_out_map_rounded, size: 18, color: BrandColors.red),
                tooltip: 'Widen Search Ring (+2km)',
                onPressed: () => onWidenRequest(id, ringKm),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18, color: BrandColors.green),
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
