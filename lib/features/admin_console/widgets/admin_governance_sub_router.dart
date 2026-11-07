// ============================================================================
// BloodNorms | admin_governance_sub_router.dart
// Sub-router for Four-Eyes Approvals, Data Exports, DPDP & Platform Settings
// ============================================================================

import 'package:flutter/material.dart';
import 'algorithm_settings_view.dart';
import 'approvals_queue_view.dart';
import 'audit_logs_view.dart';
import 'data_exports_view.dart';
import 'dpdp_registry_view.dart';
import 'killswitch_settings_view.dart';
import 'safety_desk_view.dart';

class AdminGovernanceSubRouter {
  static Widget? maybeBuild({
    required String activePage,
    required List<Map<String, dynamic>> approvalRequests,
    required List<Map<String, dynamic>> dataExports,
    required List<Map<String, dynamic>> dpdpRequests,
    required bool killSwitchActive,
    required List<Map<String, dynamic>> safetyIncidents,
    required List<Map<String, dynamic>> auditLogs,
    required void Function(String id, bool approve) onDecideApproval,
    required void Function(bool value) onToggleKillSwitch,
    required void Function(String message) onShowToast,
  }) {
    switch (activePage) {
      case 'approvals_queue':
        return ApprovalsQueueView(
          approvalRequests: approvalRequests,
          onDecideApproval: onDecideApproval,
        );
      case 'data_exports':
        return DataExportsView(
          dataExports: dataExports,
          onShowToast: onShowToast,
        );
      case 'dpdp_registry':
        return DPDPRegistryView(
          dpdpRequests: dpdpRequests,
        );
      case 'settings_killswitch':
        return KillswitchSettingsView(
          killSwitchActive: killSwitchActive,
          onToggleKillSwitch: onToggleKillSwitch,
        );
      case 'settings_algorithm':
        return const AlgorithmSettingsView();
      case 'settings_safety':
        return SafetyDeskView(
          safetyIncidents: safetyIncidents,
        );
      case 'settings_audit':
        return AuditLogsView(
          auditLogs: auditLogs,
        );
      default:
        return null;
    }
  }
}
