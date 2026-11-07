// ============================================================================
// BloodNorms | location_screen.dart
// Location selection screen — Thin Screen Composing Map & Landmark Picker
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/services/location_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/screen_header.dart';
import '../providers/request_flow_provider.dart';
import '../widgets/location_map_view.dart';
import '../widgets/location_search_header.dart';

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
        _placeLabel = 'Resolving GPS location...';
      });
      _mapController.move(point, 14.0);

      final resolved = await LocationService.reverseGeocode(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {
          _placeLabel = resolved ?? 'Current Location (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})';
        });
        globalRequestFlow.setLocation(
          lat: point.latitude,
          lng: point.longitude,
          label: _placeLabel,
        );
      }
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
      backgroundColor: BrandColors.bgGrouped,
      appBar: ScreenHeader(
        title: loc.t('loc.use'),
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            LocationSearchHeader(
              searchController: _searchController,
              hintText: loc.t('loc.search'),
              quickLocations: _quickLocations,
              onSearchSubmitted: _onSearchSubmitted,
              onSelectQuickLocation: _selectQuickLocation,
            ),
            Expanded(
              child: LocationMapView(
                mapController: _mapController,
                currentPoint: _currentPoint,
                isLoadingGps: _isLoadingGps,
                gpsButtonLabel: loc.t('loc.use'),
                onMapTap: (point) async {
                  setState(() {
                    _currentPoint = point;
                    _placeLabel = 'Resolving OpenStreetMap address...';
                  });
                  final resolved = await LocationService.reverseGeocode(point.latitude, point.longitude);
                  if (mounted) {
                    setState(() {
                      _placeLabel = resolved ?? 'Pinned: ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
                    });
                    globalRequestFlow.setLocation(
                      lat: point.latitude,
                      lng: point.longitude,
                      label: _placeLabel,
                    );
                  }
                },
                onUseMyLocation: _useMyLocation,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: BrandColors.border, width: 2.0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pin_drop_rounded, size: 20, color: BrandColors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _placeLabel,
                          style: TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: BrandColors.textPrimary,
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
                    child: ActionButton(
                      label: loc.t('cta.continue'),
                      variant: ActionButtonVariant.primary,
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
