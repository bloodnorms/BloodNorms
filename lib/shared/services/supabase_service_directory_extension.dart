// ============================================================================
// BloodNorms | supabase_service_directory_extension.dart
// SupabaseService extension for Directory, Hospital, Partner, and DPDP operations
// ============================================================================

import '../../features/admin_console/services/admin_directory_service.dart';
import 'supabase_service.dart';

extension SupabaseServiceDirectoryExtension on SupabaseService {
  // Directory & Safety Operations
  Future<List<Map<String, dynamic>>> getHospitals() =>
      AdminDirectoryService().getHospitals();

  Future<List<Map<String, dynamic>>> getAIPromptVersions() =>
      AdminDirectoryService().getAIPromptVersions();

  Future<Map<String, dynamic>> runAIEvaluationSuite({
    required String promptVersionId,
  }) =>
      AdminDirectoryService().runAIEvaluationSuite(
        promptVersionId: promptVersionId,
      );

  Future<List<Map<String, dynamic>>> getSafetyIncidents() =>
      AdminDirectoryService().getSafetyIncidents();

  Future<List<Map<String, dynamic>>> getDPDPRequests() =>
      AdminDirectoryService().getDPDPRequests();

  Future<List<Map<String, dynamic>>> getCommunityPartners() =>
      AdminDirectoryService().getCommunityPartners();

  Future<List<Map<String, dynamic>>> getRequesterProfiles() =>
      AdminDirectoryService().getRequesterProfiles();

  Future<bool> setRequesterBlockStatus({
    required String phone,
    required bool isBlocked,
    String? reason,
  }) =>
      AdminDirectoryService().setRequesterBlockStatus(
        phone: phone,
        isBlocked: isBlocked,
        reason: reason,
      );
}
