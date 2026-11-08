// ============================================================================
// BloodNorms | donor_camps_screen.dart
// Blood Donation Camps Screen — Thin Screen Composing DonorCampCard & Filter Header
// Dynamic city filtering, distance sorting, travel zone badges
// ============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/screen_header.dart';
import '../widgets/donor_camp_card.dart';
import '../widgets/donor_camp_directions_sheet.dart';
import '../widgets/donor_camps_city_sheet.dart';
import '../widgets/donor_camps_empty_card.dart';
import '../widgets/donor_camps_filter_header.dart';

class DonorCampsScreen extends StatefulWidget {
  const DonorCampsScreen({super.key});

  @override
  State<DonorCampsScreen> createState() => _DonorCampsScreenState();
}

class _DonorCampsScreenState extends State<DonorCampsScreen> {
  static const _cityCoords = {
    'kakinada': (16.9891, 82.2475),
    'visakhapatnam': (17.7042, 83.3032),
    'vijayawada': (16.5062, 80.6480),
    'guntur': (16.3067, 80.4365),
    'eluru': (16.7107, 81.0952),
    'rajahmundry': (17.0005, 81.7820),
  };

  static const _supportedCities = [
    'Rajahmundry', 'Kakinada', 'Visakhapatnam', 'Vijayawada',
    'Guntur', 'Eluru', 'Amalapuram', 'Mandapeta', 'All',
  ];

  final Set<String> _joinedCampIds = {};
  List<CampModel> _allCamps = [];
  bool _isLoading = true;
  String? _donorId;
  String _selectedCity = 'Rajahmundry';
  double _selectedRadiusKm = 25.0;
  double _donorLat = 17.0005;
  double _donorLng = 81.7820;
  double _donorTravelRadius = 15.0;
  bool _isAway = false;

  @override
  void initState() {
    super.initState();
    _loadDonorLocationAndCamps();
  }

  Future<void> _loadDonorLocationAndCamps() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    _donorId = prefs.getString('current_donor_id') ?? 'd1000000-0000-0000-0000-000000000001';

    final locPrefs = await SupabaseService().getDonorLocationPreferences(_donorId!);
    final cityPref = locPrefs['city']?.toString() ?? 'Rajahmundry';
    _resolveCityCoordinates(cityPref);

    final results = await SupabaseService().getCamps();
    final joined = _donorId != null && _donorId!.isNotEmpty
        ? await SupabaseService().getDonorJoinedCampIds(_donorId!)
        : <String>{};

    if (mounted) {
      setState(() {
        _allCamps = results;
        _selectedCity = cityPref;
        _donorTravelRadius = (locPrefs['travel_radius_km'] as num?)?.toDouble() ?? 15.0;
        _isAway = locPrefs['is_away'] == true;
        _joinedCampIds.clear();
        _joinedCampIds.addAll(joined);
        _isLoading = false;
      });
    }
  }

  void _resolveCityCoordinates(String city) {
    final coords = _cityCoords[city.toLowerCase()] ?? _cityCoords['rajahmundry']!;
    _donorLat = coords.$1;
    _donorLng = coords.$2;
  }

  Future<void> _toggleJoin(String id) async {
    final willJoin = !_joinedCampIds.contains(id);
    setState(() => willJoin ? _joinedCampIds.add(id) : _joinedCampIds.remove(id));

    if (willJoin) {
      await SupabaseService().joinCamp(campId: id, donorId: _donorId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registered for camp in Supabase! You will receive SMS & WhatsApp reminders.'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _openCityPicker() {
    showDonorCampsCitySheet(
      context: context,
      selectedCity: _selectedCity,
      supportedCities: _supportedCities,
      onCitySelected: (city) {
        setState(() {
          _selectedCity = city;
          if (city != 'All') _resolveCityCoordinates(city);
        });
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredCamps() {
    return _allCamps.map((camp) => {
      'camp': camp,
      'distance': SupabaseService().calculateHaversineDistanceKm(_donorLat, _donorLng, camp.lat, camp.lng),
    }).where((item) {
      final camp = item['camp'] as CampModel;
      final dist = item['distance'] as double;
      final matchesCity = _selectedCity == 'All' || camp.city.toLowerCase() == _selectedCity.toLowerCase();
      return matchesCity && (dist <= _selectedRadiusKm);
    }).toList()..sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredCamps();

    return Scaffold(
      backgroundColor: BrandColors.surfaceSoft,
      appBar: const ScreenHeader(title: 'Donation Camps', showBackButton: false),
      body: SafeArea(
        child: RefreshIndicator(
          color: BrandColors.primaryAction,
          onRefresh: _loadDonorLocationAndCamps,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              DonorCampsFilterHeader(
                isAway: _isAway,
                selectedCity: _selectedCity,
                selectedRadiusKm: _selectedRadiusKm,
                onOpenCityPicker: _openCityPicker,
                onRadiusChanged: (r) => setState(() => _selectedRadiusKm = r),
              ),
              const SizedBox(height: 16),
              Text('Upcoming Drives (${filtered.length})', style: BrandTypography.title(color: BrandColors.textPrimary)),
              const SizedBox(height: 14),
              if (_isLoading)
                const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: BrandColors.red)))
              else if (filtered.isEmpty)
                DonorCampsEmptyCard(
                  selectedCity: _selectedCity,
                  selectedRadiusKm: _selectedRadiusKm,
                  onViewAll: () => setState(() {
                    _selectedCity = 'All';
                    _selectedRadiusKm = 100.0;
                  }),
                )
              else
                ...filtered.map((item) {
                  final camp = item['camp'] as CampModel;
                  final distKm = item['distance'] as double;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DonorCampCard(
                      camp: camp,
                      distanceKm: distKm,
                      donorTravelRadius: _donorTravelRadius,
                      isJoined: _joinedCampIds.contains(camp.id),
                      onToggleJoin: () => _toggleJoin(camp.id),
                      onOpenDirections: () => showDonorCampDirectionsSheet(
                        context: context,
                        camp: camp,
                        distKm: distKm,
                        donorTravelRadius: _donorTravelRadius,
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
