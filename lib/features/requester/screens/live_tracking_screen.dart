// ============================================================================
// BloodNorms | live_tracking_screen.dart
// Live tracking screen matching pure reference with Map & Accepted Donors
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/widgets/screen_header.dart';
import '../controllers/live_tracking_controller.dart';
import '../providers/request_flow_provider.dart';
import '../widgets/live_tracking_contact_dialogs.dart';
import '../widgets/live_tracking_donors_section.dart';
import '../widgets/live_tracking_fulfillment_dialogs.dart';
import '../widgets/live_tracking_map_view.dart';

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

  @override
  void initState() {
    super.initState();
    final f = globalRequestFlow.state;
    _data = LiveTrackingData(
      need: f.units > 0 ? f.units : 2,
      bloodGroup: f.bloodGroup?.label ?? 'O+',
      hospitalLat: (f.lat != 0.0) ? f.lat : 17.0481,
      hospitalLng: (f.lng != 0.0) ? f.lng : 81.8421,
      hospitalName: f.hospitalName.isNotEmpty ? f.hospitalName : 'Diwancheruvu',
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

  @override
  Widget build(BuildContext context) {
    final centerPoint = LatLng(_data.hospitalLat, _data.hospitalLng);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ScreenHeader(
        title: 'Request sent',
        showBackButton: true,
        onBackOverride: () => context.go('/'),
        trailing: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: BrandColors.borderSubtle),
              borderRadius: BorderRadius.circular(BrandColors.radiusPill),
            ),
            child: const Text('EN', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          ),
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.close_rounded, size: 24, color: BrandColors.textSecondary),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            LiveTrackingMapView(
              mapController: _mapController,
              centerPoint: centerPoint,
              currentRingKm: _data.currentRingKm,
              donors: _data.donors,
              onCallDonor: _callDonor,
              needUnits: _data.need,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: LiveTrackingDonorsSection(
                isLoading: _data.isLoading,
                bloodGroup: _data.bloodGroup,
                needUnits: _data.need,
                currentRingKm: _data.currentRingKm,
                hospitalName: _data.hospitalName,
                donors: _data.donors,
                onCallDonor: _callDonor,
                onConfirmDonation: _confirmDonation,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
