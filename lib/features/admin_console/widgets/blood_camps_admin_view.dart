// ============================================================================
// BloodNorms | blood_camps_admin_view.dart
// Modern Minimal Blood Camps Admin Roster & Drive Scheduling
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';

class BloodCampsAdminView extends StatefulWidget {
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
  State<BloodCampsAdminView> createState() => _BloodCampsAdminViewState();
}

class _BloodCampsAdminViewState extends State<BloodCampsAdminView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _cityController = TextEditingController(text: 'Rajahmundry');
  final TextEditingController _capacityController = TextEditingController(text: '100');

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.subPage == 'camps_create') {
      return _buildCampsCreatePage();
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
                onPressed: widget.onNavigateToCreate,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.campsList.map((c) => Container(
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
                      onPressed: () => widget.onCampSelectedForBroadcast(c),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCampsCreatePage() {
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
            'Schedule voluntary blood drive camp',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Camp title')),
          const SizedBox(height: 12),
          TextField(controller: _venueController, decoration: const InputDecoration(labelText: 'Venue / Hall name')),
          const SizedBox(height: 12),
          TextField(controller: _areaController, decoration: const InputDecoration(labelText: 'Area / Neighborhood')),
          const SizedBox(height: 12),
          TextField(controller: _cityController, decoration: const InputDecoration(labelText: 'City')),
          const SizedBox(height: 12),
          TextField(controller: _capacityController, decoration: const InputDecoration(labelText: 'Target donor capacity'), keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          AppPillButton(
            label: 'Publish drive now',
            icon: Icons.check_circle_outline_rounded,
            variant: AppPillButtonVariant.primary,
            onPressed: () async {
              if (_titleController.text.isNotEmpty && _venueController.text.isNotEmpty) {
                final newCamp = CampModel(
                  id: 'camp-${DateTime.now().millisecondsSinceEpoch}',
                  bankId: widget.banksList.isNotEmpty ? widget.banksList.first.id : 'bank-01',
                  title: _titleController.text.trim(),
                  venue: _venueController.text.trim(),
                  area: _areaController.text.trim().isEmpty ? 'Central' : _areaController.text.trim(),
                  city: _cityController.text.trim(),
                  startsAt: DateTime.now().add(const Duration(days: 3)),
                  endsAt: DateTime.now().add(const Duration(days: 3, hours: 6)),
                  capacity: int.tryParse(_capacityController.text.trim()) ?? 100,
                  status: 'published',
                  lat: 17.0005,
                  lng: 81.7820,
                  targetRadiusKm: 10.0,
                );

                await SupabaseService().createCamp(
                  title: newCamp.title,
                  venue: newCamp.venue,
                  area: newCamp.area,
                  city: newCamp.city,
                  startsAt: newCamp.startsAt,
                  endsAt: newCamp.endsAt,
                  capacity: newCamp.capacity,
                );

                widget.onCampCreated(newCamp);
                widget.onShowToast('Blood camp drive successfully scheduled and published!');
              }
            },
          ),
        ],
      ),
    );
  }
}
