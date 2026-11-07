// ============================================================================
// BloodNorms | admin_console_screen.dart
// Executive Operations & Superhero Admin Command Center Screen
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/models/blood_bank_model.dart';
import '../../../shared/models/camp_model.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../widgets/index.dart';

class AdminConsoleScreen extends StatefulWidget {
  const AdminConsoleScreen({super.key});

  @override
  State<AdminConsoleScreen> createState() => _AdminConsoleScreenState();
}

class _AdminConsoleScreenState extends State<AdminConsoleScreen> {
  // Navigation State (Untitled UI Nested Tree)
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

  // --- LIVE & REACTIVE PLATFORM DATA ---
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

  // Interactive 8-Group Stock Matrix (Reactive units for quick adjustments)
  final Map<String, int> _stockMatrix = {
    'A+': 34, 'A-': 12, 'B+': 48, 'B-': 18,
    'O+': 62, 'O-': 8, 'AB+': 22, 'AB-': 6,
  };

  // --- REGIONAL BROADCAST WORKSPACE STATE ---
  final TextEditingController _broadcastTitleController = TextEditingController(
    text: 'Mega Voluntary Blood Camp at Rotary Diamond Hall',
  );
  final TextEditingController _broadcastMsgController = TextEditingController(
    text: 'Dear BloodNorms Hero, a voluntary blood camp is organized this Sunday 9 AM at Rotary Diamond Hall, Main Road. Would you like to attend and donate? Reply YES to confirm.',
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

  @override
  void initState() {
    super.initState();
    _loadAllAdminData();
  }

  @override
  void dispose() {
    _broadcastTitleController.dispose();
    _broadcastMsgController.dispose();
    super.dispose();
  }

  Future<void> _loadAllAdminData() async {
    setState(() => _isLoading = true);
    try {
      final s = SupabaseService();
      final reqs = await s.getActiveRequests();
      final donors = await s.getAllDonors();
      final banks = await s.getNearestBanks(lat: AppConstants.defaultLat, lng: AppConstants.defaultLng);
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

      if (mounted) {
        setState(() {
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
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAudiencePreview() async {
    final preview = await SupabaseService().previewBroadcastAudience(
      campId: _selectedCampId,
      targetCity: _selectedTargetCity,
      radiusKm: _broadcastRadiusKm,
      respectTravelCap: _respectDonorTravelRadius,
      bloodGroup: _selectedGroupFilter,
      channel: _selectedChannel,
    );
    if (mounted) {
      setState(() {
        _audiencePreview = preview;
      });
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: BrandTypography.fontFamily,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: BrandColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _widenRequest(String reqId, double currentKm) async {
    final nextKm = currentKm + 2.0;
    await SupabaseService().widenRequest(reqId, nextKm);
    setState(() {
      final idx = _liveRequests.indexWhere((r) => r['id'].toString() == reqId);
      if (idx != -1) {
        _liveRequests[idx]['current_ring_km'] = nextKm;
        _liveRequests[idx]['donors_contacted'] = (_liveRequests[idx]['donors_contacted'] ?? 0) + 3;
      }
    });
    _showToast('Expanded search ring to ${nextKm.toStringAsFixed(1)} km (+3 donors contacted)');
  }

  Future<void> _closeRequest(String reqId) async {
    await SupabaseService().closeRequest(reqId, outcome: 'admin_closed');
    setState(() {
      _liveRequests.removeWhere((r) => r['id'].toString() == reqId);
      _auditLogs.insert(0, {
        'time': 'Just now',
        'action': 'crisis.resolved',
        'detail': 'Super Admin fulfilled & closed emergency crisis #$reqId',
      });
    });
    _showToast('Emergency crisis fulfilled and closed');
  }

  Future<void> _toggleKillSwitch(bool value) async {
    await SupabaseService().setKillSwitch(value);
    setState(() {
      _killSwitchActive = value;
      _auditLogs.insert(0, {
        'time': 'Just now',
        'action': 'killswitch.toggle',
        'detail': value ? 'Emergency platform killswitch ACTIVATED' : 'Platform killswitch deactivated - normal ops restored',
      });
    });
    _showToast(value ? '🚨 PLATFORM EMERGENCY KILL-SWITCH ACTIVATED' : '✅ Platform operations restored to normal');
  }

  void _adjustStockDirect(String group, int delta) {
    setState(() {
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
      }
    });
    if (_banksList.isNotEmpty) {
      SupabaseService().adjustBankStockQuick(bankId: _banksList.first.id, bloodGroup: group, deltaUnits: delta);
    }
    _showToast('${delta > 0 ? "+$delta" : delta} units of $group adjusted in database');
  }

  Future<void> _toggleRequesterBlock(String phone, bool currentBlocked) async {
    final nextBlocked = !currentBlocked;
    await SupabaseService().setRequesterBlockStatus(phone: phone, isBlocked: nextBlocked, reason: 'Admin manual audit');
    setState(() {
      final idx = _requestersList.indexWhere((r) => r['phone'] == phone);
      if (idx != -1) {
        _requestersList[idx]['is_blocked'] = nextBlocked;
      }
    });
    _showToast(nextBlocked ? 'Blocked $phone from emergency broadcast' : 'Unblocked $phone');
  }

  Future<void> _toggleDonorPause(String donorId, String currentState) async {
    final nextState = currentState == 'active' ? 'paused' : 'active';
    await SupabaseService().updateDonorState(donorId, nextState);
    setState(() {
      final idx = _donorsList.indexWhere((d) => d['id'].toString() == donorId);
      if (idx != -1) {
        _donorsList[idx]['state'] = nextState;
      }
    });
    _showToast('Donor status updated to ${nextState.toUpperCase()}');
  }

  Future<void> _decideApproval(String id, bool approve) async {
    final res = await SupabaseService().decideApprovalRequest(
      requestId: id,
      approve: approve,
      currentUserId: 'super-admin-checker-02',
    );
    if (res['ok'] == true) {
      setState(() {
        _approvalRequests.removeWhere((a) => a['id'].toString() == id);
        _auditLogs.insert(0, {
          'time': 'Just now',
          'action': approve ? 'approval.granted' : 'approval.rejected',
          'detail': '${approve ? "Approved" : "Rejected"} request #$id by Checker',
        });
      });
      _showToast(approve ? 'Approved change request #$id' : 'Rejected change request #$id');
    } else {
      _showToast('Approval action failed: ${res['reason']}');
    }
  }

  Future<void> _dispatchBroadcast() async {
    final title = _broadcastTitleController.text.trim();
    final message = _broadcastMsgController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      _showToast('Please enter both broadcast title and message text.');
      return;
    }

    setState(() => _isBroadcasting = true);
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

    if (mounted) {
      setState(() => _isBroadcasting = false);
      if (res['success'] == true) {
        final count = res['recipients'] ?? 0;
        final suppressed = res['suppressed'] ?? 0;
        final cost = res['cost_inr'] ?? 0.0;
        setState(() {
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
        });
        _showToast('🚀 Broadcast sent to $count donors in $_selectedTargetCity within ${_broadcastRadiusKm.toInt()} km! ($suppressed suppressed, ₹$cost INR)');
        _updateAudiencePreview();
      } else if (res['requires_approval'] == true) {
        final count = res['eligible_count'] ?? 0;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.rule_folder_outlined, color: BrandColors.red),
                SizedBox(width: 8),
                Text('Four-Eyes Approval Required', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            content: Text(
              'Broadcasting to $count recipients exceeds single-admin threshold (>200 donors).\n\nRouted to Four-Eyes Approvals Desk for second-admin verification.',
              style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 13, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => _activePage = 'approvals_queue');
                },
                child: const Text('Go to Approvals Queue', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, color: BrandColors.red)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: BrandColors.red, foregroundColor: Colors.white),
                child: const Text('Acknowledged'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _openQuickActions() {
    showQuickActionsSheet(
      context: context,
      onNavigate: (page) => setState(() => _activePage = page),
      onToggleKillswitch: () => _toggleKillSwitch(!_killSwitchActive),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final showPermanentSidebar = width >= 720;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: showPermanentSidebar
            ? Row(
                children: [
                  AdminSidebar(
                    activePage: _activePage,
                    isSidebarCompact: _isSidebarCompact,
                    expandedCategories: _expandedCategories,
                    onPageSelected: (page) => setState(() => _activePage = page),
                    onToggleCompact: () => setState(() => _isSidebarCompact = !_isSidebarCompact),
                    onToggleCategory: (cat) {
                      setState(() {
                        if (_expandedCategories.contains(cat)) {
                          _expandedCategories.remove(cat);
                        } else {
                          _expandedCategories.add(cat);
                        }
                      });
                    },
                    isPermanent: true,
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: BrandColors.red))
                        : _buildMainWorkspaceCanvas(),
                  ),
                ],
              )
            : Scaffold(
                backgroundColor: const Color(0xFFF4F6FB),
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: const Color(0xFF121316),
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: Text(
                    AdminHeader.getPageTitle(_activePage),
                    style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.sync_rounded, color: Colors.white),
                      onPressed: () {
                        _loadAllAdminData();
                        _showToast('Synced with Supabase');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.bolt_rounded, color: BrandColors.red),
                      onPressed: _openQuickActions,
                    ),
                  ],
                ),
                drawer: Drawer(
                  child: AdminSidebar(
                    activePage: _activePage,
                    isSidebarCompact: false,
                    expandedCategories: _expandedCategories,
                    onPageSelected: (page) => setState(() => _activePage = page),
                    onToggleCompact: () {},
                    onToggleCategory: (cat) {
                      setState(() {
                        if (_expandedCategories.contains(cat)) {
                          _expandedCategories.remove(cat);
                        } else {
                          _expandedCategories.add(cat);
                        }
                      });
                    },
                    isPermanent: false,
                  ),
                ),
                body: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: BrandColors.red))
                    : _buildMainWorkspaceCanvas(),
              ),
      ),
    );
  }

