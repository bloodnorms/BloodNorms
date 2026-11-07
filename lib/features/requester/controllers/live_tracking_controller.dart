// ============================================================================
// BloodNorms | live_tracking_controller.dart
// Realtime PostGIS/Supabase stream controller for live donor search tracking
// ============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../shared/services/supabase_service.dart';

class LiveTrackingData {
  final double currentRingKm;
  final int contacted;
  final int accepted;
  final int need;
  final String hospitalName;
  final String bloodGroup;
  final double hospitalLat;
  final double hospitalLng;
  final bool isClosed;
  final String closedStatus;
  final String closedOutcome;
  final List<DonorCardModel> donors;
  final bool isLoading;

  LiveTrackingData({
    this.currentRingKm = 1.0,
    this.contacted = 0,
    this.accepted = 0,
    this.need = 1,
    this.hospitalName = 'Hospital',
    this.bloodGroup = 'Blood',
    this.hospitalLat = 17.0005,
    this.hospitalLng = 81.7820,
    this.isClosed = false,
    this.closedStatus = '',
    this.closedOutcome = '',
    this.donors = const [],
    this.isLoading = true,
  });

  LiveTrackingData copyWith({
    double? currentRingKm,
    int? contacted,
    int? accepted,
    int? need,
    String? hospitalName,
    String? bloodGroup,
    double? hospitalLat,
    double? hospitalLng,
    bool? isClosed,
    String? closedStatus,
    String? closedOutcome,
    List<DonorCardModel>? donors,
    bool? isLoading,
  }) {
    return LiveTrackingData(
      currentRingKm: currentRingKm ?? this.currentRingKm,
      contacted: contacted ?? this.contacted,
      accepted: accepted ?? this.accepted,
      need: need ?? this.need,
      hospitalName: hospitalName ?? this.hospitalName,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      hospitalLat: hospitalLat ?? this.hospitalLat,
      hospitalLng: hospitalLng ?? this.hospitalLng,
      isClosed: isClosed ?? this.isClosed,
      closedStatus: closedStatus ?? this.closedStatus,
      closedOutcome: closedOutcome ?? this.closedOutcome,
      donors: donors ?? this.donors,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LiveTrackingController {
  final String requestId;
  final ValueChanged<LiveTrackingData> onDataChanged;
  LiveTrackingData data;

  StreamSubscription? _requestSub;
  StreamSubscription? _contactsSub;

  LiveTrackingController({
    required this.requestId,
    required this.onDataChanged,
    required this.data,
  });

  Future<void> start() async {
    try {
      final req = await SupabaseService().getRequest(requestId);
      if (req != null) {
        final status = req['status']?.toString();
        final lat = (req['hospital_lat'] as num?)?.toDouble();
        final lng = (req['hospital_lng'] as num?)?.toDouble();

        data = data.copyWith(
          isClosed: status == 'cancelled' || status == 'fulfilled',
          closedStatus: status ?? '',
          closedOutcome: req['outcome']?.toString() ?? '',
          currentRingKm: (req['current_ring_km'] as num?)?.toDouble() ?? data.currentRingKm,
          contacted: (req['donors_contacted'] as num?)?.toInt() ?? data.contacted,
          accepted: (req['donors_accepted'] as num?)?.toInt() ?? data.accepted,
          need: (req['units_needed'] as num?)?.toInt() ?? data.need,
          bloodGroup: req['blood_group']?.toString() ?? data.bloodGroup,
          hospitalName: req['hospital_name']?.toString() ?? data.hospitalName,
          hospitalLat: (lat != null && lat != 0.0) ? lat : data.hospitalLat,
          hospitalLng: (lng != null && lng != 0.0) ? lng : data.hospitalLng,
        );
        onDataChanged(data);
      }

      final initialContacts = await SupabaseService().getRequestContacts(requestId);
      data = data.copyWith(
        donors: initialContacts,
        contacted: initialContacts.isNotEmpty ? initialContacts.length : data.contacted,
        accepted: initialContacts.where((d) => d.status == 'accepted').length,
        isLoading: false,
      );
      onDataChanged(data);
    } catch (e) {
      debugPrint('Error starting live tracking: $e');
      data = data.copyWith(isLoading: false);
      onDataChanged(data);
    }

    _requestSub = SupabaseService().streamRequest(requestId).listen((row) {
      if (row == null) return;
      final status = row['status']?.toString();
      data = data.copyWith(
        isClosed: status == 'cancelled' || status == 'fulfilled',
        closedStatus: status ?? '',
        closedOutcome: row['outcome']?.toString() ?? '',
        currentRingKm: (row['current_ring_km'] as num?)?.toDouble() ?? data.currentRingKm,
        contacted: (row['donors_contacted'] as num?)?.toInt() ?? data.contacted,
        accepted: (row['donors_accepted'] as num?)?.toInt() ?? data.accepted,
        need: (row['units_needed'] as num?)?.toInt() ?? data.need,
      );
      onDataChanged(data);
    });

    _contactsSub = SupabaseService().streamRequestContacts(requestId).listen((rows) async {
      final updated = await SupabaseService().getRequestContacts(requestId);
      data = data.copyWith(
        donors: updated,
        contacted: updated.isNotEmpty ? updated.length : data.contacted,
        accepted: updated.where((d) => d.status == 'accepted').length,
      );
      onDataChanged(data);
    });
  }

  void dispose() {
    _requestSub?.cancel();
    _contactsSub?.cancel();
  }
}
