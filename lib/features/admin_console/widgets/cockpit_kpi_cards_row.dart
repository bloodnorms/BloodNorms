// ============================================================================
// BloodNorms | cockpit_kpi_cards_row.dart
// Executive Operations Dashboard KPI Metric Cards Horizontal Row
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/models/blood_bank_model.dart';
import '../../../shared/models/camp_model.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class CockpitKPICardsRow extends StatelessWidget {
  final List<Map<String, dynamic>> liveRequests;
  final List<BloodBankModel> banksList;
  final List<Map<String, dynamic>> donorsList;
  final List<CampModel> campsList;
  final Map<String, dynamic> dailySpend;

  const CockpitKPICardsRow({
    super.key,
    required this.liveRequests,
    required this.banksList,
    required this.donorsList,
    required this.campsList,
    required this.dailySpend,
  });

  @override
  Widget build(BuildContext context) {
    final activeCrises =
        liveRequests.where((r) => r['status'] == 'searching').length;
    final totalStock =
        banksList.fold<int>(0, (sum, b) => sum + b.stockUnits);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildKPICard(
            'Active Donors',
            '${donorsList.length}',
            '+8.4% vs yesterday',
            Icons.people_rounded,
            const Color(0xFF6366F1),
            const [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
          ),
          const SizedBox(width: 12),
          _buildKPICard(
            'Active Crises',
            '$activeCrises',
            'Realtime Radar',
            Icons.radar_rounded,
            BrandColors.red,
            const [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
          ),
          const SizedBox(width: 12),
          _buildKPICard(
            'Blood Centers',
            '${banksList.length}',
            'Pilot Active',
            Icons.local_hospital_rounded,
            const Color(0xFF0EA5E9),
            const [Color(0xFFECFEFF), Color(0xFFCFFAFE)],
          ),
          const SizedBox(width: 12),
          _buildKPICard(
            'Units in Stock',
            '$totalStock',
            '8 Groups Total',
            Icons.inventory_2_rounded,
            const Color(0xFF10B981),
            const [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
          ),
          const SizedBox(width: 12),
          _buildKPICard(
            'Camps Scheduled',
            '${campsList.length}',
            '+12.3% this month',
            Icons.event_available_rounded,
            const Color(0xFFF59E0B),
            const [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
          ),
          const SizedBox(width: 12),
          _buildKPICard(
            'Telecom Spend',
            '₹${dailySpend['total_cost_inr'] ?? 482}',
            'Auto-budgeted',
            Icons.currency_rupee_rounded,
            const Color(0xFFD946EF),
            const [Color(0xFFFDF4FF), Color(0xFFFAE8FF)],
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(
    String title,
    String value,
    String trend,
    IconData icon,
    Color color,
    List<Color> gradient,
  ) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 11,
              color: BrandColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: BrandColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
