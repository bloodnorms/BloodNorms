// ============================================================================
// BloodNorms | camp_checkin_sheet.dart
// Live Camp Donor QR & Mobile Check-In Sheet for Bank Console
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';

void showCampCheckInSheet({
  required BuildContext context,
  required CampModel camp,
  required VoidCallback onCampUpdated,
  required void Function(String message) onShowToast,
}) {
  final phoneController = TextEditingController(text: '+91 98480 12345');
  int unitsDonated = 1;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Camp Donor Check-In',
                    style: BrandTypography.title2(color: BrandColors.textPrimary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: BrandColors.greenTint,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: BrandColors.greenShadow, width: 1.0),
                  ),
                  child: const Text('LIVE DRIVE',
                      style: TextStyle(
                          color: BrandColors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(camp.title,
                style: BrandTypography.caption(color: BrandColors.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Donor Mobile Number / Pass Code',
                hintText: '+91 98480 12345',
                prefixIcon: const Icon(Icons.phone_iphone_rounded, color: BrandColors.red),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Units Collected:',
                    style: BrandTypography.headline(color: BrandColors.textPrimary)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded,
                          color: BrandColors.red),
                      onPressed: () {
                        if (unitsDonated > 1) {
                          setModalState(() => unitsDonated--);
                        }
                      },
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: BrandColors.redTint,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: BrandColors.redShadow, width: 1.0),
                      ),
                      child: Text(
                        '$unitsDonated Unit${unitsDonated > 1 ? "s" : ""}',
                        style: const TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontWeight: FontWeight.bold,
                          color: BrandColors.red,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded,
                          color: BrandColors.red),
                      onPressed: () {
                        setModalState(() => unitsDonated++);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ActionButton(
              label: 'VERIFY & CHECK-IN DONOR',
              icon: Icons.check_circle_rounded,
              variant: ActionButtonVariant.success,
              onPressed: () async {
                Navigator.pop(ctx);
                final phone = phoneController.text.trim();
                final res = await SupabaseService().checkInCampAttendee(
                  campId: camp.id,
                  phone: phone,
                  units: unitsDonated,
                );
                final donorName = res['first_name'] ?? 'Donor';
                final group = res['blood_group'] ?? 'Blood Group';
                onShowToast(
                    'Checked in $donorName ($group) · $unitsDonated units added!');
                onCampUpdated();
              },
            ),
            const SizedBox(height: 10),
            ActionButton(
              label: 'CANCEL',
              variant: ActionButtonVariant.plain,
              height: 44,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    ),
  );
}
