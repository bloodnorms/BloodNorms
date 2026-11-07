// ============================================================================
// BloodNorms | donor_camps_screen.dart
// Blood Donation Camps Screen — Multi-Location Aware & Geo-Fenced
// Dynamic city filtering, distance sorting, travel zone badges, Arial font
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/screen_header.dart';

class DonorCampsScreen extends StatefulWidget {
  const DonorCampsScreen({super.key});

  @override
  State<DonorCampsScreen> createState() => _DonorCampsScreenState();
}

class _DonorCampsScreenState extends State<DonorCampsScreen> {
  final Set<String> _joinedCampIds = {};
  List<CampModel> _allCamps = [];
  bool _isLoading = true;
  String? _donorId;

  // Donor location and filter preferences
  String _selectedCity = 'Rajahmundry';
  double _selectedRadiusKm = 25.0;
  double _donorLat = 17.0005;
  double _donorLng = 81.7820;
  double _donorTravelRadius = 15.0;
  bool _isAway = false;

  final List<String> _supportedCities = [
    'Rajahmundry',
    'Kakinada',
    'Visakhapatnam',
    'Vijayawada',
    'Guntur',
    'Eluru',
    'Amalapuram',
    'Mandapeta',
    'All',
  ];

  @override
  void initState() {
    super.initState();
    _loadDonorLocationAndCamps();
  }

  Future<void> _loadDonorLocationAndCamps() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    _donorId = prefs.getString('current_donor_id') ?? 'd1000000-0000-0000-0000-000000000001';

    // Load donor location preferences
    final locPrefs = await SupabaseService().getDonorLocationPreferences(_donorId!);
    final cityPref = locPrefs['city']?.toString() ?? 'Rajahmundry';
    final radiusPref = (locPrefs['travel_radius_km'] as num?)?.toDouble() ?? 15.0;
    final isAwayPref = locPrefs['is_away'] == true;

    // Set coordinates based on city
    _resolveCityCoordinates(cityPref);

    final results = await SupabaseService().getCamps();
    Set<String> joined = {};
    if (_donorId != null && _donorId!.isNotEmpty) {
      joined = await SupabaseService().getDonorJoinedCampIds(_donorId!);
    }

