// ============================================================================
// BloodNorms | admin_console_controller.dart
// Executive Operations & Superhero Admin Command Center State Controller
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/supabase_service.dart';
import 'admin_broadcast_mixin.dart';
import 'admin_navigation_mixin.dart';
import 'admin_platform_loader.dart';

export 'admin_broadcast_mixin.dart';
export 'admin_navigation_mixin.dart';
export 'admin_platform_loader.dart';

class AdminConsoleController extends ChangeNotifier
    with AdminNavigationMixin, AdminBroadcastMixin {
  bool _killSwitchActive = false;
  bool _isLoading = true;

  // Platform Data
  List<Map<String, dynamic>> _liveRequests = [], _donorsList = [];
  List<BloodBankModel> _banksList = [];
  List<CampModel> _campsList = [];
  final List<Map<String, dynamic>> _auditLogs = [], _broadcastHistory = [];
  List<Map<String, dynamic>> _hospitalsList = [], _requestersList = [];
  List<Map<String, dynamic>> _partnersList = [], _approvalRequests = [];
  List<Map<String, dynamic>> _safetyIncidents = [], _dpdpRequests = [];
  List<Map<String, dynamic>> _dataExports = [];
  Map<String, dynamic> _dailySpend = {};

  final Map<String, int> _stockMatrix = {
    'A+': 34, 'A-': 12, 'B+': 48, 'B-': 18,
    'O+': 62, 'O-': 8, 'AB+': 22, 'AB-': 6,
  };

  // Getters
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

  @override
  List<Map<String, dynamic>> get broadcastHistoryList => _broadcastHistory;

  @override
  void onBroadcastCampSelected() {
    setActivePage('broadcast_dispatch');
  }

  void addCamp(CampModel camp) {
    _campsList.insert(0, camp);
    setActivePage('camps_list');
    notifyListeners();
  }

  Future<void> loadAllAdminData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snap = await AdminPlatformLoader.loadSnapshot();
      _liveRequests = snap.liveRequests;
      _donorsList = snap.donors;
      _banksList = snap.banks;
      _campsList = snap.camps;
      _killSwitchActive = snap.killSwitch;
      _auditLogs.clear();
      _auditLogs.addAll(snap.auditLogs);
      _broadcastHistory.clear();
      _broadcastHistory.addAll(snap.broadcastHistory);
      _hospitalsList = snap.hospitals;
      _requestersList = snap.requesters;
      _partnersList = snap.partners;
      _approvalRequests = snap.approvals;
      _safetyIncidents = snap.incidents;
      _dpdpRequests = snap.dpdp;
      _dataExports = snap.exports;
      _dailySpend = snap.spend;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    _stockMatrix[group] = (current + delta).clamp(0, 999);
    if (_banksList.isNotEmpty) {
      final b = _banksList.first;
      _banksList.first = BloodBankModel(
        id: b.id, name: b.name, address: b.address, city: b.city,
        phones: b.phones, is24x7: b.is24x7, distanceKm: b.distanceKm,
        stockUnits: (b.stockUnits + delta).clamp(0, 9999),
        stockFreshness: b.stockFreshness, trustScore: b.trustScore,
        trustLabel: b.trustLabel, latitude: b.latitude, longitude: b.longitude,
      );
      SupabaseService().adjustBankStockQuick(
        bankId: b.id, bloodGroup: group, deltaUnits: delta,
      );
    }
    notifyListeners();
  }

  Future<void> toggleRequesterBlock(String phone, bool currentBlocked) async {
    final nextBlocked = !currentBlocked;
    await SupabaseService().setRequesterBlockStatus(
      phone: phone, isBlocked: nextBlocked, reason: 'Admin manual audit',
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
      requestId: id, approve: approve, currentUserId: 'super-admin-checker-02',
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

  @override
  void dispose() {
    disposeBroadcastControllers();
    super.dispose();
  }
}
