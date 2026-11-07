// ============================================================================
// BloodNorms | supabase_service_donor_extension.dart
// Donor operations extensions for SupabaseService
// ============================================================================

import '../../features/donor/services/index.dart';
import '../models/request_alert_model.dart';
import 'supabase_service.dart';

extension SupabaseServiceDonorExtension on SupabaseService {
  Future<String?> registerDonor({
    required String fullName,
    required String phone,
    required String bloodGroup,
    required String gender,
    required DateTime dob,
    required double weightKg,
    required double lat,
    required double lng,
    String? area,
    String? city,
  }) =>
      DonorService().registerDonor(
        fullName: fullName,
        phone: phone,
        bloodGroup: bloodGroup,
        gender: gender,
        dob: dob,
        weightKg: weightKg,
        lat: lat,
        lng: lng,
        area: area,
        city: city,
      );

  Future<List<RequestAlertModel>> getDonorAlerts({String? bloodGroup}) =>
      DonorService().getDonorAlerts(bloodGroup: bloodGroup);

  Future<String?> acceptDonorAlert({
    required String requestId,
    required String donorId,
  }) =>
      DonorService().acceptDonorAlert(requestId: requestId, donorId: donorId);

  Future<List<Map<String, dynamic>>> getDonorPastHistory(String donorId) =>
      DonorService().getDonorPastHistory(donorId);

  Future<Map<String, dynamic>?> getDonor(String donorId) =>
      DonorService().getDonor(donorId);

  Future<List<Map<String, dynamic>>> getAllDonors() =>
      DonorService().getAllDonors();

  Future<List<Map<String, dynamic>>> getExpectedDonors() =>
      DonorService().getExpectedDonors();

  Future<bool> updateDonorState(String donorId, String state) =>
      DonorService().updateDonorState(donorId, state);

  Future<bool> deleteDonor(String donorId) =>
      DonorService().deleteDonor(donorId);

  Future<bool> updateDonorLocationPreferences({
    required String donorId,
    required String city,
    required String area,
    required double travelRadiusKm,
    required bool isAway,
    String? awayReason,
  }) =>
      DonorService().updateDonorLocationPreferences(
        donorId: donorId,
        city: city,
        area: area,
        travelRadiusKm: travelRadiusKm,
        isAway: isAway,
        awayReason: awayReason,
      );

  Future<Map<String, dynamic>> getDonorLocationPreferences(String donorId) =>
      DonorService().getDonorLocationPreferences(donorId);
}