    if (mounted) {
      setState(() {
        _allCamps = results;
        _selectedCity = cityPref;
        _donorTravelRadius = radiusPref;
        _isAway = isAwayPref;
        _joinedCampIds.clear();
        _joinedCampIds.addAll(joined);
        _isLoading = false;
      });
    }
  }

  void _resolveCityCoordinates(String city) {
    switch (city.toLowerCase()) {
      case 'kakinada':
        _donorLat = 16.9891;
        _donorLng = 82.2475;
        break;
      case 'visakhapatnam':
        _donorLat = 17.7042;
        _donorLng = 83.3032;
        break;
      case 'vijayawada':
        _donorLat = 16.5062;
        _donorLng = 80.6480;
        break;
      case 'guntur':
        _donorLat = 16.3067;
        _donorLng = 80.4365;
        break;
      case 'eluru':
        _donorLat = 16.7107;
        _donorLng = 81.0952;
        break;
      case 'rajahmundry':
      default:
        _donorLat = 17.0005;
        _donorLng = 81.7820;
        break;
    }
  }

  Future<void> _toggleJoin(String id) async {
    final willJoin = !_joinedCampIds.contains(id);
    setState(() {
      if (willJoin) {
        _joinedCampIds.add(id);
      } else {
        _joinedCampIds.remove(id);
      }
    });

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

  void _showCityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Viewing City / Region', style: DuoTypography.title2(color: DuoColors.textPrimary)),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'View voluntary blood drives in your area or adjacent districts.',
              style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _supportedCities.map((city) {
                final isSel = _selectedCity.toLowerCase() == city.toLowerCase();
                return ChoiceChip(
                  label: Text(
                    city == 'All' ? '🌐 All Regions' : city,
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      color: isSel ? Colors.white : DuoColors.textPrimary,
                    ),
                  ),
                  selected: isSel,
                  selectedColor: DuoColors.red,
                  backgroundColor: DuoColors.bgGrouped,
                  onSelected: (val) {
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedCity = city;
                      if (city != 'All') _resolveCityCoordinates(city);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDirectionsModal(CampModel camp, double distKm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: DuoColors.redTint, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.location_on_rounded, color: DuoColors.red, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(camp.venue, style: DuoTypography.title2(color: DuoColors.textPrimary)),
                      Text('${camp.area}, ${camp.city} (${camp.pincode})', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DuoColors.bgGrouped,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: DuoColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Distance from your location:', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
                      Text('~${distKm.toStringAsFixed(1)} KM', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 13, fontWeight: FontWeight.bold, color: DuoColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Travel Zone Status:', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
                      Text(
                        distKm <= _donorTravelRadius ? '✓ Within Your Travel Limit' : '⚠️ Outside Travel Limit',
                        style: TextStyle(
                          fontFamily: DuoTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: distKm <= _donorTravelRadius ? DuoColors.green : const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                  if (camp.coordinatorName != null) ...[
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Camp Coordinator:', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
                        Text('${camp.coordinatorName} (${camp.coordinatorPhone ?? ""})', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.bold, color: DuoColors.textPrimary)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            DuoButton(
              label: 'OPEN NAVIGATION MAP',
              icon: Icons.map_rounded,
              variant: DuoButtonVariant.primary,
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening GPS route to ${camp.venue} (${camp.lat}, ${camp.lng})'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Calculate distances for all camps and sort by nearest
    final campsWithDistance = _allCamps.map((camp) {
      final dist = SupabaseService().calculateHaversineDistanceKm(
        _donorLat,
        _donorLng,
        camp.lat,
        camp.lng,
      );
      return {'camp': camp, 'distance': dist};
    }).toList();

    campsWithDistance.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    // 2. Filter by city and radius
    final filtered = campsWithDistance.where((item) {
      final camp = item['camp'] as CampModel;
      final dist = item['distance'] as double;
      final cityMatches = _selectedCity == 'All' || camp.city.toLowerCase() == _selectedCity.toLowerCase();
      final radiusMatches = dist <= _selectedRadiusKm;
      return cityMatches && radiusMatches;
    }).toList();

    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: const DuoHeaderBar(
        title: 'Donation Camps',
        showBackButton: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: DuoColors.red,
          onRefresh: _loadDonorLocationAndCamps,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Out of station alert banner if donor is away
              if (_isAway) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFCD34D)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.flight_takeoff_rounded, color: Color(0xFFB45309), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You are marked as "Away / Out of Town". Localized broadcasts are temporarily paused.',
                          style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Speech Bubble with dynamic city
              DuoSpeechBubble(
                emoji: '⛺',
                text: 'Join voluntary blood drives in ${_selectedCity == "All" ? "Andhra Pradesh" : _selectedCity}! Meet fellow donors and save lives together.',
              ),
              const SizedBox(height: 16),

              // Location Selector Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: DuoColors.border, width: 2.0),
                  boxShadow: const [
                    BoxShadow(color: DuoColors.border, offset: Offset(0, 3), blurRadius: 0),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: DuoColors.red, size: 18),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CURRENT REGION', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 9, fontWeight: FontWeight.bold, color: DuoColors.textSecondary)),
                            Text(_selectedCity == 'All' ? 'All Districts' : _selectedCity, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 13, fontWeight: FontWeight.bold, color: DuoColors.textPrimary)),
                          ],
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: _showCityPicker,
                      icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: DuoColors.red),
                      label: const Text('Change City', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.bold, color: DuoColors.red)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        backgroundColor: DuoColors.redTint,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Radius filter stepper
              Row(
                children: [
                  const Text('Search Radius: ', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, fontWeight: FontWeight.bold, color: DuoColors.textSecondary)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [5.0, 15.0, 25.0, 50.0, 100.0].map((r) {
                          final isSel = _selectedRadiusKm == r;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text('${r.toInt()} km', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 10, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                              selected: isSel,
                              selectedColor: DuoColors.redTint,
                              onSelected: (_) => setState(() => _selectedRadiusKm = r),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text('Upcoming Drives (${filtered.length})', style: DuoTypography.title1(color: DuoColors.textPrimary)),
              const SizedBox(height: 14),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: DuoColors.red),
                  ),
                )
              else if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: DuoColors.border, width: 2.0),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.explore_off_rounded, size: 40, color: DuoColors.textSecondary),
                      const SizedBox(height: 12),
                      Text(
                        'No voluntary blood drives found in $_selectedCity within ${_selectedRadiusKm.toInt()} km.',
                        style: DuoTypography.body(color: DuoColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: () => setState(() {
                          _selectedCity = 'All';
                          _selectedRadiusKm = 100.0;
                        }),
                        icon: const Icon(Icons.public_rounded, size: 16),
                        label: const Text('View All Regional Drives', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              else
                ...filtered.map((item) {
                  final camp = item['camp'] as CampModel;
                  final distKm = item['distance'] as double;
                  final month = DateFormat('MMM').format(camp.startsAt).toUpperCase();
                  final day = DateFormat('dd').format(camp.startsAt);
                  final time = '${DateFormat('hh:mm a').format(camp.startsAt)} – ${DateFormat('hh:mm a').format(camp.endsAt)}';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildDuoCampCard(
                      camp: camp,
                      distanceKm: distKm,
                      month: month,
                      day: day,
                      time: time,
                      baseRegistered: 35,
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDuoCampCard({
    required CampModel camp,
    required double distanceKm,
    required String month,
    required String day,
    required String time,
    required int baseRegistered,
  }) {
    final isJoined = _joinedCampIds.contains(camp.id);
    final count = baseRegistered + (isJoined ? 1 : 0);
    final inTravelZone = distanceKm <= _donorTravelRadius;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isJoined ? DuoColors.greenShadow : DuoColors.border,
          width: 2.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: DuoColors.border,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Box in Red
              Container(
                width: 58,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isJoined ? DuoColors.greenTint : DuoColors.redTint,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isJoined ? DuoColors.greenShadow : DuoColors.redShadow,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isJoined ? DuoColors.greenShadow : DuoColors.redShadow,
                      offset: const Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      month,
                      style: TextStyle(
                        fontFamily: DuoTypography.fontFamily,
                        color: isJoined ? DuoColors.green : DuoColors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      day,
                      style: TextStyle(
                        fontFamily: DuoTypography.fontFamily,
                        color: isJoined ? DuoColors.green : DuoColors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      camp.title,
                      style: DuoTypography.title2(color: DuoColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 14, color: DuoColors.red),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${camp.venue}, ${camp.area} (${camp.city})',
                            style: DuoTypography.caption(color: DuoColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled_rounded, size: 14, color: DuoColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: DuoTypography.caption(color: DuoColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Distance and Zone Badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: DuoColors.bgGrouped,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: DuoColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.near_me_rounded, size: 12, color: DuoColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '~${distanceKm.toStringAsFixed(1)} KM Away',
                      style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 10, fontWeight: FontWeight.bold, color: DuoColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: inTravelZone ? DuoColors.greenTint : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  inTravelZone ? '✓ In Your Zone' : 'Outside Zone',
                  style: TextStyle(
                    fontFamily: DuoTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: inTravelZone ? DuoColors.green : const Color(0xFFB45309),
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => _showDirectionsModal(camp, distanceKm),
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.directions_rounded, size: 14, color: DuoColors.red),
                      SizedBox(width: 3),
                      Text('Route', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, fontWeight: FontWeight.bold, color: DuoColors.red)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$count donors registered',
                style: const TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  color: DuoColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                'Cap: ${camp.capacity}',
                style: DuoTypography.caption(color: DuoColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (count / camp.capacity).clamp(0.0, 1.0),
              backgroundColor: DuoColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                isJoined ? DuoColors.green : DuoColors.red,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),

          // 3D Action Button
          DuoButton(
            label: isJoined ? 'REGISTERED ✓' : 'JOIN CAMP',
            icon: isJoined ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
            variant: isJoined ? DuoButtonVariant.success : DuoButtonVariant.primary,
            height: 44,
            onPressed: () => _toggleJoin(camp.id),
          ),
        ],
      ),
    );
  }
}
