// ============================================================================
// BloodNorms | blood_camps_admin_view.dart
// Blood Camps Admin Roster & Drive Scheduling
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/models/camp_model.dart';
import '../../../shared/models/blood_bank_model.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Scheduled Blood Drives', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 15)),
              ElevatedButton.icon(
                onPressed: widget.onNavigateToCreate,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('New Drive'),
                style: ElevatedButton.styleFrom(backgroundColor: BrandColors.red, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...widget.campsList.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.title, style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('${c.venue} · ${c.area}, ${c.city} · Target Radius: ${c.targetRadiusKm}km · Capacity: ${c.capacity} donors', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, color: BrandColors.textSecondary)),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: () => widget.onCampSelectedForBroadcast(c),
                      icon: const Icon(Icons.campaign_rounded, size: 14, color: BrandColors.red),
                      label: const Text('Broadcast', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, color: BrandColors.red)),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Schedule Voluntary Blood Drive Camp', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Camp Drive Title', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _venueController, decoration: const InputDecoration(labelText: 'Venue / Hall Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _areaController, decoration: const InputDecoration(labelText: 'Area / Neighborhood', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _cityController, decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _capacityController, decoration: const InputDecoration(labelText: 'Donor Capacity Target', border: OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          ElevatedButton(
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
            style: ElevatedButton.styleFrom(backgroundColor: BrandColors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            child: const Text('Publish Drive Now'),
          ),
        ],
      ),
    );
  }
}
