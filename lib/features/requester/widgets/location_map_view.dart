// ============================================================================
// BloodNorms | location_map_view.dart
// Interactive map layer for pinning location and triggering GPS auto-locate
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../shared/services/location_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class LocationMapView extends StatelessWidget {
  final MapController mapController;
  final LatLng currentPoint;
  final bool isLoadingGps;
  final String gpsButtonLabel;
  final ValueChanged<LatLng> onMapTap;
  final VoidCallback onUseMyLocation;

  const LocationMapView({
    super.key,
    required this.mapController,
    required this.currentPoint,
    required this.isLoadingGps,
    required this.gpsButtonLabel,
    required this.onMapTap,
    required this.onUseMyLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: currentPoint,
            initialZoom: 13.0,
            onTap: (_, point) => onMapTap(point),
          ),
          children: [
            TileLayer(
              urlTemplate: LocationService.osmTileUrl,
              userAgentPackageName: 'org.bloodnorms.emergency',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: currentPoint,
                  width: 50,
                  height: 50,
                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 44,
                    color: BrandColors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          left: 20,
          right: 20,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                onTap: isLoadingGps ? null : onUseMyLocation,
                child: Container(
                  constraints: const BoxConstraints(minHeight: BrandColors.minTouchTarget),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: BrandColors.background,
                    borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                    border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                    boxShadow: BrandColors.shadowFloating,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLoadingGps)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: BrandColors.statusError),
                        )
                      else
                        const Icon(
                          Icons.my_location_rounded,
                          size: 18,
                          color: BrandColors.statusError,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        gpsButtonLabel,
                        style: const TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: BrandColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

