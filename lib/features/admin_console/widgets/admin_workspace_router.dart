// ============================================================================
// BloodNorms | admin_workspace_router.dart
// Active page router component for the Executive Admin Command Center
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/models/blood_bank_model.dart';
import '../../../shared/models/camp_model.dart';
import 'admin_comms_sub_router.dart';
import 'admin_directory_sub_router.dart';
import 'admin_governance_sub_router.dart';
import 'audit_logs_view.dart';
import 'crisis_radar_view.dart';
import 'dashboard_cockpit_view.dart';
import 'needs_human_view.dart';

export 'admin_comms_sub_router.dart';
export 'admin_directory_sub_router.dart';
export 'admin_governance_sub_router.dart';

class AdminWorkspaceRouter extends StatelessWidget {
  final String activePage;
  final List<Map<String, dynamic>> liveRequests;
  final List<BloodBankModel> banksList;
  final List<Map<String, dynamic>> donorsList;
  final List<CampModel> campsList;
  final Map<String, dynamic> dailySpend;
  final Map<String, dynamic> audiencePreview;
  final List<Map<String, dynamic>> broadcastHistory;
  final String selectedTargetCity;
  final String selectedChannel;
  final double broadcastRadiusKm;
  final bool respectDonorTravelRadius;
  final TextEditingController broadcastTitleController;
  final TextEditingController broadcastMsgController;
  final bool isBroadcasting;
  final List<Map<String, dynamic>> hospitalsList;
  final List<Map<String, dynamic>> requestersList;
  final List<Map<String, dynamic>> partnersList;
  final List<Map<String, dynamic>> approvalRequests;
  final List<Map<String, dynamic>> dataExports;
  final List<Map<String, dynamic>> dpdpRequests;
  final bool killSwitchActive;
  final List<Map<String, dynamic>> safetyIncidents;
  final List<Map<String, dynamic>> auditLogs;
  final Map<String, int> stockMatrix;

  final void Function(String reqId, double currentKm) onWidenRequest;
  final void Function(String reqId) onCloseRequest;
  final void Function(String page) onNavigate;
  final void Function(String city) onCityChanged;
  final void Function(String channel) onChannelChanged;
  final void Function(double radius) onRadiusChanged;
  final void Function(bool respect) onRespectRadiusChanged;
  final VoidCallback onDispatchBroadcast;
  final void Function(CampModel camp) onCampSelectedForBroadcast;
  final void Function(CampModel newCamp) onCampCreated;
  final void Function(String group, int delta) onAdjustStock;
  final void Function(String donorId, String currentState) onToggleDonorPause;
  final void Function(String phone, bool currentBlocked) onToggleRequesterBlock;
  final void Function(String id, bool approve) onDecideApproval;
  final void Function(bool value) onToggleKillSwitch;
  final void Function(String message) onShowToast;

  const AdminWorkspaceRouter({
    super.key,
    required this.activePage,
    required this.liveRequests,
    required this.banksList,
    required this.donorsList,
    required this.campsList,
    required this.dailySpend,
    required this.audiencePreview,
    required this.broadcastHistory,
    required this.selectedTargetCity,
    required this.selectedChannel,
    required this.broadcastRadiusKm,
    required this.respectDonorTravelRadius,
    required this.broadcastTitleController,
    required this.broadcastMsgController,
    required this.isBroadcasting,
    required this.hospitalsList,
    required this.requestersList,
    required this.partnersList,
    required this.approvalRequests,
    required this.dataExports,
    required this.dpdpRequests,
    required this.killSwitchActive,
    required this.safetyIncidents,
    required this.auditLogs,
    required this.stockMatrix,
    required this.onWidenRequest,
    required this.onCloseRequest,
    required this.onNavigate,
    required this.onCityChanged,
    required this.onChannelChanged,
    required this.onRadiusChanged,
    required this.onRespectRadiusChanged,
    required this.onDispatchBroadcast,
    required this.onCampSelectedForBroadcast,
    required this.onCampCreated,
    required this.onAdjustStock,
    required this.onToggleDonorPause,
    required this.onToggleRequesterBlock,
    required this.onDecideApproval,
    required this.onToggleKillSwitch,
    required this.onShowToast,
  });

  @override
  Widget build(BuildContext context) {
    final commsWidget = AdminCommsSubRouter.maybeBuild(
      activePage: activePage,
      audiencePreview: audiencePreview,
      selectedTargetCity: selectedTargetCity,
      selectedChannel: selectedChannel,
      broadcastRadiusKm: broadcastRadiusKm,
      respectDonorTravelRadius: respectDonorTravelRadius,
      broadcastTitleController: broadcastTitleController,
      broadcastMsgController: broadcastMsgController,
      isBroadcasting: isBroadcasting,
      broadcastHistory: broadcastHistory,
      onCityChanged: onCityChanged,
      onChannelChanged: onChannelChanged,
      onRadiusChanged: onRadiusChanged,
      onRespectRadiusChanged: onRespectRadiusChanged,
      onDispatchBroadcast: onDispatchBroadcast,
      onShowToast: onShowToast,
    );
    if (commsWidget != null) return commsWidget;

    final govWidget = AdminGovernanceSubRouter.maybeBuild(
      activePage: activePage,
      approvalRequests: approvalRequests,
      dataExports: dataExports,
      dpdpRequests: dpdpRequests,
      killSwitchActive: killSwitchActive,
      safetyIncidents: safetyIncidents,
      auditLogs: auditLogs,
      onDecideApproval: onDecideApproval,
      onToggleKillSwitch: onToggleKillSwitch,
      onShowToast: onShowToast,
    );
    if (govWidget != null) return govWidget;

    final dirWidget = AdminDirectorySubRouter.maybeBuild(
      activePage: activePage,
      campsList: campsList,
      banksList: banksList,
      stockMatrix: stockMatrix,
      donorsList: donorsList,
      hospitalsList: hospitalsList,
      requestersList: requestersList,
      partnersList: partnersList,
      onNavigate: onNavigate,
      onCampSelectedForBroadcast: onCampSelectedForBroadcast,
      onCampCreated: onCampCreated,
      onAdjustStock: onAdjustStock,
      onToggleDonorPause: onToggleDonorPause,
      onToggleRequesterBlock: onToggleRequesterBlock,
      onShowToast: onShowToast,
    );
    if (dirWidget != null) return dirWidget;

    switch (activePage) {
      case 'dashboard':
        return DashboardCockpitView(
          liveRequests: liveRequests,
          banksList: banksList,
          donorsList: donorsList,
          campsList: campsList,
          dailySpend: dailySpend,
          onOpenRadar: () => onNavigate('crisis_radar'),
          onWidenRequest: onWidenRequest,
          onCloseRequest: onCloseRequest,
        );
      case 'crisis_radar':
        return CrisisRadarView(
          liveRequests: liveRequests,
          onWidenRequest: onWidenRequest,
          onCloseRequest: onCloseRequest,
        );
      case 'needs_human':
        return NeedsHumanView(
          liveRequests: liveRequests,
          onWidenRequest: onWidenRequest,
          onCloseRequest: onCloseRequest,
        );
      default:
        return AuditLogsView(
          auditLogs: auditLogs,
        );
    }
  }
}
