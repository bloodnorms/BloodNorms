// ============================================================================
// BloodNorms | broadcast_audience_view.dart
// Regional Broadcast Audience Geofence & Breakdown View
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class BroadcastAudienceView extends StatelessWidget {
  final Map<String, dynamic> audiencePreview;

  const BroadcastAudienceView({
    super.key,
    required this.audiencePreview,
  });

  @override
  Widget build(BuildContext context) {
    final samples = (audiencePreview['sample_donors'] as List<dynamic>?) ?? [];
    final suppressedList =
        (audiencePreview['suppressed_sample'] as List<dynamic>?) ?? [];
    final areaBreakdown =
        (audiencePreview['area_breakdown'] as Map<String, dynamic>?) ?? {};

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'In-Radius Eligible Donors',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...samples.map((s) => ListTile(
                dense: true,
                leading: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: BrandColors.redTint,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    s['blood_group'] ?? 'O+',
                    style: const TextStyle(
                      color: BrandColors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                title: Text(
                  s['name'] ?? 'Donor',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${s['distance_km']} km away · ${s['area']}, ${s['city']}',
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: BrandColors.greenTint,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ELIGIBLE',
                    style: TextStyle(
                      color: BrandColors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              )),
          const Divider(),
          const Text(
            'Suppressed Donors (Out of Target Radius / Away)',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: BrandColors.red,
            ),
          ),
          const SizedBox(height: 8),
          ...suppressedList.map((s) => ListTile(
                dense: true,
                leading: const Icon(
                  Icons.block_rounded,
                  color: BrandColors.red,
                  size: 18,
                ),
                title: Text(
                  s['name'] ?? 'Donor',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('${s['reason']} (${s['distance_km']} km away)'),
              )),
          if (areaBreakdown.isNotEmpty) ...[
            const Divider(),
            const Text(
              'Area / Neighborhood Breakdown',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ...areaBreakdown.entries.map((e) => ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFF0D9488),
                    size: 18,
                  ),
                  title: Text(
                    e.key.toString(),
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Text(
                    '${e.value} donors in radius',
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
