// ============================================================================
// BloodNorms | admin_workspace_router.dart
// Active page router component for the Executive Admin Command Center
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/models/blood_bank_model.dart';
import '../../../shared/models/camp_model.dart';
import 'algorithm_settings_view.dart';
import 'approvals_queue_view.dart';
import 'audit_logs_view.dart';
import 'blood_banks_stock_view.dart';
import 'blood_camps_admin_view.dart';
import 'broadcast_audience_view.dart';
import 'broadcast_dispatch_view.dart';
import 'broadcast_history_view.dart';
import 'community_partners_view.dart';
import 'crisis_radar_view.dart';
import 'dashboard_cockpit_view.dart';
import 'data_exports_view.dart';
import 'donors_registry_view.dart';
import 'dpdp_registry_view.dart';
import 'hospitals_registry_view.dart';
import 'killswitch_settings_view.dart';
import 'needs_human_view.dart';
import 'requester_shield_view.dart';
import 'safety_desk_view.dart';
import 'voice_prompts_view.dart';
import 'voice_safety_view.dart';
import 'voice_simulator_view.dart';
import 'whatsapp_bot_view.dart';
import 'whatsapp_telecom_view.dart';
import 'whatsapp_templates_view.dart';

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
      case 'broadcast_dispatch':
        return BroadcastDispatchView(
          audiencePreview: audiencePreview,
          selectedTargetCity: selectedTargetCity,
          selectedChannel: selectedChannel,
          broadcastRadiusKm: broadcastRadiusKm,
          respectDonorTravelRadius: respectDonorTravelRadius,
          broadcastTitleController: broadcastTitleController,
          broadcastMsgController: broadcastMsgController,
          isBroadcasting: isBroadcasting,
          onCityChanged: onCityChanged,
          onChannelChanged: onChannelChanged,
          onRadiusChanged: onRadiusChanged,
          onRespectRadiusChanged: onRespectRadiusChanged,
          onDispatch: onDispatchBroadcast,
        );
      case 'broadcast_audience':
        return BroadcastAudienceView(
          audiencePreview: audiencePreview,
        );
      case 'broadcast_history':
        return BroadcastHistoryView(
          broadcastHistory: broadcastHistory,
        );
      case 'voice_simulator':
        return VoiceSimulatorView(
          onShowToast: onShowToast,
        );
      case 'voice_prompts':
        return const VoicePromptsView();
      case 'voice_safety':
        return const VoiceSafetyView();
      case 'whatsapp_bot':
        return WhatsAppBotView(
          onShowToast: onShowToast,
        );
      case 'whatsapp_templates':
        return WhatsAppTemplatesView(
          onShowToast: onShowToast,
        );
      case 'whatsapp_telecom':
        return const WhatsAppTelecomView();
      case 'camps_list':
      case 'camps_create':
        return BloodCampsAdminView(
          subPage: activePage,
          campsList: campsList,
          banksList: banksList,
          onNavigateToCreate: () => onNavigate('camps_create'),
          onCampSelectedForBroadcast: onCampSelectedForBroadcast,
          onCampCreated: onCampCreated,
          onShowToast: onShowToast,
        );
      case 'banks_directory':
      case 'banks_stock':
        return BloodBanksStockView(
          subPage: activePage,
          banksList: banksList,
          stockMatrix: stockMatrix,
          onAdjustStock: onAdjustStock,
        );
      case 'donors_list':
      case 'donors_location':
        return DonorsRegistryView(
          subPage: activePage,
          donorsList: donorsList,
          onToggleDonorPause: onToggleDonorPause,
          onShowToast: onShowToast,
        );
      case 'hospitals_list':
        return HospitalsRegistryView(
          hospitalsList: hospitalsList,
        );
      case 'requester_shield':
        return RequesterShieldView(
          requestersList: requestersList,
          onToggleRequesterBlock: onToggleRequesterBlock,
        );
      case 'community_partners':
        return CommunityPartnersView(
          partnersList: partnersList,
        );
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
      default:
        return AuditLogsView(
          auditLogs: auditLogs,
        );
    }
  }
}
