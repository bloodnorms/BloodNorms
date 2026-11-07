// ============================================================================
// BloodNorms | live_tracking_map_view.dart
// Interactive OpenStreetMap showing expanding search wave radius and donor pins
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

  const LiveTrackingMapView({
    super.key,
    required this.mapController,
    required this.centerPoint,
    required this.currentRingKm,
    required this.donors,
    required this.onCallDonor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BrandColors.border, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: BrandColors.border,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: centerPoint,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.arkiolabs.bloodnorms',
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: centerPoint,
                    radius: currentRingKm * 1000,
                    useRadiusInMeter: true,
                    color: BrandColors.red.withValues(alpha: 0.12),
                    borderColor: BrandColors.red,
                    borderStrokeWidth: 2.5,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // Hospital Pin
                  Marker(
                    point: centerPoint,
                    width: 48,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        color: BrandColors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: BrandColors.redShadow,
                            offset: Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.local_hospital_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                  // Dynamic Donor Pins from Supabase
                  ...donors.map((d) {
                    final isAccepted = d.status == 'accepted';
                    return Marker(
                      point: LatLng(d.lat, d.lng),
                      width: 42,
                      height: 42,
                      child: GestureDetector(
                        onTap: () => onCallDonor(d),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isAccepted ? BrandColors.green : BrandColors.redTint,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isAccepted ? Colors.white : BrandColors.red,
                              width: 2.0,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: BrandColors.border,
                                offset: Offset(0, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              d.firstName.isNotEmpty ? d.firstName[0].toUpperCase() : 'D',
                              style: TextStyle(
                                fontFamily: BrandTypography.fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isAccepted ? Colors.white : BrandColors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: BrandColors.border, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.radar_rounded, size: 14, color: BrandColors.red),
                  const SizedBox(width: 4),
                  Text(
                    'WAVE RING: ${currentRingKm.toStringAsFixed(1)} KM',
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

