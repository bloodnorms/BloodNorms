// ============================================================================
// BloodNorms | supabase_service_requester_extension.dart
// Requester operations extensions for SupabaseService
// ============================================================================

import 'dart:typed_data';
import '../../features/requester/services/index.dart';
import '../models/donor_card_model.dart';
import 'supabase_service.dart';

extension SupabaseServiceRequesterExtension on SupabaseService {
  Future<List<DonorCardModel>> findNearbyDonors({
    required double lat,
    required double lng,
    required String bloodGroup,
    bool allowCompatible = true,
    double radiusKm = 30.0,
  }) =>
      BloodRequestService().findNearbyDonors(
        lat: lat,
        lng: lng,
        bloodGroup: bloodGroup,
        allowCompatible: allowCompatible,
        radiusKm: radiusKm,
      );

  Future<String> createRequest({
    required String bloodGroup,
    required String component,
    required int unitsNeeded,
    required String urgency,
    required String hospitalName,
    required String hospitalArea,
    required double lat,
    required double lng,
    required String requesterName,
    required String requesterPhone,
    String? patientFirstName,
    int? patientAge,
    String? note,
    bool allowCompatible = false,
  }) =>
      BloodRequestService().createRequest(
        bloodGroup: bloodGroup,
        component: component,
        unitsNeeded: unitsNeeded,
        urgency: urgency,
        hospitalName: hospitalName,
        hospitalArea: hospitalArea,
        lat: lat,
        lng: lng,
        requesterName: requesterName,
        requesterPhone: requesterPhone,
        patientFirstName: patientFirstName,
        patientAge: patientAge,
        note: note,
        allowCompatible: allowCompatible,
      );

  Future<List<DonorCardModel>> getRequestContacts(String requestId) =>
      BloodRequestService().getRequestContacts(requestId);

  Stream<Map<String, dynamic>?> streamRequest(String requestId) =>
      BloodRequestService().streamRequest(requestId);

  Stream<List<Map<String, dynamic>>> streamRequestContacts(String requestId) =>
      BloodRequestService().streamRequestContacts(requestId);

  Future<Map<String, dynamic>?> getRequest(String requestId) =>
      BloodRequestService().getRequest(requestId);

  Future<List<Map<String, dynamic>>> getActiveRequests() =>
      BloodRequestService().getActiveRequests();

  Future<bool> widenRequest(String requestId, double newRadiusKm, {int wave = 1}) =>
      BloodRequestService().widenRequest(requestId, newRadiusKm, wave: wave);

  Future<bool> closeRequest(String requestId, {String outcome = 'resolved', String? status}) =>
      BloodRequestService().closeRequest(requestId, outcome: outcome, status: status);

  Future<String?> uploadPrescriptionSlip({
    required Uint8List bytes,
    required String fileName,
  }) =>
      BloodRequestService().uploadPrescriptionSlip(bytes: bytes, fileName: fileName);
}

