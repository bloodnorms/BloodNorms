// ============================================================================
// BloodNorms | cockpit_kpi_cards_row.dart
// Modern Minimal Dashboard KPI Metric Cards Horizontal Row
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/models/blood_bank_model.dart';
import '../../../shared/models/camp_model.dart';
import '../../../shared/widgets/app_stat_card.dart';

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
    final spendAmount = dailySpend['total_cost_inr'] ?? 482;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          AppStatCard(
            label: 'Active donors',
            value: '${donorsList.length}',
            trendText: '+8.4% today',
            icon: Icons.people_outline_rounded,
          ),
          const SizedBox(width: 12),
          AppStatCard(
            label: 'Active crises',
            value: '$activeCrises',
            trendText: 'Live radar',
            icon: Icons.radar_rounded,
          ),
          const SizedBox(width: 12),
          AppStatCard(
            label: 'Blood centers',
            value: '${banksList.length}',
            trendText: 'Pilot active',
            icon: Icons.local_hospital_outlined,
          ),
          const SizedBox(width: 12),
          AppStatCard(
            label: 'Units in stock',
            value: '$totalStock',
            trendText: '8 blood groups',
            icon: Icons.inventory_2_outlined,
          ),
          const SizedBox(width: 12),
          AppStatCard(
            label: 'Drives scheduled',
            value: '${campsList.length}',
            trendText: '+12% this month',
            icon: Icons.event_available_outlined,
          ),
          const SizedBox(width: 12),
          AppStatCard(
            label: 'Telecom spend',
            value: '₹$spendAmount',
            trendText: 'Auto-capped',
            icon: Icons.currency_rupee_rounded,
          ),
        ],
      ),
    );
  }
}
