// ============================================================================
// BloodNorms | admin_console_controller.dart
// Executive Operations & Superhero Admin Command Center State Controller
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/services/supabase_service.dart';

class AdminConsoleController extends ChangeNotifier {
  // Navigation State
  String _activePage = 'dashboard';
  bool _isSidebarCompact = false;
  final Set<String> _expandedCategories = {
    'broadcast',
    'voice',
    'whatsapp',
    'camps',
    'banks',
    'donors',
    'shield',
    'governance',
    'settings',
  };

  bool _killSwitchActive = false;
  bool _isLoading = true;

  // Platform Data
  List<Map<String, dynamic>> _liveRequests = [];
  List<Map<String, dynamic>> _donorsList = [];
  List<BloodBankModel> _banksList = [];
  List<CampModel> _campsList = [];
  List<Map<String, dynamic>> _auditLogs = [];
  List<Map<String, dynamic>> _broadcastHistory = [];
  List<Map<String, dynamic>> _hospitalsList = [];
  List<Map<String, dynamic>> _requestersList = [];
  List<Map<String, dynamic>> _partnersList = [];
  List<Map<String, dynamic>> _approvalRequests = [];
  List<Map<String, dynamic>> _safetyIncidents = [];
  List<Map<String, dynamic>> _dpdpRequests = [];
  List<Map<String, dynamic>> _dataExports = [];
  Map<String, dynamic> _dailySpend = {};

  final Map<String, int> _stockMatrix = {
    'A+': 34,
    'A-': 12,
    'B+': 48,
    'B-': 18,
    'O+': 62,
    'O-': 8,
    'AB+': 22,
    'AB-': 6,
  };

  // Broadcast State
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

  // Getters
  String get activePage => _activePage;
  bool get isSidebarCompact => _isSidebarCompact;
  Set<String> get expandedCategories => _expandedCategories;
  bool get killSwitchActive => _killSwitchActive;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get liveRequests => _liveRequests;
  List<Map<String, dynamic>> get donorsList => _donorsList;
  List<BloodBankModel> get banksList => _banksList;
  List<CampModel> get campsList => _campsList;
  List<Map<String, dynamic>> get auditLogs => _auditLogs;
  List<Map<String, dynamic>> get broadcastHistory => _broadcastHistory;
  List<Map<String, dynamic>> get hospitalsList => _hospitalsList;
  List<Map<String, dynamic>> get requestersList => _requestersList;
  List<Map<String, dynamic>> get partnersList => _partnersList;
  List<Map<String, dynamic>> get approvalRequests => _approvalRequests;
  List<Map<String, dynamic>> get safetyIncidents => _safetyIncidents;
  List<Map<String, dynamic>> get dpdpRequests => _dpdpRequests;
  List<Map<String, dynamic>> get dataExports => _dataExports;
  Map<String, dynamic> get dailySpend => _dailySpend;
  Map<String, int> get stockMatrix => _stockMatrix;
  String? get selectedCampId => _selectedCampId;
  String get selectedTargetCity => _selectedTargetCity;
  double get broadcastRadiusKm => _broadcastRadiusKm;
  bool get respectDonorTravelRadius => _respectDonorTravelRadius;
  String get selectedGroupFilter => _selectedGroupFilter;
  String get selectedChannel => _selectedChannel;
  bool get isBroadcasting => _isBroadcasting;
  Map<String, dynamic> get audiencePreview => _audiencePreview;

  void setActivePage(String page) {
    _activePage = page;
    notifyListeners();
  }

  void toggleSidebarCompact() {
    _isSidebarCompact = !_isSidebarCompact;
    notifyListeners();
  }

