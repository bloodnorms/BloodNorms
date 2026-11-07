// ============================================================================
// BloodNorms | supabase_service_governance_extension.dart
// Governance, RBAC, maintenance, cost ledger, and directory extensions
// ============================================================================

import '../../features/admin_console/services/index.dart';
import 'supabase_service.dart';

extension SupabaseServiceGovernanceExtension on SupabaseService {
  // Feature Flags & RBAC
  Future<bool> isFeatureEnabled(String flagKey, {bool defaultValue = false}) =>
      AdminFeatureFlagsService().isFeatureEnabled(flagKey, defaultValue: defaultValue);

  Future<List<Map<String, dynamic>>> getFeatureFlags() =>
      AdminFeatureFlagsService().getFeatureFlags();

  Future<bool> setFeatureFlag(String flagKey, bool enabled) =>
      AdminFeatureFlagsService().setFeatureFlag(flagKey, enabled);

  Future<bool> hasAdminPermission(String permissionCode) =>
      AdminFeatureFlagsService().hasAdminPermission(permissionCode);

  Future<List<Map<String, dynamic>>> getAdminRoles() =>
      AdminFeatureFlagsService().getAdminRoles();

  // Four-Eyes Approvals & Step-Up
  Future<Map<String, dynamic>> submitApprovalRequest({
    required String actionType,
    String? targetEntity,
    String? targetId,
    required Map<String, dynamic> diffPayload,
    required String reason,
    String? makerId,
  }) =>
      AdminGovernanceService().submitApprovalRequest(
        actionType: actionType,
        targetEntity: targetEntity,
        targetId: targetId,
        diffPayload: diffPayload,
        reason: reason,
        makerId: makerId,
      );

  Future<List<Map<String, dynamic>>> getApprovalRequests({
    String status = 'pending',
  }) =>
      AdminGovernanceService().getApprovalRequests(status: status);

  Future<Map<String, dynamic>> decideApprovalRequest({
    required String requestId,
    required bool approve,
    String? note,
    String? currentUserId,
  }) =>
      AdminGovernanceService().decideApprovalRequest(
        requestId: requestId,
        approve: approve,
        note: note,
        currentUserId: currentUserId,
      );

  Future<bool> verifyStepUpCode(String totpCode) =>
      AdminGovernanceService().verifyStepUpCode(totpCode);

  Future<bool> hasActiveStepUp() =>
      AdminGovernanceService().hasActiveStepUp();

  Future<List<Map<String, dynamic>>> getActiveAdminSessions() =>
      AdminGovernanceService().getActiveAdminSessions();

  Future<bool> revokeAdminSession(String sessionId) =>
      AdminGovernanceService().revokeAdminSession(sessionId);

  Future<Map<String, dynamic>> requestBreakGlassElevation({
    required String reason,
  }) =>
      AdminGovernanceService().requestBreakGlassElevation(reason: reason);

  // Maintenance Windows
  Future<Map<String, dynamic>> checkMaintenanceStatus({
    required String scope,
    String? identifier,
  }) =>
      AdminMaintenanceService().checkMaintenanceStatus(
        scope: scope,
        identifier: identifier,
      );

  Future<List<Map<String, dynamic>>> getMaintenanceWindows() =>
      AdminMaintenanceService().getMaintenanceWindows();

  Future<Map<String, dynamic>> setMaintenanceMode({
    required bool active,
    List<String>? scopes,
    String policy = 'continue_active',
    String reason = 'Scheduled maintenance window',
    int durationMinutes = 60,
    Map<String, dynamic>? bypassAllowlist,
  }) =>
      AdminMaintenanceService().setMaintenanceMode(
        active: active,
        scopes: scopes,
        policy: policy,
        reason: reason,
        durationMinutes: durationMinutes,
        bypassAllowlist: bypassAllowlist,
      );

  Future<Map<String, dynamic>> extendMaintenanceWindow({
    required String windowId,
    required int additionalMinutes,
    String reason = 'Additional migration verification required',
  }) =>
      AdminMaintenanceService().extendMaintenanceWindow(
        windowId: windowId,
        additionalMinutes: additionalMinutes,
        reason: reason,
      );

  Future<bool> isMaintenanceActive() =>
      AdminMaintenanceService().isMaintenanceActive();

  // Data Exports
  String sanitizeCsvCell(String input) =>
      AdminExportService().sanitizeCsvCell(input);

  Future<Map<String, dynamic>> createDataExport({
    required String entityType,
    required String tier,
    required String format,
    required String reason,
    int rowCount = 0,
    Map<String, dynamic>? filterParams,
    String? approvalId,
  }) =>
      AdminExportService().createDataExport(
        entityType: entityType,
        tier: tier,
        format: format,
        reason: reason,
        rowCount: rowCount,
        filterParams: filterParams,
        approvalId: approvalId,
      );

  Future<List<Map<String, dynamic>>> getDataExports() =>
      AdminExportService().getDataExports();

  // Cost Ledgers
  Future<List<Map<String, dynamic>>> getCostRateCards() =>
      AdminCostLedgerService().getCostRateCards();

  Future<Map<String, dynamic>> recordCostEvent({
    required String requestId,
    required String serviceName,
    double units = 1.0,
    Map<String, dynamic>? meta,
  }) =>
      AdminCostLedgerService().recordCostEvent(
        requestId: requestId,
        serviceName: serviceName,
        units: units,
        meta: meta,
      );

  Future<Map<String, dynamic>> getDailySpendSummary({DateTime? date}) =>
      AdminCostLedgerService().getDailySpendSummary(date: date);

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

