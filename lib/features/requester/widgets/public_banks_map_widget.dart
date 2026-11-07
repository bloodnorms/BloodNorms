// ============================================================================
// BloodNorms | public_banks_map_widget.dart
// Interactive map widget showing public blood bank pins and city count pill
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/models/blood_bank_model.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class PublicBanksMapWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng cityPoint;
  final List<BloodBankModel> banks;
  final int? selectedBankIndex;
  final ValueChanged<int> onBankSelected;

  const PublicBanksMapWidget({
    super.key,
    required this.mapController,
    required this.cityPoint,
    required this.banks,
    required this.selectedBankIndex,
    required this.onBankSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
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
              initialCenter: cityPoint,
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.arkiolabs.bloodnorms',
              ),
              MarkerLayer(
                markers: banks.asMap().entries.map((entry) {
                  final index = entry.key;
                  final b = entry.value;
                  final isSel = selectedBankIndex == index;

                  return Marker(
                    point: LatLng(b.lat, b.lng),
                    width: 48,
                    height: 48,
                    child: GestureDetector(
                      onTap: () {
                        onBankSelected(index);
                        mapController.move(LatLng(b.lat, b.lng), 14.0);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSel ? BrandColors.red : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSel ? BrandColors.redShadow : BrandColors.red,
                            width: 2.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: BrandColors.border,
                              offset: Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.local_hospital_rounded,
                            size: 24,
                            color: isSel ? Colors.white : BrandColors.red,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Positioned(
            top: 10,
            right: 10,
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
                  const Icon(Icons.pin_drop_rounded, size: 14, color: BrandColors.red),
                  const SizedBox(width: 4),
                  Text(
                    '${banks.length} Banks in ${AppConstants.pilotCity}',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.textPrimary,
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
