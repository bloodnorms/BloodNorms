// ============================================================================
// BloodNorms | supabase_service_bank_extension.dart
// Blood bank and camp operation extensions for SupabaseService
// ============================================================================

import '../../features/bank_console/services/index.dart';
import '../models/blood_bank_model.dart';
import '../models/camp_model.dart';
import 'supabase_service.dart';

extension SupabaseServiceBankExtension on SupabaseService {
  // Blood bank operations
  Future<List<BloodBankModel>> getNearestBanks({
    required double lat,
    required double lng,
    String? bloodGroup,
    String component = 'whole_blood',
  }) =>
      BloodBankService().getNearestBanks(
        lat: lat,
        lng: lng,
        bloodGroup: bloodGroup,
        component: component,
      );

  Future<void> cacheBloodBanks(List<BloodBankModel> banks) =>
      BloodBankService().cacheBloodBanks(banks);

  Future<List<BloodBankModel>> getCachedBloodBanks() =>
      BloodBankService().getCachedBloodBanks();

  Future<Map<String, int>> getBankStock({
    String? bankId,
    String component = 'whole_blood',
  }) =>
      BloodBankService().getBankStock(bankId: bankId, component: component);

  Future<int> setBankStock(
    List<Map<String, dynamic>> rows, {
    String? bankId,
  }) =>
      BloodBankService().setBankStock(rows, bankId: bankId);

  Future<Map<String, dynamic>> confirmBankDonation({
    required String code,
    String? donorLast4,
  }) =>
      BloodBankService().confirmBankDonation(
        code: code,
        donorLast4: donorLast4,
      );

  Future<List<Map<String, dynamic>>> getBanks() =>
      BloodBankService().getBanks();

  // Camp operations
  Future<void> cacheCamps(List<CampModel> camps) =>
      CampService().cacheCamps(camps);

  Future<List<CampModel>> getCachedCamps() =>
      CampService().getCachedCamps();

  Future<List<CampModel>> getCamps() =>
      CampService().getCamps();

  Future<bool> joinCamp({required String campId, String? donorId}) =>
      CampService().joinCamp(campId: campId, donorId: donorId);

  Future<bool> createCamp({
    String? bankId,
    required String title,
    required String venue,
    required String area,
    String city = 'Rajahmundry',
    required DateTime startsAt,
    required DateTime endsAt,
    int capacity = 100,
    double? lat,
    double? lng,
    double targetRadiusKm = 10.0,
    String? directionsUrl,
    String? coordinatorName,
    String? coordinatorPhone,
  }) =>
      CampService().createCamp(
        bankId: bankId,
        title: title,
        venue: venue,
        area: area,
        city: city,
        startsAt: startsAt,
        endsAt: endsAt,
        capacity: capacity,
        lat: lat,
        lng: lng,
        targetRadiusKm: targetRadiusKm,
        directionsUrl: directionsUrl,
        coordinatorName: coordinatorName,
        coordinatorPhone: coordinatorPhone,
      );

  Future<Set<String>> getDonorJoinedCampIds(String donorId) =>
      CampService().getDonorJoinedCampIds(donorId);
}

