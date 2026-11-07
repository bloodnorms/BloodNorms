// ============================================================================
// BloodNorms | admin_platform_loader.dart
// Service Loader for Admin Platform Data Snapshot
// ============================================================================

import '../../../shared/constants/app_constants.dart';
import '../../../shared/services/supabase_service.dart';

class AdminPlatformSnapshot {
  final List<Map<String, dynamic>> liveRequests;
  final List<Map<String, dynamic>> donors;
  final List<BloodBankModel> banks;
  final List<CampModel> camps;
  final bool killSwitch;
  final List<Map<String, dynamic>> auditLogs;
  final List<Map<String, dynamic>> broadcastHistory;
  final List<Map<String, dynamic>> hospitals;
  final List<Map<String, dynamic>> requesters;
  final List<Map<String, dynamic>> partners;
  final List<Map<String, dynamic>> approvals;
  final List<Map<String, dynamic>> incidents;
  final List<Map<String, dynamic>> dpdp;
  final List<Map<String, dynamic>> exports;
  final Map<String, dynamic> spend;

  const AdminPlatformSnapshot({
    required this.liveRequests,
    required this.donors,
    required this.banks,
    required this.camps,
    required this.killSwitch,
    required this.auditLogs,
    required this.broadcastHistory,
    required this.hospitals,
    required this.requesters,
    required this.partners,
    required this.approvals,
    required this.incidents,
    required this.dpdp,
    required this.exports,
    required this.spend,
  });
}

class AdminPlatformLoader {
  static Future<AdminPlatformSnapshot> loadSnapshot() async {
    final s = SupabaseService();
    return AdminPlatformSnapshot(
      liveRequests: await s.getActiveRequests(),
      donors: await s.getAllDonors(),
      banks: await s.getNearestBanks(
        lat: AppConstants.defaultLat,
        lng: AppConstants.defaultLng,
      ),
      camps: await s.getCamps(),
      killSwitch: await s.getKillSwitch(),
      auditLogs: await s.getRecentActivityLog(),
      broadcastHistory: await s.getBroadcastHistory(),
      hospitals: await s.getHospitals(),
      requesters: await s.getRequesterProfiles(),
      partners: await s.getCommunityPartners(),
      approvals: await s.getApprovalRequests(),
      incidents: await s.getSafetyIncidents(),
      dpdp: await s.getDPDPRequests(),
      exports: await s.getDataExports(),
      spend: await s.getDailySpendSummary(),
    );
  }
}