  Widget _buildMainWorkspaceCanvas() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      children: [
        AdminHeader(
          activePage: _activePage,
          onQuickActions: _openQuickActions,
        ),
        const SizedBox(height: 20),
        _buildActiveWorkspacePage(),
      ],
    );
  }

  Widget _buildActiveWorkspacePage() {
    switch (_activePage) {
      case 'dashboard':
        return DashboardCockpitView(
          liveRequests: _liveRequests,
          banksList: _banksList,
          donorsList: _donorsList,
          campsList: _campsList,
          dailySpend: _dailySpend,
          onOpenRadar: () => setState(() => _activePage = 'crisis_radar'),
          onWidenRequest: _widenRequest,
          onCloseRequest: _closeRequest,
        );
      case 'crisis_radar':
        return CrisisRadarView(
          liveRequests: _liveRequests,
          onWidenRequest: _widenRequest,
          onCloseRequest: _closeRequest,
        );
      case 'needs_human':
        return NeedsHumanView(
          liveRequests: _liveRequests,
          onWidenRequest: _widenRequest,
          onCloseRequest: _closeRequest,
        );
      case 'broadcast_dispatch':
      case 'broadcast_audience':
      case 'broadcast_history':
        return RegionalBroadcastView(
          subPage: _activePage,
          audiencePreview: _audiencePreview,
          broadcastHistory: _broadcastHistory,
          selectedTargetCity: _selectedTargetCity,
          selectedChannel: _selectedChannel,
          broadcastRadiusKm: _broadcastRadiusKm,
          respectDonorTravelRadius: _respectDonorTravelRadius,
          broadcastTitleController: _broadcastTitleController,
          broadcastMsgController: _broadcastMsgController,
          isBroadcasting: _isBroadcasting,
          onCityChanged: (city) {
            setState(() => _selectedTargetCity = city);
            _updateAudiencePreview();
          },
          onChannelChanged: (ch) => setState(() => _selectedChannel = ch),
          onRadiusChanged: (r) {
            setState(() => _broadcastRadiusKm = r);
            _updateAudiencePreview();
          },
          onRespectRadiusChanged: (val) {
            setState(() => _respectDonorTravelRadius = val);
            _updateAudiencePreview();
          },
          onDispatch: _dispatchBroadcast,
        );
      case 'voice_simulator':
      case 'voice_prompts':
      case 'voice_safety':
        return AiVoiceStudioView(
          subPage: _activePage,
          onShowToast: _showToast,
        );
      case 'whatsapp_bot':
      case 'whatsapp_templates':
      case 'whatsapp_telecom':
        return WhatsAppCenterView(
          subPage: _activePage,
          onShowToast: _showToast,
        );
      case 'camps_list':
      case 'camps_create':
        return BloodCampsAdminView(
          subPage: _activePage,
          campsList: _campsList,
          banksList: _banksList,
          onNavigateToCreate: () => setState(() => _activePage = 'camps_create'),
          onCampSelectedForBroadcast: (camp) {
            setState(() {
              _selectedCampId = camp.id;
              _selectedTargetCity = camp.city;
              _broadcastRadiusKm = camp.targetRadiusKm;
              _activePage = 'broadcast_dispatch';
            });
          },
          onCampCreated: (newCamp) {
            setState(() {
              _campsList.insert(0, newCamp);
              _activePage = 'camps_list';
            });
          },
          onShowToast: _showToast,
        );
      case 'banks_directory':
      case 'banks_stock':
        return BloodBanksStockView(
          subPage: _activePage,
          banksList: _banksList,
          stockMatrix: _stockMatrix,
          onAdjustStock: _adjustStockDirect,
        );
      case 'donors_list':
      case 'donors_location':
        return DonorsRegistryView(
          subPage: _activePage,
          donorsList: _donorsList,
          onToggleDonorPause: _toggleDonorPause,
          onShowToast: _showToast,
        );
      case 'hospitals_list':
      case 'requester_shield':
      case 'community_partners':
        return DirectoryRegistryView(
          subPage: _activePage,
          hospitalsList: _hospitalsList,
          requestersList: _requestersList,
          partnersList: _partnersList,
          onToggleRequesterBlock: _toggleRequesterBlock,
        );
      case 'approvals_queue':
      case 'data_exports':
      case 'dpdp_registry':
      case 'settings_killswitch':
      case 'settings_algorithm':
      case 'settings_safety':
      case 'settings_audit':
      default:
        return GovernanceViews(
          subPage: _activePage,
          approvalRequests: _approvalRequests,
          dataExports: _dataExports,
          dpdpRequests: _dpdpRequests,
          killSwitchActive: _killSwitchActive,
          safetyIncidents: _safetyIncidents,
          auditLogs: _auditLogs,
          onDecideApproval: _decideApproval,
          onToggleKillSwitch: _toggleKillSwitch,
          onShowToast: _showToast,
        );
    }
  }
}
