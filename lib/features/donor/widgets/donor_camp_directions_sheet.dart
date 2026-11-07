// ============================================================================
// BloodNorms | donor_camp_directions_sheet.dart
// Modal sheet showing distance and GPS directions to a donation camp
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';

void showDonorCampDirectionsSheet({
  required BuildContext context,
  required CampModel camp,
  required double distKm,
  required double donorTravelRadius,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: BrandColors.redTint, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.location_on_rounded, color: BrandColors.red, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(camp.venue, style: BrandTypography.title2(color: BrandColors.textPrimary)),
                    Text('${camp.area}, ${camp.city} (${camp.pincode})', style: BrandTypography.caption(color: BrandColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: BrandColors.bgGrouped,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: BrandColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Distance from your location:', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, color: BrandColors.textSecondary)),
                    Text('~${distKm.toStringAsFixed(1)} KM', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 13, fontWeight: FontWeight.bold, color: BrandColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Travel Zone Status:', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, color: BrandColors.textSecondary)),
                    Text(
                      distKm <= donorTravelRadius ? '✓ Within Your Travel Limit' : '⚠️ Outside Travel Limit',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: distKm <= donorTravelRadius ? BrandColors.green : const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
                if (camp.coordinatorName != null) ...[
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Camp Coordinator:', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, color: BrandColors.textSecondary)),
                      Text('${camp.coordinatorName} (${camp.coordinatorPhone ?? ""})', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.bold, color: BrandColors.textPrimary)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          ActionButton(
            label: 'OPEN NAVIGATION MAP',
            icon: Icons.map_rounded,
            variant: ActionButtonVariant.primary,
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening GPS route to ${camp.venue} (${camp.lat}, ${camp.lng})'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
