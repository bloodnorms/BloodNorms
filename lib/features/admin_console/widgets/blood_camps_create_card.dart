// ============================================================================
// BloodNorms | blood_camps_create_card.dart
// Schedule voluntary blood drive camp creation form card
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/models/blood_bank_model.dart';
import '../../../shared/models/camp_model.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';

class BloodCampsCreateCard extends StatefulWidget {
  final List<BloodBankModel> banksList;
  final void Function(CampModel newCamp) onCampCreated;
  final void Function(String message) onShowToast;

  const BloodCampsCreateCard({
    super.key,
    required this.banksList,
    required this.onCampCreated,
    required this.onShowToast,
  });

  @override
  State<BloodCampsCreateCard> createState() => _BloodCampsCreateCardState();
}

class _BloodCampsCreateCardState extends State<BloodCampsCreateCard> {
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

