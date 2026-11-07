// ============================================================================
// BloodNorms | donors_registry_view.dart
// Modern Minimal Donors Directory DataTable & Location Preferences
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';
import '../../../shared/widgets/app_search_field.dart';

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
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
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
                      child: GestureDetector(
                        onTap: () => setState(() => _activeFilter = tab),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSel ? BrandColors.primaryAction : BrandColors.surfaceSoft,
                            borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                            border: Border.all(
                              color: isSel ? BrandColors.primaryAction : BrandColors.borderSubtle,
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            tab,
                            style: TextStyle(
                              fontFamily: BrandTypography.fontFamily,
                              fontSize: 12,
                              fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                              color: isSel ? Colors.white : BrandColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Text(
                  '${filtered.length} donors registered',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 12,
                    color: BrandColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppSearchField(
              hintText: 'Search donors by name or blood group...',
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: BrandColors.borderSubtle),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(BrandColors.surfaceSoft),
              columns: const [
                DataColumn(label: Text('DONOR DETAILS', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.w600, fontSize: 12))),
                DataColumn(label: Text('BLOOD GROUP', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.w600, fontSize: 12))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.w600, fontSize: 12))),
                DataColumn(label: Text('ZONE / RADIUS', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.w600, fontSize: 12))),
                DataColumn(label: Text('ACTIONS', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.w600, fontSize: 12))),
              ],
              rows: filtered.map((d) {
                final id = d['id']?.toString() ?? '';
                final name = d['full_name'] ?? d['first_name'] ?? 'Donor';
                final phone = d['phone'] ?? '';
                final bg = d['blood_group'] ?? 'O+';
                final state = d['state'] ?? 'active';
                final isPaused = state != 'active';
                final radius = d['travel_radius_km'] ?? 10;
                final city = d['city'] ?? 'Rajahmundry';

                return DataRow(cells: [
                  DataCell(Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(phone, style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 11, color: BrandColors.textSecondary)),
                    ],
                  )),
                  DataCell(Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: BrandColors.accentTint,
                      borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                    ),
                    child: Text(bg, style: const TextStyle(color: BrandColors.accent, fontWeight: FontWeight.w600, fontSize: 11)),
                  )),
                  DataCell(Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isPaused ? BrandColors.statusWarningTint : BrandColors.statusSuccessTint,
                      borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                    ),
                    child: Text(
                      isPaused ? 'Paused' : 'Active',
                      style: TextStyle(
                        color: isPaused ? BrandColors.statusWarning : BrandColors.statusSuccess,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  )),
                  DataCell(Text('$city ($radius km)', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12))),
                  DataCell(AppPillButton(
                    label: isPaused ? 'Resume' : 'Pause',
                    variant: isPaused ? AppPillButtonVariant.primary : AppPillButtonVariant.secondary,
                    onPressed: () => widget.onToggleDonorPause(id, state),
                  )),
                ]);
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
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Donor regional distribution & travel preferences',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildLocationItem('Rajahmundry (Primary Pilot)', '340 donors · Average travel radius: 12.4 km'),
          _buildLocationItem('Kakinada (Extended Zone)', '85 donors'),
          _buildLocationItem('Visakhapatnam', '15 donors'),
          _buildLocationItem('Vijayawada', '10 donors'),
          _buildLocationItem('Currently out of station / away', '12 donors (Auto-suppressed from broadcasts)', isWarning: true),
        ],
      ),
    );
  }

  Widget _buildLocationItem(String title, String subtitle, {bool isWarning = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
                title,
                style: const TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: BrandColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontSize: 12,
                  color: BrandColors.textSecondary,
                ),
              ),
            ],
          ),
          if (isWarning)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: BrandColors.statusWarningTint,
                borderRadius: BorderRadius.circular(BrandColors.radiusPill),
              ),
              child: const Text(
                'Auto-suppressed',
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  color: BrandColors.statusWarning,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
