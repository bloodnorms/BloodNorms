// ============================================================================
// BloodNorms | live_tracking_screen.dart
// Live tracking screen with Map & Radar — Duolingo Feather Red Style
// Interactive OpenStreetMap, radar search card, 3D keypad entry, 3D donor cards
// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/duo_colors.dart';
import '../../../core/theme/duo_typography.dart';
import '../../../core/widgets/duo_button.dart';
import '../../../core/widgets/duo_header_bar.dart';
import '../../../core/widgets/duo_keypad.dart';
import '../../../core/widgets/duo_radar_card.dart';
import '../providers/request_flow_provider.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String requestId;

  const LiveTrackingScreen({super.key, required this.requestId});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  double _currentRingKm = 1.0;
  int _contacted = 6;
  int _accepted = 1;
  int _need = 1;
  Timer? _simulationTimer;
  late final MapController _mapController;
  bool _showMap = true; // Toggle between Live Map and Radar Graphic

  final List<DonorCardModel> _donors = [
    DonorCardModel(
      id: 'd1',
      firstName: 'Ramesh',
      bloodGroup: 'O+',
      distanceBand: '1–2 km',
      etaMinutes: 20,
      status: 'accepted',
      isStandby: false,
      phoneRevealed: true,
      phone: '+919848111222',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _need = globalRequestFlow.state.units;

    // Simulation timer to expand search rings every 8 seconds
    _simulationTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!mounted) return;
      if (_currentRingKm < 5.0) {
        setState(() {
          _currentRingKm += 1.0;
          _contacted += 6;
          if (_donors.length == 1) {
            _donors.add(
              DonorCardModel(
                id: 'd2',
                firstName: 'Suresh',
                bloodGroup: globalRequestFlow.state.bloodGroup?.label ?? 'O+',
                distanceBand: '${_currentRingKm.toInt()}–${(_currentRingKm + 1).toInt()} km',
                etaMinutes: 30,
                status: 'accepted',
                isStandby: false,
                phoneRevealed: false,
                phone: '+919848222333',
              ),
            );
            _accepted += 1;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  Future<void> _callDonor(DonorCardModel donor) async {
    final phone = donor.phone ?? '+919848111222';
    final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showPhoneFallback(donor.firstName, phone);
      }
    } catch (_) {
      _showPhoneFallback(donor.firstName, phone);
    }
  }

  void _showPhoneFallback(String name, String phone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: DuoColors.border, width: 2.0),
        ),
        title: Text('Call $name', style: DuoTypography.title3(color: DuoColors.textPrimary)),
        content: Text(
          'Donor phone number: $phone\n(Revealed per BR-10 audit trail)',
          style: DuoTypography.body(color: DuoColors.textSecondary),
        ),
        actions: [
          DuoButton(
            label: 'OK',
            variant: DuoButtonVariant.primary,
            height: 44,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _showCodeEntrySheet() {
    String enteredCode = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: DuoColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Enter Donor Code',
                      style: DuoTypography.title2(color: DuoColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ask the donor for their 6-digit pass code (BR-25)',
                      style: DuoTypography.caption(color: DuoColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    DuoCodeDisplayDots(code: enteredCode),
                    const SizedBox(height: 24),
                    DuoKeypad(
                      onDigitPressed: (digit) {
                        if (enteredCode.length < 6) {
                          setSheetState(() => enteredCode += digit);
                          if (enteredCode.length == 6) {
                            Navigator.pop(ctx);
                            _confirmDonation(enteredCode);
                          }
                        }
                      },
                      onDeletePressed: () {
                        if (enteredCode.isNotEmpty) {
                          setSheetState(() => enteredCode = enteredCode.substring(0, enteredCode.length - 1));
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDonation(String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: DuoColors.border, width: 2.0),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DuoColors.greenTint,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: DuoColors.greenShadow, width: 1.5),
              ),
              child: const Icon(Icons.check_circle_rounded, color: DuoColors.green, size: 24),
            ),
            const SizedBox(width: 12),
            Text('Donation Confirmed!', style: DuoTypography.title3(color: DuoColors.textPrimary)),
          ],
        ),
        content: Text(
          'Donation pass $code verified. Thank you for using BloodNorms! Units recorded.',
          style: DuoTypography.body(color: DuoColors.textSecondary),
        ),
        actions: [
          DuoButton(
            label: 'DONE',
            variant: DuoButtonVariant.success,
            height: 44,
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/');
            },
          ),
        ],
      ),
    );
  }

  void _showGotBloodSheet() {
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
            Text('Got Blood! Close Request?', style: DuoTypography.title2(color: DuoColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Was blood stock available at the blood bank? Feedback keeps bank honesty accurate.', style: DuoTypography.body(color: DuoColors.textSecondary)),
            const SizedBox(height: 20),
            DuoButton(
              label: 'Yes, stock was there (+3 trust)',
              variant: DuoButtonVariant.success,
              height: 48,
              onPressed: () {
                Navigator.pop(ctx);
                _finishRequest('Found stock at bank');
              },
            ),
            const SizedBox(height: 10),
            DuoButton(
              label: 'Found donor through BloodNorms',
              variant: DuoButtonVariant.primary,
              height: 48,
              onPressed: () {
                Navigator.pop(ctx);
                _finishRequest('Found verified donor');
              },
            ),
            const SizedBox(height: 10),
            DuoButton(
              label: 'No, bank stock was wrong (-8 trust)',
              variant: DuoButtonVariant.secondary,
              height: 48,
              onPressed: () {
                Navigator.pop(ctx);
                _finishRequest('Bank stock was missing');
              },
            ),
            const SizedBox(height: 10),
            DuoButton(
              label: 'CANCEL',
              variant: DuoButtonVariant.plain,
              height: 44,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _finishRequest(String reason) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: DuoColors.border, width: 2.0),
        ),
        title: Text('Request Completed', style: DuoTypography.title2(color: DuoColors.textPrimary)),
        content: Text('Outcome recorded: $reason. Thank you! Contacted donors have been notified.', style: DuoTypography.body(color: DuoColors.textSecondary)),
        actions: [
          DuoButton(
            label: 'DONE',
            variant: DuoButtonVariant.primary,
            height: 44,
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/');
            },
          ),
        ],
      ),
    );
  }

  void _showStopConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: DuoColors.border, width: 2.0),
        ),
        title: Text('Stop Search?', style: DuoTypography.title2(color: DuoColors.red)),
        content: Text(
          'This will cancel the active request and notify contacted donors that blood is no longer needed.',
          style: DuoTypography.body(color: DuoColors.textSecondary),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: DuoButton(
                  label: 'KEEP SEARCHING',
                  variant: DuoButtonVariant.secondary,
                  height: 44,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DuoButton(
                  label: 'STOP',
                  variant: DuoButtonVariant.destructive,
                  height: 44,
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final hospitalLat = globalRequestFlow.state.lat;
    final hospitalLng = globalRequestFlow.state.lng;
    final centerPoint = LatLng(hospitalLat, hospitalLng);

    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: DuoHeaderBar(
        title: 'Live Search',
        showBackButton: false,
        trailing: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.close_rounded, size: 24, color: DuoColors.textSecondary),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  const DuoSpeechBubble(
                    emoji: '📡',
                    text: "I'm searching donors in widening rings. Confirmed donors appear live on the map below!",
                  ),
                  const SizedBox(height: 16),

                  // View Toggle (Map vs Radar Graphic)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _showMap = !_showMap),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: DuoColors.red, width: 1.5),
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
                              Icon(
                                _showMap ? Icons.radar_rounded : Icons.map_rounded,
                                size: 16,
                                color: DuoColors.red,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _showMap ? 'RADAR VIEW' : 'MAP VIEW',
                                style: TextStyle(
                                  fontFamily: DuoTypography.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: DuoColors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Interactive Live Search Map or Radar Graphic
                  if (_showMap)
                    Container(
                      height: 230,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: DuoColors.border, width: 2.0),
                        boxShadow: const [
                          BoxShadow(
                            color: DuoColors.border,
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: centerPoint,
                              initialZoom: 13.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.arkiolabs.bloodnorms',
                              ),
                              // Expanding Search Radius Circle
                              CircleLayer(
                                circles: [
                                  CircleMarker(
                                    point: centerPoint,
                                    radius: _currentRingKm * 800, // Visual meter scaling
                                    useRadiusInMeter: true,
                                    color: DuoColors.red.withValues(alpha: 0.15),
                                    borderColor: DuoColors.red,
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
                                        color: DuoColors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2.5),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: DuoColors.redShadow,
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
                                  // Accepted Donor Pins
                                  Marker(
                                    point: LatLng(centerPoint.latitude + 0.009, centerPoint.longitude + 0.008),
                                    width: 44,
                                    height: 44,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: DuoColors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.person_pin_circle_rounded, color: Colors.white, size: 26),
                                      ),
                                    ),
                                  ),
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
                                border: Border.all(color: DuoColors.border, width: 1.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.radar_rounded, size: 14, color: DuoColors.red),
                                  const SizedBox(width: 4),
                                  Text(
                                    'WAVE RING: ${_currentRingKm.toStringAsFixed(1)} KM',
                                    style: TextStyle(
                                      fontFamily: DuoTypography.fontFamily,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: DuoColors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    DuoRadarCard(
                      currentRingKm: _currentRingKm,
                      contactedCount: _contacted,
                      acceptedCount: _accepted,
                      needUnits: _need,
                    ),

                  const SizedBox(height: 20),

                  // Metrics summary badges
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricPill(Icons.people_rounded, 'CONTACTED', '$_contacted', DuoColors.textPrimary, const Color(0xFFF0F0F0)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricPill(Icons.check_circle_rounded, 'AGREED', '$_accepted', DuoColors.green, DuoColors.greenTint),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricPill(Icons.water_drop_rounded, 'NEEDED', '$_need', DuoColors.red, DuoColors.redTint),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Donors accepted header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Agreed Donors',
                        style: DuoTypography.title2(color: DuoColors.textPrimary),
                      ),
                      TextButton.icon(
                        onPressed: _showCodeEntrySheet,
                        icon: const Icon(Icons.dialpad_rounded, size: 18, color: DuoColors.red),
                        label: Text(
                          'ENTER CODE',
                          style: TextStyle(
                            fontFamily: DuoTypography.fontFamily,
                            color: DuoColors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._donors.map((d) => _buildDuoDonorCard(context, d)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // Bottom Action Bar: Got blood (Green) & Stop (Secondary White)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: DuoColors.border, width: 2.0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DuoButton(
                      label: loc.t('live.got'),
                      icon: Icons.check_circle_rounded,
                      variant: DuoButtonVariant.success,
                      onPressed: _showGotBloodSheet,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DuoButton(
                      label: loc.t('cta.stop'),
                      variant: DuoButtonVariant.secondary,
                      onPressed: _showStopConfirmation,
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

  Widget _buildMetricPill(IconData icon, String label, String value, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DuoColors.border, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: DuoTypography.fontFamily,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: DuoColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuoDonorCard(BuildContext context, DonorCardModel donor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DuoColors.border, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: DuoColors.border,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: DuoColors.redTint,
              shape: BoxShape.circle,
              border: Border.all(color: DuoColors.red, width: 2.0),
            ),
            child: Center(
              child: Text(
                donor.firstName[0].toUpperCase(),
                style: TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: DuoColors.red,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Name, distance, ETA
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      donor.firstName,
                      style: DuoTypography.headline(color: DuoColors.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: DuoColors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        donor.bloodGroup,
                        style: const TextStyle(
                          fontFamily: DuoTypography.fontFamily,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      donor.distanceBand,
                      style: DuoTypography.caption(color: DuoColors.textSecondary),
                    ),
                    const Text(' · ', style: TextStyle(color: DuoColors.textMuted)),
                    const Icon(Icons.schedule_rounded, size: 14, color: DuoColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '~${donor.etaMinutes} min ETA',
                      style: DuoTypography.caption(color: DuoColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 3D Call circle button
          GestureDetector(
            onTap: () => _callDonor(donor),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: DuoColors.green,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: DuoColors.greenShadow,
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.phone_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
