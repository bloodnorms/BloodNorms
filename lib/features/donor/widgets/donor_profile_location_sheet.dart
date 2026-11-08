// ============================================================================
// BloodNorms | donor_profile_location_sheet.dart
// Location & alert preference configuration sheet for donor profile
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
import 'out_of_station_switch_card.dart';

void showDonorProfileLocationSheet({
  required BuildContext context,
  required String donorId,
  required String currentCity,
  required String currentArea,
  required double currentRadiusKm,
  required bool currentIsAway,
  required void Function({
    required String city,
    required String area,
    required double travelRadiusKm,
    required bool isAway,
  }) onSaved,
}) {
  String tempCity = currentCity;
  final areaController = TextEditingController(text: currentArea);
  double tempRadius = currentRadiusKm;
  bool tempAway = currentIsAway;

  final supportedCities = [
    'Rajahmundry',
    'Kakinada',
    'Visakhapatnam',
    'Vijayawada',
    'Guntur',
    'Eluru',
    'Amalapuram',
    'Mandapeta',
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: BrandColors.redTint, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.location_on_rounded, color: BrandColors.red, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Text('Location & Alert Preferences', style: BrandTypography.title2(color: BrandColors.textPrimary)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Set your primary city, neighborhood, and maximum travel radius. Localized blood camp broadcasts strictly respect these settings.',
                style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, color: BrandColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // City Selector
              Text('Registered City / District', style: BrandTypography.fieldLabel(color: BrandColors.textPrimary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: supportedCities.map((city) {
                  final isSel = tempCity.toLowerCase() == city.toLowerCase();
                  return ChoiceChip(
                    label: Text(
                      city,
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        color: isSel ? Colors.white : BrandColors.textPrimary,
                      ),
                    ),
                    selected: isSel,
                    selectedColor: BrandColors.red,
                    backgroundColor: BrandColors.bgGrouped,
                    onSelected: (_) => setSheetState(() => tempCity = city),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Area / Locality
              Text('Area / Neighborhood', style: BrandTypography.fieldLabel(color: BrandColors.textPrimary)),
              const SizedBox(height: 6),
              TextField(
                controller: areaController,
                decoration: InputDecoration(
                  hintText: 'e.g. Danavaipeta, Kotipalli, Morampudi',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Max Willing Travel Radius
              Text('Maximum Travel Radius', style: BrandTypography.fieldLabel(color: BrandColors.textPrimary)),
              const SizedBox(height: 4),
              const Text(
                'You will NOT receive alerts for drives beyond this distance.',
                style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 11, color: BrandColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [3.0, 5.0, 10.0, 15.0, 25.0, 50.0].map((r) {
                  final isSel = tempRadius == r;
                  return ChoiceChip(
                    label: Text('${r.toInt()} km', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                    selected: isSel,
                    selectedColor: BrandColors.redTint,
                    onSelected: (_) => setSheetState(() => tempRadius = r),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Out of station switch
              OutOfStationSwitchCard(
                isAway: tempAway,
                onChanged: (v) => setSheetState(() => tempAway = v),
              ),
              const SizedBox(height: 20),

              ActionButton(
                label: 'SAVE PREFERENCES',
                variant: ActionButtonVariant.success,
                height: 44,
                onPressed: () async {
                  final finalArea = areaController.text.trim().isEmpty ? 'Danavaipeta' : areaController.text.trim();
                  await SupabaseService().updateDonorLocationPreferences(
                    donorId: donorId,
                    city: tempCity,
                    area: finalArea,
                    travelRadiusKm: tempRadius,
                    isAway: tempAway,
                  );
                  onSaved(
                    city: tempCity,
                    area: finalArea,
                    travelRadiusKm: tempRadius,
                    isAway: tempAway,
                  );
                  if (ctx.mounted && Navigator.canPop(ctx)) {
                    Navigator.pop(ctx);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Location & regional alert preferences updated!'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

