// ============================================================================
// BloodNorms | admin_broadcast_mixin.dart
// Admin Regional Broadcast Form, Audience Preview & Dispatching Mixin
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/supabase_service.dart';

mixin AdminBroadcastMixin on ChangeNotifier {
  final TextEditingController broadcastTitleController = TextEditingController(
    text: 'Mega Voluntary Blood Camp at Rotary Diamond Hall',
  );
  final TextEditingController broadcastMsgController = TextEditingController(
    text:
        'Dear BloodNorms Hero, a voluntary blood camp is organized this Sunday 9 AM at Rotary Diamond Hall, Main Road. Would you like to attend and donate? Reply YES to confirm.',
  );
  String? _selectedCampId;
  String _selectedTargetCity = 'Rajahmundry';
  double _broadcastRadiusKm = 10.0;
  bool _respectDonorTravelRadius = true;
  final String _selectedGroupFilter = 'All';
  String _selectedChannel = 'whatsapp';
  bool _isBroadcasting = false;
  Map<String, dynamic> _audiencePreview = {
    'eligible_count': 4,
    'suppressed_count': 2,
    'estimated_cost_inr': 3.40,
    'requires_approval': false,
    'sample_donors': [],
    'suppressed_sample': [],
    'area_breakdown': {'Danavaipeta': 2, 'Morampudi': 1, 'Innespeta': 1},
  };

  String? get selectedCampId => _selectedCampId;
  String get selectedTargetCity => _selectedTargetCity;
  double get broadcastRadiusKm => _broadcastRadiusKm;
  bool get respectDonorTravelRadius => _respectDonorTravelRadius;
  String get selectedGroupFilter => _selectedGroupFilter;
  String get selectedChannel => _selectedChannel;
  bool get isBroadcasting => _isBroadcasting;
  Map<String, dynamic> get audiencePreview => _audiencePreview;

  void setTargetCity(String city) {
    _selectedTargetCity = city;
    updateAudiencePreview();
    notifyListeners();
  }

  void setChannel(String ch) {
    _selectedChannel = ch;
    notifyListeners();
  }

  void setBroadcastRadius(double r) {
    _broadcastRadiusKm = r;
    updateAudiencePreview();
    notifyListeners();
  }

  void setRespectTravelRadius(bool val) {
    _respectDonorTravelRadius = val;
    updateAudiencePreview();
    notifyListeners();
  }

  void selectCampForBroadcast(CampModel camp) {
    _selectedCampId = camp.id;
    _selectedTargetCity = camp.city;
    _broadcastRadiusKm = camp.targetRadiusKm;
    onBroadcastCampSelected();
    notifyListeners();
  }

  /// Hook for setting active page when camp is selected
  void onBroadcastCampSelected() {}

  /// Hook for accessing broadcast history list
  List<Map<String, dynamic>> get broadcastHistoryList => [];

  Future<void> updateAudiencePreview() async {
    final preview = await SupabaseService().previewBroadcastAudience(
      campId: _selectedCampId,
      targetCity: _selectedTargetCity,
      radiusKm: _broadcastRadiusKm,
      respectTravelCap: _respectDonorTravelRadius,
      bloodGroup: _selectedGroupFilter,
      channel: _selectedChannel,
    );
    _audiencePreview = preview;
    notifyListeners();
  }

  Future<Map<String, dynamic>> dispatchBroadcast() async {
    final title = broadcastTitleController.text.trim();
    final message = broadcastMsgController.text.trim();
    _isBroadcasting = true;
    notifyListeners();

    try {
      final res = await SupabaseService().broadcastRegionalMessage(
        title: title,
        message: message,
        broadcastType: 'camp_invitation',
        campId: _selectedCampId,
        targetCity: _selectedTargetCity,
        radiusKm: _broadcastRadiusKm,
        respectTravelCap: _respectDonorTravelRadius,
        bloodGroupFilter: _selectedGroupFilter,
        channel: _selectedChannel,
      );

      if (res['success'] == true) {
        final count = res['recipients'] ?? 0;
        final suppressed = res['suppressed'] ?? 0;
        final cost = res['cost_inr'] ?? 0.0;
        broadcastHistoryList.insert(0, {
          'id': 'bcast-${DateTime.now().millisecondsSinceEpoch}',
          'title': title,
          'city': _selectedTargetCity,
          'radius_km': _broadcastRadiusKm,
          'channel': _selectedChannel,
          'recipients_count': count,
          'suppressed_count': suppressed,
          'cost_inr': cost,
          'status': 'sent',
          'created_at': DateTime.now().toIso8601String(),
        });
        updateAudiencePreview();
      }
      return res;
    } finally {
      _isBroadcasting = false;
      notifyListeners();
    }
  }

  void disposeBroadcastControllers() {
    broadcastTitleController.dispose();
    broadcastMsgController.dispose();
  }
}
