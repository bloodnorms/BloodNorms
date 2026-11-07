// ============================================================================
// BloodNorms | bank_broadcast_sheet.dart
// Regional Broadcast Outreach Sheet for Camp Drives in Bank Console
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/models/camp_model.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';

void showBankBroadcastSheet({
  required BuildContext context,
  required CampModel camp,
  required void Function(String message) onShowToast,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => FutureBuilder<Map<String, dynamic>>(
      future: SupabaseService().previewBroadcastAudience(
        campId: camp.id,
        targetCity: camp.city,
        centerLat: camp.lat,
        centerLng: camp.lng,
        radiusKm: camp.targetRadiusKm,
        respectTravelCap: true,
      ),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
                child: CircularProgressIndicator(color: BrandColors.red)),
          );
        }

        final data = snapshot.data!;
        final eligible = data['eligible_count'] as int? ?? 0;
        final suppressed = data['suppressed_count'] as int? ?? 0;
        final cost = data['estimated_cost_inr'] ?? 0.0;
        final samples = data['sample_donors'] as List? ?? [];

        return Padding(
          padding: const EdgeInsets.all(20),
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
                        decoration: BoxDecoration(
                            color: BrandColors.redTint,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.campaign_rounded,
                            color: BrandColors.red, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Regional Broadcast Outreach',
                              style: TextStyle(
                                  fontFamily: BrandTypography.fontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: BrandColors.textPrimary)),
                          Text('${camp.venue} (${camp.city})',
                              style: const TextStyle(
                                  fontFamily: BrandTypography.fontFamily,
                                  fontSize: 11,
                                  color: BrandColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$eligible Donors in ${camp.targetRadiusKm.toInt()} km Radius',
                            style: const TextStyle(
                                fontFamily: BrandTypography.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: BrandColors.green)),
                        const SizedBox(height: 2),
                        Text('Outreach spend: ₹$cost INR (WhatsApp template)',
                            style: const TextStyle(
                                fontFamily: BrandTypography.fontFamily,
                                fontSize: 11,
                                color: BrandColors.textSecondary)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text('$suppressed Out-of-Region Excluded',
                          style: const TextStyle(
                              fontFamily: BrandTypography.fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: BrandColors.red)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text('Nearby Matching Donors in City:',
                  style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.textPrimary)),
              const SizedBox(height: 8),
              ...samples.take(4).map((d) {
                final dMap = d as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: BrandColors.green, size: 14),
                      const SizedBox(width: 6),
                      Text(dMap['name']?.toString() ?? 'Donor',
                          style: const TextStyle(
                              fontFamily: BrandTypography.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 6),
                      Text(
                          '(${dMap['blood_group']}) · ~${dMap['distance_km']} km away',
                          style: const TextStyle(
                              fontFamily: BrandTypography.fontFamily,
                              fontSize: 11,
                              color: BrandColors.textSecondary)),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 18),
              ActionButton(
                label: 'DISPATCH REGIONAL BROADCAST',
                icon: Icons.send_rounded,
                variant: ActionButtonVariant.primary,
                height: 44,
                onPressed: () async {
                  Navigator.pop(ctx);
                  final res = await SupabaseService().broadcastRegionalMessage(
                    title: 'Blood Drive at ${camp.venue}',
                    message:
                        'Dear Lifesaver, our blood bank is hosting a voluntary blood drive at ${camp.venue}, ${camp.area}. We welcome your support!',
                    broadcastType: 'camp_invitation',
                    campId: camp.id,
                    targetCity: camp.city,
                    centerLat: camp.lat,
                    centerLng: camp.lng,
                    radiusKm: camp.targetRadiusKm,
                    respectTravelCap: true,
                  );
                  onShowToast(
                      'Broadcast dispatched to ${res["recipients"]} in-radius lifesavers!');
                },
              ),
            ],
          ),
        );
      },
    ),
  );
}
