// ============================================================================
// BloodNorms | supabase_service_admin_extension.dart
// Admin console direct bank, donor, camp, and telemetry extensions
// ============================================================================

import '../../features/admin_console/services/index.dart';
import 'supabase_service.dart';

extension SupabaseServiceAdminExtension on SupabaseService {
  // Admin Direct Bank Operations
  Future<bool> adjustBankStockQuick({
    required String bankId,
    required String bloodGroup,
    required int deltaUnits,
    String component = 'whole_blood',
  }) =>
      AdminBankOperationsService().adjustBankStockQuick(
        bankId: bankId,
        bloodGroup: bloodGroup,
        deltaUnits: deltaUnits,
        component: component,
      );

  Future<bool> updateBloodBank({
    required String bankId,
    double? trustScore,
    bool? is24x7,
  }) =>
      AdminBankOperationsService().updateBloodBank(
        bankId: bankId,
        trustScore: trustScore,
        is24x7: is24x7,
      );

  Future<Map<String, dynamic>> createBloodBankDirect({
    required String name,
    required String address,
    required String phone,
    bool is24x7 = true,
    int trustScore = 85,
    String contactPerson = '',
    double lat = 17.0005,
    double lng = 81.7800,
  }) =>
      AdminBankOperationsService().createBloodBankDirect(
        name: name,
        address: address,
        phone: phone,
        is24x7: is24x7,
        trustScore: trustScore,
        contactPerson: contactPerson,
        lat: lat,
        lng: lng,
      );

  Future<bool> updateBloodBankFull({
    required String id,
    String? name,
    String? address,
    String? phone,
    bool? is24x7,
    int? trustScore,
    String? contactPerson,
    double? lat,
    double? lng,
  }) =>
      AdminBankOperationsService().updateBloodBankFull(
        id: id,
        name: name,
        address: address,
        phone: phone,
        is24x7: is24x7,
        trustScore: trustScore,
        contactPerson: contactPerson,
        lat: lat,
        lng: lng,
      );

  Future<Map<String, int>> getBankStockAllGroups(String bankId) =>
      AdminBankOperationsService().getBankStockAllGroups(bankId);

  Future<bool> setBankStockDirect({
    required String bankId,
    required String bloodGroup,
    required int units,
    String component = 'whole_blood',
  }) =>
      AdminBankOperationsService().setBankStockDirect(
        bankId: bankId,
        bloodGroup: bloodGroup,
        units: units,
        component: component,
      );

  // Admin Direct Donor Operations
  Future<bool> updateDonorTrustLevel(String donorId, int trustLevel) =>
      AdminDonorOperationsService().updateDonorTrustLevel(donorId, trustLevel);

  Future<Map<String, dynamic>> createDonorDirect({
    required String fullName,
    required String phone,
    required String bloodGroup,
    int trustLevel = 1,
    String gender = 'other',
    int maxTravelKm = 10,
    String state = 'active',
  }) =>
      AdminDonorOperationsService().createDonorDirect(
        fullName: fullName,
        phone: phone,
        bloodGroup: bloodGroup,
        trustLevel: trustLevel,
        gender: gender,
        maxTravelKm: maxTravelKm,
        state: state,
      );

  Future<bool> updateDonorDirect({
    required String id,
    String? fullName,
    String? phone,
    String? bloodGroup,
    String? state,
    int? trustLevel,
    String? gender,
    int? maxTravelKm,
    int? donationsCount,
  }) =>
      AdminDonorOperationsService().updateDonorDirect(
        id: id,
        fullName: fullName,
        phone: phone,
        bloodGroup: bloodGroup,
        state: state,
        trustLevel: trustLevel,
        gender: gender,
        maxTravelKm: maxTravelKm,
        donationsCount: donationsCount,
      );

  // Admin Camp Operations
  Future<List<Map<String, dynamic>>> getBroadcastHistory() =>
      AdminCampOperationsService().getBroadcastHistory();

  Future<bool> updateCampDirect({
    required String id,
    String? title,
    String? venue,
    String? area,
    DateTime? startsAt,
    DateTime? endsAt,
    int? capacity,
    String? status,
  }) =>
      AdminCampOperationsService().updateCampDirect(
        id: id,
        title: title,
        venue: venue,
        area: area,
        startsAt: startsAt,
        endsAt: endsAt,
        capacity: capacity,
        status: status,
      );

  Future<bool> deleteCampDirect(String id) =>
      AdminCampOperationsService().deleteCampDirect(id);
}
