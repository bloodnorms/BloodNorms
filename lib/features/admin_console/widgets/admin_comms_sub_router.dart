// ============================================================================
// BloodNorms | admin_comms_sub_router.dart
// Sub-router for Broadcast Center, AI Voice Studio & WhatsApp Comms Hub
// ============================================================================

import 'package:flutter/material.dart';
import 'broadcast_audience_view.dart';
import 'broadcast_dispatch_view.dart';
import 'broadcast_history_view.dart';
import 'voice_prompts_view.dart';
import 'voice_safety_view.dart';
import 'voice_simulator_view.dart';
import 'whatsapp_bot_view.dart';
import 'whatsapp_telecom_view.dart';
import 'whatsapp_templates_view.dart';

class AdminCommsSubRouter {
  static Widget? maybeBuild({
    required String activePage,
    required Map<String, dynamic> audiencePreview,
    required String selectedTargetCity,
    required String selectedChannel,
    required double broadcastRadiusKm,
    required bool respectDonorTravelRadius,
    required TextEditingController broadcastTitleController,
    required TextEditingController broadcastMsgController,
    required bool isBroadcasting,
    required List<Map<String, dynamic>> broadcastHistory,
    required void Function(String city) onCityChanged,
    required void Function(String channel) onChannelChanged,
    required void Function(double radius) onRadiusChanged,
    required void Function(bool respect) onRespectRadiusChanged,
    required VoidCallback onDispatchBroadcast,
    required void Function(String message) onShowToast,
  }) {
    switch (activePage) {
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
      default:
        return null;
    }
  }
}
