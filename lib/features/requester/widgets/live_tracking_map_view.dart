// ============================================================================
// BloodNorms | live_tracking_map_view.dart
// Interactive Map matching pure reference with Hospital beacon & donor pins
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class LiveTrackingMapView extends StatelessWidget {
  final MapController mapController;
  final LatLng centerPoint;
  final double currentRingKm;
  final List<DonorCardModel> donors;
  final ValueChanged<DonorCardModel> onCallDonor;
  final int needUnits;

  const LiveTrackingMapView({
    super.key,
    required this.mapController,
    required this.centerPoint,
    required this.currentRingKm,
    required this.donors,
    required this.onCallDonor,
    this.needUnits = 2,
  });

  @override
  Widget build(BuildContext context) {
    final agreed = donors
        .where((d) => d.status == 'accepted' || d.status == 'on_the_way' || d.status == 'arrived')
        .toList();

    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: centerPoint,
              initialZoom: 13.8,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.arkiolabs.bloodnorms',
              ),
              MarkerLayer(
                markers: [
                  // Center Hospital / Requester Red Beacon with concentric halo
                  Marker(
                    point: centerPoint,
                    width: 32,
                    height: 32,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Donor markers
                  ...donors
                      .where((d) => d.latitude != null && d.longitude != null)
                      .map((d) {
                    final isAcc = d.status == 'accepted' || d.status == 'on_the_way';
                    return Marker(
                      point: LatLng(d.lat, d.lng),
                      width: 26,
                      height: 26,
                      child: GestureDetector(
                        onTap: () => onCallDonor(d),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isAcc ? const Color(0xFF4B4C55) : Colors.grey.shade400,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isAcc ? const Color(0xFF8E909D).withOpacity(0.4) : Colors.white,
                              width: isAcc ? 4.0 : 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
          // Floating Pill Callout matching reference screenshot
          if (agreed.isNotEmpty)
            Positioned(
              top: 14,
              left: 20,
              right: 20,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    agreed.length == 1
                        ? '${agreed.first.firstName} accepted your request'
                        : '${agreed.length} of $needUnits accepted',
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
              ),
            ),
          // Mapbox Watermark styling
          Positioned(
            bottom: 8,
            left: 10,
            child: Row(
              children: [
                Icon(Icons.near_me_rounded, size: 13, color: Colors.black.withOpacity(0.35)),
                const SizedBox(width: 3),
                Text(
                  'mapbox',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withOpacity(0.35),
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
          // Info circle button styling
          Positioned(
            bottom: 8,
            right: 10,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'i',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
