// ============================================================================
// BloodNorms | schedule_camp_dialog.dart
// Schedule Blood Drive Dialog for Blood Bank Console
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

void showScheduleCampDialog({
  required BuildContext context,
  required String selectedBankId,
  required VoidCallback onCampUpdated,
  required void Function(String message) onShowToast,
}) {
  final titleCtrl = TextEditingController(text: 'Community Voluntary Blood Drive');
  final venueCtrl = TextEditingController(text: 'Community Hall, Main Road');
  final areaCtrl = TextEditingController(text: 'Danavaipeta');
  String selectedCity = 'Rajahmundry';
  int capacity = 100;
  double radiusKm = 10.0;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BrandColors.redTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_location_alt_rounded,
                  color: BrandColors.red, size: 22),
            ),
            const SizedBox(width: 10),
            Text('Schedule Blood Drive',
                style: BrandTypography.title3(color: BrandColors.textPrimary)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                    labelText: 'Camp Title', border: OutlineInputBorder()),
                style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: venueCtrl,
                decoration: const InputDecoration(
                    labelText: 'Venue / Hall Name', border: OutlineInputBorder()),
                style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedCity,
                      decoration: const InputDecoration(
                          labelText: 'City', border: OutlineInputBorder()),
                      items: ['Rajahmundry', 'Kakinada', 'Vijayawada', 'Visakhapatnam']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) =>
                          setDialogState(() => selectedCity = v ?? 'Rajahmundry'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: areaCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Locality / Area', border: OutlineInputBorder()),
                      style: const TextStyle(
                          fontFamily: BrandTypography.fontFamily, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: capacity,
                      decoration: const InputDecoration(
                          labelText: 'Target Capacity', border: OutlineInputBorder()),
                      items: [50, 100, 150, 200, 300, 500]
                          .map((c) => DropdownMenuItem(value: c, child: Text('$c Units')))
                          .toList(),
                      onChanged: (v) => setDialogState(() => capacity = v ?? 100),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<double>(
                      initialValue: radiusKm,
                      decoration: const InputDecoration(
                          labelText: 'Target Radius', border: OutlineInputBorder()),
                      items: [5.0, 10.0, 15.0, 25.0]
                          .map((r) => DropdownMenuItem(
                              value: r, child: Text('${r.toInt()} KM')))
                          .toList(),
                      onChanged: (v) => setDialogState(() => radiusKm = v ?? 10.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL',
                style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    color: BrandColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final startsAt =
                  DateTime.now().add(const Duration(days: 3, hours: 9));
              final endsAt = startsAt.add(const Duration(hours: 6));

              await SupabaseService().createCamp(
                bankId: selectedBankId,
                title: titleCtrl.text.trim(),
                venue: venueCtrl.text.trim(),
                area: areaCtrl.text.trim(),
                city: selectedCity,
                startsAt: startsAt,
                endsAt: endsAt,
                capacity: capacity,
                targetRadiusKm: radiusKm,
              );

              onCampUpdated();
              onShowToast('Blood drive scheduled in $selectedCity!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: BrandColors.red),
            child: const Text('SCHEDULE DRIVE',
                style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}
