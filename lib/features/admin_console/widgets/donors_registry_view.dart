// ============================================================================
// BloodNorms | donors_registry_view.dart
// Donors Directory DataTable & Location Preferences
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class DonorsRegistryView extends StatefulWidget {
  final String subPage; // 'donors_list' | 'donors_location'
  final List<Map<String, dynamic>> donorsList;
  final void Function(String donorId, String currentState) onToggleDonorPause;
  final void Function(String message) onShowToast;

  const DonorsRegistryView({
    super.key,
    required this.subPage,
    required this.donorsList,
    required this.onToggleDonorPause,
    required this.onShowToast,
  });

  @override
  State<DonorsRegistryView> createState() => _DonorsRegistryViewState();
}

class _DonorsRegistryViewState extends State<DonorsRegistryView> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.subPage == 'donors_location') {
      return _buildDonorsLocationPage();
    }
    return _buildDonorsListPage();
  }

  Widget _buildDonorsListPage() {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = widget.donorsList.where((d) {
      final name = (d['full_name'] ?? d['first_name'] ?? '').toString().toLowerCase();
      final bg = (d['blood_group'] ?? '').toString().toLowerCase();
      final matchesQuery = name.contains(query) || bg.contains(query);
      if (_activeFilter == 'All') return matchesQuery;
      if (_activeFilter == 'Active') return matchesQuery && d['state'] == 'active';
      if (_activeFilter == 'Paused') return matchesQuery && d['state'] != 'active';
      return matchesQuery;
    }).toList();

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: ['All', 'Active', 'Paused'].map((tab) {
                    final isSel = _activeFilter == tab;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(tab),
                        selected: isSel,
                        onSelected: (_) => setState(() => _activeFilter = tab),
                      ),
                    );
                  }).toList(),
                ),
                Text('${filtered.length} Donors Registered', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, color: BrandColors.textSecondary)),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columns: const [
                DataColumn(label: Text('DONOR DETAILS', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('BLOOD GROUP', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('ZONE / RADIUS', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('SUPERHERO ACTIONS', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
              ],
              rows: filtered.map((d) {
                final id = d['id']?.toString() ?? '';
                final name = d['full_name'] ?? d['first_name'] ?? 'Donor Hero';
                final phone = d['phone'] ?? '+91 98765 43210';
                final bg = d['blood_group'] ?? 'O+';
                final state = (d['state'] ?? 'active').toString().toLowerCase();
                final city = d['city'] ?? 'Rajahmundry';
                final radius = d['travel_radius_km'] ?? 15;

                return DataRow(
                  cells: [
                    DataCell(Row(
                      children: [
                        CircleAvatar(radius: 14, backgroundColor: BrandColors.redTint, child: Text(name[0], style: const TextStyle(color: BrandColors.red, fontWeight: FontWeight.bold))),
                        const SizedBox(width: 8),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(name, style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(phone, style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 11, color: BrandColors.textSecondary)),
                        ]),
                      ],
                    )),
                    DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: BrandColors.redTint, borderRadius: BorderRadius.circular(6)), child: Text(bg, style: const TextStyle(color: BrandColors.red, fontWeight: FontWeight.bold)))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: state == 'active' ? BrandColors.greenTint : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(999)),
                      child: Text(state.toUpperCase(), style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, color: state == 'active' ? BrandColors.green : BrandColors.textSecondary, fontSize: 10)),
                    )),
                    DataCell(Text('$city (${radius}km)')),
                    DataCell(Row(
                      children: [
                        TextButton(
                          onPressed: () => widget.onToggleDonorPause(id, state),
                          child: Text(state == 'active' ? 'PAUSE' : 'ACTIVATE', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, color: state == 'active' ? BrandColors.red : BrandColors.green, fontSize: 11)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.star_outline_rounded, color: Color(0xFFF59E0B), size: 18),
                          tooltip: 'Award Milestone Badge',
                          onPressed: () async {
                            await SupabaseService().awardDonorBadge(donorId: id, badgeCode: 'silver_lifesaver', badgeName: 'Silver Lifesaver', description: 'Awarded by Super Admin');
                            widget.onShowToast('Silver Lifesaver Badge awarded to $name!');
                          },
                        ),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorsLocationPage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Donor Regional Distribution & Travel Preferences', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 12),
          Text('• Rajahmundry (Primary Pilot): 340 Donors (Average travel radius: 12.4 km)\n• Kakinada (Extended Zone): 85 Donors\n• Visakhapatnam: 15 Donors\n• Vijayawada: 10 Donors\n• Currently Out of Station / Away: 12 Donors (Auto-suppressed from broadcasts)'),
        ],
      ),
    );
  }
}