  void toggleCategory(String cat) {
    if (_expandedCategories.contains(cat)) {
      _expandedCategories.remove(cat);
    } else {
      _expandedCategories.add(cat);
    }
    notifyListeners();
  }

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
    _activePage = 'broadcast_dispatch';
    notifyListeners();
  }

  void addCamp(CampModel camp) {
    _campsList.insert(0, camp);
    _activePage = 'camps_list';
    notifyListeners();
  }

  Future<void> loadAllAdminData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final s = SupabaseService();
      final reqs = await s.getActiveRequests();
      final donors = await s.getAllDonors();
      final banks = await s.getNearestBanks(
          lat: AppConstants.defaultLat, lng: AppConstants.defaultLng);
      final camps = await s.getCamps();
      final kill = await s.getKillSwitch();
      final audit = await s.getRecentActivityLog();
      final broadcasts = await s.getBroadcastHistory();
      final hospitals = await s.getHospitals();
      final requesters = await s.getRequesterProfiles();
      final partners = await s.getCommunityPartners();
      final approvals = await s.getApprovalRequests();
      final incidents = await s.getSafetyIncidents();
      final dpdp = await s.getDPDPRequests();
      final exports = await s.getDataExports();
      final spend = await s.getDailySpendSummary();

      _liveRequests = reqs;
      _donorsList = donors;
      _banksList = banks;
      _campsList = camps;
      _killSwitchActive = kill;
      _auditLogs = audit;
      _broadcastHistory = broadcasts;
      _hospitalsList = hospitals;
      _requestersList = requesters;
      _partnersList = partners;
      _approvalRequests = approvals;
      _safetyIncidents = incidents;
      _dpdpRequests = dpdp;
      _dataExports = exports;
      _dailySpend = spend;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  Future<void> widenRequest(String reqId, double currentKm) async {
    final nextKm = currentKm + 2.0;
    await SupabaseService().widenRequest(reqId, nextKm);
    final idx = _liveRequests.indexWhere((r) => r['id'].toString() == reqId);
    if (idx != -1) {
      _liveRequests[idx]['current_ring_km'] = nextKm;
      _liveRequests[idx]['donors_contacted'] =
          (_liveRequests[idx]['donors_contacted'] ?? 0) + 3;
    }
    notifyListeners();
  }

  Future<void> closeRequest(String reqId) async {
    await SupabaseService().closeRequest(reqId, outcome: 'admin_closed');
    _liveRequests.removeWhere((r) => r['id'].toString() == reqId);
    _auditLogs.insert(0, {
      'time': 'Just now',
      'action': 'crisis.resolved',
      'detail': 'Super Admin fulfilled & closed emergency crisis #$reqId',
    });
    notifyListeners();
  }

  Future<void> toggleKillSwitch(bool value) async {
    await SupabaseService().setKillSwitch(value);
    _killSwitchActive = value;
    _auditLogs.insert(0, {
      'time': 'Just now',
      'action': 'killswitch.toggle',
      'detail': value
          ? 'Emergency platform killswitch ACTIVATED'
          : 'Platform killswitch deactivated - normal ops restored',
    });
    notifyListeners();
  }

  void adjustStockDirect(String group, int delta) {
    final current = _stockMatrix[group] ?? 0;
    final updated = (current + delta).clamp(0, 999);
    _stockMatrix[group] = updated;

    if (_banksList.isNotEmpty) {
      final b = _banksList.first;
      _banksList.first = BloodBankModel(
        id: b.id,
        name: b.name,
        address: b.address,
        city: b.city,
        phones: b.phones,
        is24x7: b.is24x7,
        distanceKm: b.distanceKm,
        stockUnits: (_banksList.first.stockUnits + delta).clamp(0, 9999),
        stockFreshness: b.stockFreshness,
        trustScore: b.trustScore,
        trustLabel: b.trustLabel,
        latitude: b.latitude,
        longitude: b.longitude,
      );
      SupabaseService().adjustBankStockQuick(
        bankId: _banksList.first.id,
        bloodGroup: group,
        deltaUnits: delta,
      );
    }
    notifyListeners();
  }

  Future<void> toggleRequesterBlock(String phone, bool currentBlocked) async {
    final nextBlocked = !currentBlocked;
    await SupabaseService().setRequesterBlockStatus(
      phone: phone,
      isBlocked: nextBlocked,
      reason: 'Admin manual audit',
    );
    final idx = _requestersList.indexWhere((r) => r['phone'] == phone);
    if (idx != -1) {
      _requestersList[idx]['is_blocked'] = nextBlocked;
    }
    notifyListeners();
  }

  Future<void> toggleDonorPause(String donorId, String currentState) async {
    final nextState = currentState == 'active' ? 'paused' : 'active';
    await SupabaseService().updateDonorState(donorId, nextState);
    final idx = _donorsList.indexWhere((d) => d['id'].toString() == donorId);
    if (idx != -1) {
      _donorsList[idx]['state'] = nextState;
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> decideApproval(String id, bool approve) async {
    final res = await SupabaseService().decideApprovalRequest(
      requestId: id,
      approve: approve,
      currentUserId: 'super-admin-checker-02',
    );
    if (res['ok'] == true) {
      _approvalRequests.removeWhere((a) => a['id'].toString() == id);
      _auditLogs.insert(0, {
        'time': 'Just now',
        'action': approve ? 'approval.granted' : 'approval.rejected',
        'detail': '${approve ? "Approved" : "Rejected"} request #$id by Checker',
      });
      notifyListeners();
    }
    return res;
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
        _broadcastHistory.insert(0, {
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

  @override
  void dispose() {
    broadcastTitleController.dispose();
    broadcastMsgController.dispose();
    super.dispose();
  }
}
