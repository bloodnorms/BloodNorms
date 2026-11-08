// ============================================================================
// BloodNorms | banks_map_widget.dart
// Interactive OpenStreetMap widget showing user location and nearby blood banks
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../shared/models/blood_bank_model.dart';
import '../../../shared/services/location_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class BanksMapWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng userPoint;
  final List<BloodBankModel> banks;
  final int? selectedBankIndex;
  final ValueChanged<int> onBankSelected;

  const BanksMapWidget({
    super.key,
    required this.mapController,
    required this.userPoint,
    required this.banks,
    required this.selectedBankIndex,
    required this.onBankSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: userPoint,
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: LocationService.osmTileUrl,
                userAgentPackageName: 'com.arkiolabs.bloodnorms',
              ),
              MarkerLayer(
                markers: [
                  // User location marker
                  Marker(
                    point: userPoint,
                    width: 36,
                    height: 36,
                    child: Container(
                      decoration: BoxDecoration(
                        color: BrandColors.statusErrorTint,
                        shape: BoxShape.circle,
                        border: Border.all(color: BrandColors.statusError, width: 2.0),
                      ),
                      child: const Icon(
                        Icons.my_location_rounded,
                        size: 18,
                        color: BrandColors.statusError,
                      ),
                    ),
                  ),
                  // Bank markers
                  ...banks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final b = entry.value;
                    final isSel = selectedBankIndex == index;

                    return Marker(
                      point: LatLng(b.lat, b.lng),
                      width: 44,
                      height: 44,
                      child: GestureDetector(
                        onTap: () {
                          onBankSelected(index);
                          mapController.move(LatLng(b.lat, b.lng), 14.0);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSel ? BrandColors.primaryAction : BrandColors.background,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSel ? BrandColors.primaryAction : BrandColors.borderSubtle,
                              width: 1.5,
                            ),
                            boxShadow: BrandColors.shadowCardHover,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.local_hospital_rounded,
                              size: 20,
                              color: isSel ? Colors.white : BrandColors.statusError,
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
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: BrandColors.background,
                borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                boxShadow: BrandColors.shadowCardHover,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.touch_app_outlined, size: 13, color: BrandColors.textSecondary),
                  SizedBox(width: 4),
                  Text(
                    'Interactive map',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: BrandColors.textSecondary,
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
