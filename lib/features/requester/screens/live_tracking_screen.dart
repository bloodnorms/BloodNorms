// ============================================================================
// BloodNorms | live_tracking_screen.dart
// Live tracking screen with Map & Radar — Thin Screen Composing Sub-views
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/widgets/donor_radar_card.dart';
import '../../../shared/widgets/screen_header.dart';
import '../controllers/live_tracking_controller.dart';
import '../providers/request_flow_provider.dart';
import '../widgets/live_tracking_bottom_bar.dart';
import '../widgets/live_tracking_contact_dialogs.dart';
import '../widgets/live_tracking_donors_section.dart';
import '../widgets/live_tracking_fulfillment_dialogs.dart';
import '../widgets/live_tracking_map_view.dart';
import '../widgets/live_tracking_metrics_row.dart';
import '../widgets/live_tracking_status_header.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String requestId;

  const LiveTrackingScreen({super.key, required this.requestId});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  late LiveTrackingController _controller;
  late LiveTrackingData _data;
  final MapController _mapController = MapController();
  bool _showMap = true;

  @override
  void initState() {
    super.initState();
    final f = globalRequestFlow.state;
    _data = LiveTrackingData(
      need: f.units,
      bloodGroup: f.bloodGroup?.label ?? 'Blood',
      hospitalLat: f.lat,
      hospitalLng: f.lng,
      hospitalName: f.hospitalName.isNotEmpty ? f.hospitalName : 'Hospital',
    );
    _controller = LiveTrackingController(
      requestId: widget.requestId,
      data: _data,
      onDataChanged: (newData) {
        if (mounted) setState(() => _data = newData);
      },
    )..start();
  }

  @override
  void dispose() {
    _controller.dispose();
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
      if (mounted) showLiveTrackingPhoneFallback(context, donor.firstName, phone);
    } else {
      showDonorPrivacyNotice(context, donor.firstName);
    }
  }

  Future<void> _confirmDonation(String code) async {
    try {
      await SupabaseService().confirmBankDonation(code: code);
    } catch (e) {
      debugPrint('Confirm donation error: $e');
    }
    globalRequestFlow.clearActiveRequestId();
    if (mounted) showDonationConfirmedDialog(context, code);
  }

  Future<void> _finishRequest(String reason) async {
    await SupabaseService().closeRequest(widget.requestId, outcome: reason, status: 'fulfilled');
    globalRequestFlow.clearActiveRequestId();
    if (mounted) showRequestCompletedDialog(context, reason);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final centerPoint = LatLng(_data.hospitalLat, _data.hospitalLng);

    return Scaffold(
      backgroundColor: BrandColors.surfaceSoft,
      appBar: ScreenHeader(
        title: 'Live Search',
        showBackButton: false,
        trailing: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.close_rounded, size: 24, color: BrandColors.textSecondary),
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
                  LiveTrackingStatusHeader(
                    isClosed: _data.isClosed,
                    closedStatus: _data.closedStatus,
                    closedOutcome: _data.closedOutcome,
                    bloodGroup: _data.bloodGroup,
                    hospitalName: _data.hospitalName,
                    showMap: _showMap,
                    onToggleView: () => setState(() => _showMap = !_showMap),
                  ),
                  const SizedBox(height: 12),
                  if (_showMap)
                    LiveTrackingMapView(
                      mapController: _mapController,
                      centerPoint: centerPoint,
                      currentRingKm: _data.currentRingKm,
                      donors: _data.donors,
                      onCallDonor: _callDonor,
                    )
                  else
                    DonorRadarCard(
                      currentRingKm: _data.currentRingKm,
                      contactedCount: _data.contacted,
                      acceptedCount: _data.accepted,
                      needUnits: _data.need,
                    ),
                  const SizedBox(height: 20),
                  LiveTrackingMetricsRow(
                    contactedCount: _data.contacted,
                    acceptedCount: _data.accepted,
                    needUnits: _data.need,
                  ),
                  const SizedBox(height: 24),
                  LiveTrackingDonorsSection(
                    isLoading: _data.isLoading,
                    bloodGroup: _data.bloodGroup,
                    currentRingKm: _data.currentRingKm,
                    hospitalName: _data.hospitalName,
                    donors: _data.donors,
                    onCallDonor: _callDonor,
                    onConfirmDonation: _confirmDonation,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            LiveTrackingBottomBar(
              isClosed: _data.isClosed,
              gotBloodLabel: loc.t('live.got'),
              stopLabel: loc.t('cta.stop'),
              onReturnHome: () {
                globalRequestFlow.clearActiveRequestId();
                context.go('/');
              },
              onGotBlood: () => showGotBloodSheet(context: context, onSelectedReason: _finishRequest),
              onStopSearch: () => showStopSearchDialog(
                context: context,
                onConfirmStop: () async {
                  await SupabaseService().closeRequest(widget.requestId, outcome: 'cancelled_by_requester', status: 'cancelled');
                  globalRequestFlow.clearActiveRequestId();
                  if (mounted) context.go('/');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
