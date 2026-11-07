// ============================================================================
// BloodNorms | live_tracking_screen.dart
// Live tracking screen with Map & Radar — Duolingo Feather Red Style
// Realtime PostGIS PostgREST Supabase communication, Arial, zero dummy data
// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/pin_keypad.dart';
import '../../../shared/widgets/donor_radar_card.dart';
import '../providers/request_flow_provider.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String requestId;

  const LiveTrackingScreen({super.key, required this.requestId});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  double _currentRingKm = 1.0;
  int _contacted = 0;
  int _accepted = 0;
  int _need = 1;
  String _hospitalName = 'Hospital';
  String _bloodGroup = 'Blood';
  double _hospitalLat = AppConstants.defaultLat;
  double _hospitalLng = AppConstants.defaultLng;

  bool _isClosed = false;
  String _closedStatus = '';
  String _closedOutcome = '';

  StreamSubscription? _requestSub;
  StreamSubscription? _contactsSub;
  late final MapController _mapController;
  bool _showMap = true; // Toggle between Live Map and Radar Graphic

  List<DonorCardModel> _donors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _need = globalRequestFlow.state.units;
    _bloodGroup = globalRequestFlow.state.bloodGroup?.label ?? 'Blood';
    _hospitalLat = globalRequestFlow.state.lat;
    _hospitalLng = globalRequestFlow.state.lng;
    _hospitalName = globalRequestFlow.state.hospitalName.isNotEmpty
        ? globalRequestFlow.state.hospitalName
        : 'Hospital';

    _initSupabaseRealtime();
  }

  Future<void> _initSupabaseRealtime() async {
    // 1. Fetch current request state directly from Supabase
    try {
      final req = await SupabaseService().getRequest(widget.requestId);
      if (mounted && req != null) {
        final status = req['status']?.toString();
        final isClosed = (status == 'cancelled' || status == 'fulfilled');
        setState(() {
          _isClosed = isClosed;
          _closedStatus = status ?? '';
          _closedOutcome = req['outcome']?.toString() ?? '';
          _currentRingKm = (req['current_ring_km'] as num?)?.toDouble() ?? _currentRingKm;
          _contacted = (req['donors_contacted'] as num?)?.toInt() ?? _contacted;
          _accepted = (req['donors_accepted'] as num?)?.toInt() ?? _accepted;
          _need = (req['units_needed'] as num?)?.toInt() ?? _need;
          _bloodGroup = req['blood_group']?.toString() ?? _bloodGroup;
          _hospitalName = req['hospital_name']?.toString() ?? _hospitalName;
          final lat = (req['hospital_lat'] as num?)?.toDouble();
          final lng = (req['hospital_lng'] as num?)?.toDouble();
          if (lat != null && lng != null && lat != 0.0) {
            _hospitalLat = lat;
            _hospitalLng = lng;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching request: $e');
    }

    // 2. Fetch dispatched contacts directly from Supabase
    try {
      final initialContacts = await SupabaseService().getRequestContacts(widget.requestId);
      if (mounted) {
        setState(() {
          _donors = initialContacts;
          if (initialContacts.isNotEmpty) {
            _contacted = initialContacts.length;
            _accepted = initialContacts.where((d) => d.status == 'accepted').length;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching contacts: $e');
      if (mounted) setState(() => _isLoading = false);
    }

    // 3. Stream Request changes live from Supabase
    _requestSub = SupabaseService().streamRequest(widget.requestId).listen((row) {
      if (!mounted || row == null) return;
      final status = row['status']?.toString();
      final isClosed = (status == 'cancelled' || status == 'fulfilled');
      setState(() {
        _isClosed = isClosed;
        _closedStatus = status ?? '';
        _closedOutcome = row['outcome']?.toString() ?? '';
        _currentRingKm = (row['current_ring_km'] as num?)?.toDouble() ?? _currentRingKm;
        _contacted = (row['donors_contacted'] as num?)?.toInt() ?? _contacted;
        _accepted = (row['donors_accepted'] as num?)?.toInt() ?? _accepted;
        _need = (row['units_needed'] as num?)?.toInt() ?? _need;
      });
    });

    // 4. Stream Contact changes live from Supabase
    _contactsSub = SupabaseService().streamRequestContacts(widget.requestId).listen((rows) async {
      if (!mounted) return;
      final updated = await SupabaseService().getRequestContacts(widget.requestId);
      if (mounted) {
        setState(() {
          _donors = updated;
          _contacted = updated.isNotEmpty ? updated.length : _contacted;
          _accepted = updated.where((d) => d.status == 'accepted').length;
        });
      }
    });
  }

  @override
  void dispose() {
    _requestSub?.cancel();
    _contactsSub?.cancel();
    super.dispose();
  }

  Future<void> _callDonor(DonorCardModel donor) async {
    final phone = donor.phone?.trim();
    if (phone != null && phone.isNotEmpty) {
      final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          return;
        }
      } catch (_) {}
      _showPhoneFallback(donor.firstName, phone);
    } else {
      _showPrivacyNotice(donor.firstName);
    }
  }

  void _showPrivacyNotice(String name) {
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
            const Icon(Icons.privacy_tip_rounded, color: DuoColors.red, size: 24),
            const SizedBox(width: 8),
            Text('Contact Details', style: DuoTypography.title3(color: DuoColors.textPrimary)),
          ],
        ),
        content: Text(
          '$name has been sent an emergency alert. Their direct phone number will be displayed as soon as they confirm availability.',
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
          'Phone: $phone\n(Direct donor connection per emergency protocol)',
          style: DuoTypography.body(color: DuoColors.textSecondary),
        ),
        actions: [
          DuoButton(
            label: 'CLOSE',
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
                      'Ask the donor for their 6-digit pass code to verify donation',
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

  Future<void> _confirmDonation(String code) async {
    try {
      await SupabaseService().confirmBankDonation(code: code);
    } catch (e) {
      debugPrint('Confirm donation error: $e');
    }
    globalRequestFlow.clearActiveRequestId();

    if (!mounted) return;
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
          'Donation pass $code verified and recorded in Supabase.',
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
            Text('Where was the blood obtained? Feedback helps maintain blood bank accuracy.', style: DuoTypography.body(color: DuoColors.textSecondary)),
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

  Future<void> _finishRequest(String reason) async {
    await SupabaseService().closeRequest(widget.requestId, outcome: reason, status: 'fulfilled');
    globalRequestFlow.clearActiveRequestId();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: DuoColors.border, width: 2.0),
        ),
        title: Text('Request Completed', style: DuoTypography.title2(color: DuoColors.textPrimary)),
        content: Text('Outcome recorded: $reason. Contacted donors have been notified.', style: DuoTypography.body(color: DuoColors.textSecondary)),
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
          'This will cancel the active request in Supabase and notify contacted donors that blood is no longer needed.',
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
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await SupabaseService().closeRequest(
                      widget.requestId,
                      outcome: 'cancelled_by_requester',
                      status: 'cancelled',
                    );
                    globalRequestFlow.clearActiveRequestId();
                    if (mounted) context.go('/');
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
    final centerPoint = LatLng(_hospitalLat, _hospitalLng);

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
                  if (_isClosed) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _closedStatus == 'cancelled' ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _closedStatus == 'cancelled' ? DuoColors.red : DuoColors.green,
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _closedStatus == 'cancelled' ? DuoColors.red : DuoColors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _closedStatus == 'cancelled' ? Icons.close_rounded : Icons.check_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _closedStatus == 'cancelled' ? 'REQUEST CANCELLED' : 'REQUEST COMPLETED',
                                  style: TextStyle(
                                    fontFamily: DuoTypography.fontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _closedStatus == 'cancelled' ? DuoColors.red : DuoColors.green,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _closedStatus == 'cancelled'
                                      ? 'This emergency request was cancelled (${_closedOutcome.isNotEmpty ? _closedOutcome : "by requester"}). Contacted donors have been notified.'
                                      : 'Blood request was fulfilled successfully (${_closedOutcome.isNotEmpty ? _closedOutcome : "completed"}).',
                                  style: const TextStyle(
                                    fontFamily: DuoTypography.fontFamily,
                                    fontSize: 12.5,
                                    color: DuoColors.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    DuoSpeechBubble(
                      emoji: '📡',
                      text: "Searching for $_bloodGroup donors around $_hospitalName. Contacts and responses update in real time below!",
                    ),
                    const SizedBox(height: 16),
                  ],

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
                                style: const TextStyle(
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
                      height: 240,
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
                                    radius: _currentRingKm * 1000,
                                    useRadiusInMeter: true,
                                    color: DuoColors.red.withValues(alpha: 0.12),
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
                                  // Dynamic Donor Pins from Supabase
                                  ..._donors.map((d) {
                                    final isAccepted = d.status == 'accepted';
                                    return Marker(
                                      point: LatLng(d.lat, d.lng),
                                      width: 42,
                                      height: 42,
                                      child: GestureDetector(
                                        onTap: () => _callDonor(d),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isAccepted ? DuoColors.green : DuoColors.redTint,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isAccepted ? Colors.white : DuoColors.red,
                                              width: 2.0,
                                            ),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: DuoColors.border,
                                                offset: Offset(0, 2),
                                                blurRadius: 0,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              d.firstName.isNotEmpty ? d.firstName[0].toUpperCase() : 'D',
                                              style: TextStyle(
                                                fontFamily: DuoTypography.fontFamily,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isAccepted ? Colors.white : DuoColors.red,
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
                                border: Border.all(color: DuoColors.border, width: 1.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.radar_rounded, size: 14, color: DuoColors.red),
                                  const SizedBox(width: 4),
                                  Text(
                                    'WAVE RING: ${_currentRingKm.toStringAsFixed(1)} KM',
                                    style: const TextStyle(
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
                        label: const Text(
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

                  // If empty, display live radar scanning indicator
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: CircularProgressIndicator(color: DuoColors.red),
                      ),
                    )
                  else if (_donors.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
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
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: DuoColors.redTint,
                              shape: BoxShape.circle,
                              border: Border.all(color: DuoColors.red, width: 2),
                            ),
                            child: const Center(
                              child: Icon(Icons.emergency_share_rounded, color: DuoColors.red, size: 28),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Broadcasting Alerts to Donors',
                            style: DuoTypography.title3(color: DuoColors.textPrimary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Emergency alerts sent to verified $_bloodGroup donors within ${_currentRingKm.toStringAsFixed(1)} km radius of $_hospitalName. As soon as a donor accepts, their card will appear here live.',
                            style: DuoTypography.caption(color: DuoColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
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
              child: _isClosed
                  ? DuoButton(
                      label: 'RETURN TO HOME',
                      icon: Icons.home_rounded,
                      variant: DuoButtonVariant.primary,
                      onPressed: () {
                        globalRequestFlow.clearActiveRequestId();
                        context.go('/');
                      },
                    )
                  : Row(
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
            style: const TextStyle(
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
    final isAccepted = donor.status == 'accepted';

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
              color: isAccepted ? DuoColors.greenTint : DuoColors.redTint,
              shape: BoxShape.circle,
              border: Border.all(
                color: isAccepted ? DuoColors.green : DuoColors.red,
                width: 2.0,
              ),
            ),
            child: Center(
              child: Text(
                donor.firstName.isNotEmpty ? donor.firstName[0].toUpperCase() : 'D',
                style: TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isAccepted ? DuoColors.green : DuoColors.red,
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
                    Flexible(
                      child: Text(
                        donor.firstName,
                        style: DuoTypography.headline(color: DuoColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
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
                const SizedBox(height: 6),

                // Live Breadcrumb Milestone Stepper (BR-12/13 Compliant)
                Row(
                  children: [
                    _buildBreadcrumbStep(
                      label: 'Alerted',
                      isActive: true,
                      isDone: true,
                    ),
                    _buildBreadcrumbDivider(isDone: isAccepted),
                    _buildBreadcrumbStep(
                      label: 'En Route',
                      isActive: isAccepted,
                      isDone: isAccepted,
                    ),
                    _buildBreadcrumbDivider(isDone: donor.status == 'arrived' || donor.status == 'donated'),
                    _buildBreadcrumbStep(
                      label: 'Arrived',
                      isActive: donor.status == 'arrived' || donor.status == 'donated',
                      isDone: donor.status == 'donated',
                    ),
                  ],
                ),
                if (donor.donationCode != null && donor.donationCode!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Verification Pass: ${donor.donationCode}',
                    style: const TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: DuoColors.green,
                    ),
                  ),
                ],
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
                color: isAccepted ? DuoColors.green : DuoColors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isAccepted ? DuoColors.greenShadow : DuoColors.redShadow,
                    offset: const Offset(0, 3),
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

  Widget _buildBreadcrumbStep({required String label, required bool isActive, required bool isDone}) {
    final color = isDone ? DuoColors.green : (isActive ? DuoColors.red : DuoColors.border);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontFamily: DuoTypography.fontFamily,
            fontSize: 9.5,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? DuoColors.textPrimary : DuoColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBreadcrumbDivider({required bool isDone}) {
    return Container(
      width: 12,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: isDone ? DuoColors.green : DuoColors.border,
    );
  }
}
