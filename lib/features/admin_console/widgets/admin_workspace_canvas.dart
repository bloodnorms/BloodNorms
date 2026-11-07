// ============================================================================
// BloodNorms | admin_workspace_canvas.dart
// Main Scrollable Canvas Composing Admin Header and Workspace Router
// ============================================================================

import 'package:flutter/material.dart';
import '../controllers/admin_console_controller.dart';
import 'admin_header.dart';
import 'admin_workspace_router.dart';

class AdminWorkspaceCanvas extends StatelessWidget {
  final AdminConsoleController controller;
  final VoidCallback onQuickActions;
  final VoidCallback onDispatchBroadcast;
  final void Function(String message) onShowToast;

  const AdminWorkspaceCanvas({
    super.key,
    required this.controller,
    required this.onQuickActions,
    required this.onDispatchBroadcast,
    required this.onShowToast,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      children: [
        AdminHeader(
          activePage: controller.activePage,
          onQuickActions: onQuickActions,
        ),
        const SizedBox(height: 20),
        AdminWorkspaceRouter(
          activePage: controller.activePage,
          liveRequests: controller.liveRequests,
          banksList: controller.banksList,
          donorsList: controller.donorsList,
          campsList: controller.campsList,
          dailySpend: controller.dailySpend,
          audiencePreview: controller.audiencePreview,
          broadcastHistory: controller.broadcastHistory,
          selectedTargetCity: controller.selectedTargetCity,
          selectedChannel: controller.selectedChannel,
          broadcastRadiusKm: controller.broadcastRadiusKm,
          respectDonorTravelRadius: controller.respectDonorTravelRadius,
          broadcastTitleController: controller.broadcastTitleController,
          broadcastMsgController: controller.broadcastMsgController,
          isBroadcasting: controller.isBroadcasting,
          hospitalsList: controller.hospitalsList,
          requestersList: controller.requestersList,
          partnersList: controller.partnersList,
          approvalRequests: controller.approvalRequests,
          dataExports: controller.dataExports,
          dpdpRequests: controller.dpdpRequests,
          killSwitchActive: controller.killSwitchActive,
          safetyIncidents: controller.safetyIncidents,
          auditLogs: controller.auditLogs,
          stockMatrix: controller.stockMatrix,
          onWidenRequest: (id, km) {
            controller.widenRequest(id, km);
            onShowToast('Expanded search ring to ${(km + 2.0).toStringAsFixed(1)} km (+3 donors contacted)');
          },
          onCloseRequest: (id) {
            controller.closeRequest(id);
            onShowToast('Emergency crisis fulfilled and closed');
          },
          onNavigate: controller.setActivePage,
          onCityChanged: controller.setTargetCity,
          onChannelChanged: controller.setChannel,
          onRadiusChanged: controller.setBroadcastRadius,
          onRespectRadiusChanged: controller.setRespectTravelRadius,
          onDispatchBroadcast: onDispatchBroadcast,
          onCampSelectedForBroadcast: controller.selectCampForBroadcast,
          onCampCreated: controller.addCamp,
          onAdjustStock: (group, delta) {
            controller.adjustStockDirect(group, delta);
            onShowToast('${delta > 0 ? "+$delta" : delta} units of $group adjusted in database');
          },
          onToggleDonorPause: (id, state) async {
            await controller.toggleDonorPause(id, state);
            final next = state == 'active' ? 'PAUSED' : 'ACTIVE';
            onShowToast('Donor status updated to $next');
          },
          onToggleRequesterBlock: (phone, blocked) async {
            await controller.toggleRequesterBlock(phone, blocked);
            onShowToast(blocked ? 'Unblocked $phone' : 'Blocked $phone from emergency broadcast');
          },
          onDecideApproval: (id, approve) async {
            final res = await controller.decideApproval(id, approve);
            if (res['ok'] == true) {
              onShowToast(approve ? 'Approved change request #$id' : 'Rejected change request #$id');
            } else {
              onShowToast('Approval action failed: ${res['reason']}');
            }
          },
          onToggleKillSwitch: (val) async {
            await controller.toggleKillSwitch(val);
            onShowToast(val
                ? '🚨 PLATFORM EMERGENCY KILL-SWITCH ACTIVATED'
                : '✅ Platform operations restored to normal');
          },
          onShowToast: onShowToast,
        ),
      ],
    );
  }
}

