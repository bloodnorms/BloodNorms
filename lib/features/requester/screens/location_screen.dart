// ============================================================================
// BloodNorms | location_screen.dart
// Location selection screen — Duolingo Feather Red Style
// Interactive OpenStreetMap, 3D GPS button, landmark chips, Material
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/duo_colors.dart';
import '../../../core/theme/duo_typography.dart';
import '../../../core/widgets/duo_button.dart';
import '../../../core/widgets/duo_header_bar.dart';
import '../../../core/widgets/duo_text_field.dart';
import '../providers/request_flow_provider.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late final MapController _mapController;
  late LatLng _currentPoint;
  String _placeLabel = 'Rajahmundry, Andhra Pradesh';
  bool _isLoadingGps = false;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _quickLocations = [
    {'name': 'GGH Rajahmundry', 'lat': 16.9944, 'lng': 81.7774},
    {'name': 'Danavaipeta', 'lat': 17.0005, 'lng': 81.7820},
    {'name': 'Aryapuram', 'lat': 17.0120, 'lng': 81.7915},
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentPoint = LatLng(globalRequestFlow.state.lat, globalRequestFlow.state.lng);
    _placeLabel = globalRequestFlow.state.placeLabel;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _useMyLocation() async {
    setState(() => _isLoadingGps = true);
    final pos = await LocationService.getCurrentPosition();
    setState(() => _isLoadingGps = false);

    if (pos != null) {
      final point = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _currentPoint = point;
        _placeLabel = 'Current Location (${pos.latitude.toStringAsFixed(3)}, ${pos.longitude.toStringAsFixed(3)})';
      });
      _mapController.move(point, 14.0);
      globalRequestFlow.setLocation(
        lat: point.latitude,
        lng: point.longitude,
        label: _placeLabel,
      );
    }
  }

  void _selectQuickLocation(Map<String, dynamic> loc) {
    final point = LatLng(loc['lat'] as double, loc['lng'] as double);
    setState(() {
      _currentPoint = point;
      _placeLabel = '${loc['name']}, Rajahmundry';
    });
    _mapController.move(point, 14.0);
    globalRequestFlow.setLocation(
      lat: point.latitude,
      lng: point.longitude,
      label: _placeLabel,
    );
  }

  Future<void> _onSearchSubmitted(String query) async {
    if (query.trim().isEmpty) return;
    final results = await LocationService.searchPlace(query);
    if (results.isNotEmpty) {
      final best = results.first;
      final point = LatLng(best.lat, best.lng);
      setState(() {
        _currentPoint = point;
        _placeLabel = best.displayName;
      });
      _mapController.move(point, 14.0);
      globalRequestFlow.setLocation(
        lat: point.latitude,
        lng: point.longitude,
        label: _placeLabel,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: DuoHeaderBar(
        title: loc.t('loc.use'),
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search field & 3D chips in clean white container
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  DuoTextField(
                    controller: _searchController,
                    hintText: loc.t('loc.search'),
                    prefixIcon: Icons.search_rounded,
                    suffix: IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded, color: DuoColors.red),
                      onPressed: () => _onSearchSubmitted(_searchController.text),
                    ),
                    onChanged: (val) {
                      if (val.length > 3) {
                        _onSearchSubmitted(val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  // Quick landmark 3D chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _quickLocations.map((q) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => _selectQuickLocation(q),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: DuoColors.border, width: 2.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: DuoColors.border,
                                    offset: Offset(0, 2),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.near_me_rounded, size: 14, color: DuoColors.red),
                                  const SizedBox(width: 6),
                                  Text(
                                    q['name'],
                                    style: TextStyle(
                                      fontFamily: DuoTypography.fontFamily,
                                      color: DuoColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            // Map Container
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentPoint,
                      initialZoom: 13.0,
                      onTap: (_, point) {
                        setState(() {
                          _currentPoint = point;
                          _placeLabel = 'Pinned: ${point.latitude.toStringAsFixed(3)}, ${point.longitude.toStringAsFixed(3)}';
                        });
                        globalRequestFlow.setLocation(
                          lat: point.latitude,
                          lng: point.longitude,
                          label: _placeLabel,
                        );
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.arkiolabs.bloodnorms',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentPoint,
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.location_on_rounded,
                              size: 44,
                              color: DuoColors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Floating "My location" 3D button
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Center(
                      child: GestureDetector(
                        onTap: _isLoadingGps ? null : _useMyLocation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: DuoColors.redShadow, width: 2.0),
                            boxShadow: const [
                              BoxShadow(
                                color: DuoColors.redShadow,
                                offset: Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isLoadingGps)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: DuoColors.red),
                                )
                              else
                                const Icon(
                                  Icons.my_location_rounded,
                                  size: 18,
                                  color: DuoColors.red,
                                ),
                              const SizedBox(width: 8),
                              Text(
                                loc.t('loc.use').toUpperCase(),
                                style: TextStyle(
                                  fontFamily: DuoTypography.fontFamily,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: DuoColors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Selected Location Bar & Continue CTA
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: DuoColors.border, width: 2.0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pin_drop_rounded, size: 20, color: DuoColors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _placeLabel,
                          style: TextStyle(
                            fontFamily: DuoTypography.fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: DuoColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: DuoButton(
                      label: loc.t('cta.continue'),
                      variant: DuoButtonVariant.primary,
                      onPressed: () => context.push('/banks'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
