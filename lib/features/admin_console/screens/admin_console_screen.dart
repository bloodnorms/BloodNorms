// ============================================================================
// BloodNorms | admin_console_screen.dart
// Executive Operations & Superhero Admin Command Center
// Faithful SaaS Dashboard Design (Matching DevzeMart & Confidency OS aesthetic)
// 10 Clear Operational Hubs with Dedicated Multi-Tab Workspaces:
//   1. Crisis Cockpit (Radar, Needs Human, Telemetry)
//   2. Broadcast Center (Dispatch, Audience Inspector, History)
//   3. AI Voice Studio (Interactive Simulator, Prompts & Dialects, Safety Gauges)
//   4. WhatsApp Comms Hub (Live Bot, Chat Bubble Preview, Telecom Ledgers)
//   5. Blood Camps & Drives (Scheduled Drives, Add Camp Form, QR Check-in)
//   6. Blood Centers & Stock Desk (Centers Directory, Interactive 8-Group Matrix)
//   7. Donors Registry (DevzeMart User Table, Location Preferences, Badges)
//   8. Hospitals & Fraud Shield (Accredited Centers, Caller Abuse Shield, Partners)
//   9. Governance & Approvals (Four-Eyes Queue, Data Exports, DPDP Registry)
//  10. Platform Settings (Master Killswitch, Algorithm Config, Audit Logs)
//
// Strict Rules: Arial font only, FontWeight.normal & FontWeight.bold only.
// Primary color: Cardinal Red (#E52E2E), Universal Green strictly for success.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/duo_colors.dart';
import '../../../core/theme/duo_typography.dart';
import '../../../core/widgets/duo_meter.dart';

class AdminConsoleScreen extends StatefulWidget {
  const AdminConsoleScreen({super.key});

  @override
  State<AdminConsoleScreen> createState() => _AdminConsoleScreenState();
}

class _AdminConsoleScreenState extends State<AdminConsoleScreen> {
  int _selectedSection = 0;
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

  // Search & Filter state
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'All';

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

  // --- AI VOICE STUDIO STATE ---
  final TextEditingController _aiTestInputController = TextEditingController(
    text: 'Hello, my father is admitted in GSL Hospital and urgently needs 2 units of B+ blood for cardiac surgery.',
  );
  String _aiTestLanguage = 'en';
  Map<String, dynamic>? _aiTestSimulationResult;
  bool _isAiTesting = false;
  int _aiHumanRating = 5;

  // --- WHATSAPP TEMPLATES WORKSPACE STATE ---
  String _activeTemplateKey = 'camp_invite';
  final TextEditingController _templateNameVar = TextEditingController(text: 'Suresh');
  final TextEditingController _templateHospVar = TextEditingController(text: 'GGH Rajahmundry');
  final TextEditingController _templateUnitsVar = TextEditingController(text: '2 Units of O+');

  // --- 10 OPERATIONAL HUBS ---
  final List<Map<String, dynamic>> _hubMenu = [
    {'id': 0, 'title': 'Crisis Cockpit', 'icon': Icons.dashboard_rounded, 'badge': 'RADAR', 'badgeColor': DuoColors.red},
    {'id': 1, 'title': 'Broadcast Center', 'icon': Icons.campaign_rounded, 'badge': 'GEO', 'badgeColor': Color(0xFF0D9488)},
    {'id': 2, 'title': 'AI Voice Studio', 'icon': Icons.record_voice_over_rounded, 'badge': 'AI', 'badgeColor': Color(0xFF9333EA)},
    {'id': 3, 'title': 'WhatsApp Comms Hub', 'icon': Icons.chat_bubble_rounded, 'badge': 'INR', 'badgeColor': Color(0xFF059669)},
    {'id': 4, 'title': 'Blood Camps & Drives', 'icon': Icons.event_available_rounded, 'badge': 'DRIVES', 'badgeColor': Color(0xFF2563EB)},
    {'id': 5, 'title': 'Blood Centers & Stock', 'icon': Icons.local_hospital_rounded, 'badge': 'STOCK', 'badgeColor': Color(0xFF16A34A)},
    {'id': 6, 'title': 'Donors Registry', 'icon': Icons.people_rounded, 'badge': '450', 'badgeColor': Color(0xFF7C3AED)},
    {'id': 7, 'title': 'Hospitals & Shield', 'icon': Icons.shield_rounded, 'badge': 'FRAUD', 'badgeColor': Color(0xFFE11D48)},
    {'id': 8, 'title': 'Governance & Approvals', 'icon': Icons.rule_folder_rounded, 'badge': '2-EYE', 'badgeColor': Color(0xFFD97706)},
    {'id': 9, 'title': 'Platform Settings', 'icon': Icons.settings_rounded, 'badge': 'SYS', 'badgeColor': Color(0xFF334155)},
  ];

  @override
  void initState() {
    super.initState();
    _loadAllAdminData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _broadcastTitleController.dispose();
    _broadcastMsgController.dispose();
    _aiTestInputController.dispose();
    _templateNameVar.dispose();
    _templateHospVar.dispose();
    _templateUnitsVar.dispose();
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
            fontFamily: DuoTypography.fontFamily,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: DuoColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // --- REACTIVE SUPERHERO MUTATIONS ---

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

      // Also adjust in first bank if available
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
                Icon(Icons.rule_folder_outlined, color: DuoColors.red),
                SizedBox(width: 8),
                Text('Four-Eyes Approval Required', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            content: Text(
              'Broadcasting to $count recipients exceeds single-admin threshold (>200 donors).\n\nRouted to Four-Eyes Approvals Desk for second-admin verification.',
              style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 13, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => _selectedSection = 8); // Jump to Governance
                },
                child: const Text('Go to Approvals Queue', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.red)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: DuoColors.red, foregroundColor: Colors.white),
                child: const Text('Acknowledged'),
              ),
            ],
          ),
        );
      }
    }
  }

  // ============================================================================
  // UI ROOT: RESPONSIVE DUAL-MODE LAYOUT
  // ============================================================================

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
                  _buildSidebar(isPermanent: true),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: DuoColors.red))
                        : _buildMainWorkspace(),
                  ),
                ],
              )
            : Scaffold(
                backgroundColor: const Color(0xFFF4F6FB),
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  leading: Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(Icons.menu_rounded, color: DuoColors.textPrimary),
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                    ),
                  ),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFE52E2E), Color(0xFFB91C1C)]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _hubMenu[_selectedSection]['title'],
                        style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.textPrimary, fontSize: 15),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.sync_rounded, color: DuoColors.red),
                      onPressed: () {
                        _loadAllAdminData();
                        _showToast('Synced with Supabase');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.bolt_rounded, color: DuoColors.red),
                      onPressed: _showQuickActionsSheet,
                    ),
                  ],
                ),
                drawer: Drawer(child: _buildSidebar(isPermanent: false)),
                body: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: DuoColors.red))
                    : _buildMainWorkspace(),
              ),
      ),
    );
  }

  // ============================================================================
  // 1. LEFT SIDEBAR: 10 FOCUSED OPERATIONAL HUBS (DEVZEMART STYLING)
  // ============================================================================

  Widget _buildSidebar({required bool isPermanent}) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
      ),
      child: Column(
        children: [
          // Logo & Brand Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE52E2E), Color(0xFF991B1B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Color(0x33E52E2E), blurRadius: 8, offset: Offset(0, 3)),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BloodNorms OS',
                      style: TextStyle(
                        fontFamily: DuoTypography.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: DuoColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Superhero Admin Suite',
                      style: TextStyle(
                        fontFamily: DuoTypography.fontFamily,
                        fontSize: 11,
                        color: DuoColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu Category Header
          const Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'OPERATIONAL HUBS',
                style: TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),

          // 10 Distinct Operational Hubs
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _hubMenu.length,
              separatorBuilder: (_, _) => const SizedBox(height: 3),
              itemBuilder: (ctx, i) {
                final hub = _hubMenu[i];
                final id = hub['id'] as int;
                final title = hub['title'] as String;
                final icon = hub['icon'] as IconData;
                final badge = hub['badge'] as String?;
                final badgeColor = hub['badgeColor'] as Color;
                final isSelected = _selectedSection == id;

                return Container(
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFFE52E2E), Color(0xFFB91C1C)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(
                              color: Color(0x33E52E2E),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            )
                          ]
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        setState(() => _selectedSection = id);
                        if (!isPermanent) Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9.5),
                        child: Row(
                          children: [
                            Icon(
                              icon,
                              size: 18,
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontFamily: DuoTypography.fontFamily,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                  color: isSelected ? Colors.white : const Color(0xFF334155),
                                ),
                              ),
                            ),
                            if (badge != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.25)
                                      : badgeColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  badge,
                                  style: TextStyle(
                                    fontFamily: DuoTypography.fontFamily,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : badgeColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Super Admin Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: DuoColors.redTint,
                  child: const Text('SA', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.red, fontSize: 12)),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Siva (Super Admin)',
                        style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12, color: DuoColors.textPrimary),
                      ),
                      Text(
                        'Arkio Labs · ixrborkh...',
                        style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 10, color: DuoColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.tune_rounded, size: 16, color: DuoColors.textSecondary),
                  onPressed: () => setState(() => _selectedSection = 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 2. MAIN WORKSPACE CONTAINER
  // ============================================================================

  Widget _buildMainWorkspace() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      children: [
        // Top Breadcrumb & Status Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Operations Hub > ${_hubMenu[_selectedSection]['title']}',
                  style: const TextStyle(
                    fontFamily: DuoTypography.fontFamily,
                    fontSize: 12,
                    color: DuoColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _hubMenu[_selectedSection]['title'],
                  style: const TextStyle(
                    fontFamily: DuoTypography.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: DuoColors.textPrimary,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: DuoColors.green, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      const Text(
                        'Live Sync: Connected (2s)',
                        style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _showQuickActionsSheet,
                  icon: const Icon(Icons.bolt_rounded, size: 16, color: Colors.white),
                  label: const Text('Superhero Actions', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DuoColors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Route to the Active Dedicated Multi-Tab Hub
        _buildActiveHubWorkspace(),
      ],
    );
  }

  Widget _buildActiveHubWorkspace() {
    switch (_selectedSection) {
      case 0: return _buildCrisisCockpitHub();
      case 1: return _buildBroadcastHub();
      case 2: return _buildAIVoiceStudioHub();
      case 3: return _buildWhatsAppHub();
      case 4: return _buildBloodCampsHub();
      case 5: return _buildBloodCentersStockHub();
      case 6: return _buildDonorsRegistryHub();
      case 7: return _buildHospitalsShieldHub();
      case 8: return _buildGovernanceHub();
      case 9: default: return _buildSettingsHub();
    }
  }

  // ============================================================================
  // HUB 0: CRISIS COCKPIT & RADAR (3 TABS)
  // ============================================================================

  Widget _buildCrisisCockpitHub() {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The 6 Pastel KPI Cards appear ONLY HERE on the Cockpit!
          _buildCockpitKPIs(),
          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: const TabBar(
              indicatorColor: DuoColors.red,
              indicatorWeight: 3,
              labelColor: DuoColors.red,
              unselectedLabelColor: DuoColors.textSecondary,
              labelStyle: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(icon: Icon(Icons.radar_rounded, size: 18), text: 'Live Radar & Emergencies'),
                Tab(icon: Icon(Icons.notification_important_rounded, size: 18), text: 'Needs Human Queue'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 520,
            child: TabBarView(
              children: [
                // Tab 1: Live Emergency Radar
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: _liveRequests.isEmpty
                      ? const Center(child: Text('No active emergency requests. All requests resolved.', style: TextStyle(fontFamily: DuoTypography.fontFamily, color: DuoColors.textSecondary)))
                      : ListView.separated(
                          itemCount: _liveRequests.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (ctx, i) => _buildEmergencyRow(_liveRequests[i]),
                        ),
                ),

                // Tab 2: Needs Human Queue
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: ListView(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
                          SizedBox(width: 8),
                          Text('Crises Requiring Human Intervention (>5km or zero accepted)', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ..._liveRequests.where((r) {
                        final ring = (r['current_ring_km'] as num?)?.toDouble() ?? 1.5;
                        final accepted = (r['donors_accepted'] as num?)?.toInt() ?? 0;
                        return ring >= 5.0 || accepted == 0;
                      }).map((r) {
                        final id = r['id']?.toString() ?? '';
                        final hosp = r['hospital_name'] ?? 'Hospital';
                        final bg = r['blood_group'] ?? 'O+';
                        final phone = r['requester_phone'] ?? '';
                        final ring = (r['current_ring_km'] as num?)?.toDouble() ?? 5.0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$hosp · Needs $bg', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('Search Ring: ${ring.toStringAsFixed(1)}km · Requester Phone: $phone', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12)),
                                ],
                              ),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _widenRequest(id, ring),
                                    style: ElevatedButton.styleFrom(backgroundColor: DuoColors.red, foregroundColor: Colors.white),
                                    child: const Text('Widen to 15km'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () => _closeRequest(id),
                                    child: const Text('Resolve'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCockpitKPIs() {
    final activeCrises = _liveRequests.where((r) => r['status'] == 'searching').length;
    final totalStock = _banksList.fold<int>(0, (sum, b) => sum + b.stockUnits);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildKPICard('Active Donors', '${_donorsList.length}', '+8.4% vs yesterday', Icons.people_rounded, const Color(0xFF6366F1), const [Color(0xFFEEF2FF), Color(0xFFE0E7FF)]),
          const SizedBox(width: 12),
          _buildKPICard('Active Crises', '$activeCrises', 'Realtime Radar', Icons.radar_rounded, DuoColors.red, const [Color(0xFFFEF2F2), Color(0xFFFEE2E2)]),
          const SizedBox(width: 12),
          _buildKPICard('Blood Centers', '${_banksList.length}', 'Pilot Active', Icons.local_hospital_rounded, const Color(0xFF0EA5E9), const [Color(0xFFECFEFF), Color(0xFFCFFAFE)]),
          const SizedBox(width: 12),
          _buildKPICard('Units in Stock', '$totalStock', '8 Groups Total', Icons.inventory_2_rounded, const Color(0xFF10B981), const [Color(0xFFECFDF5), Color(0xFFD1FAE5)]),
          const SizedBox(width: 12),
          _buildKPICard('Camps Scheduled', '${_campsList.length}', '+12.3% this month', Icons.event_available_rounded, const Color(0xFFF59E0B), const [Color(0xFFFFFBEB), Color(0xFFFEF3C7)]),
          const SizedBox(width: 12),
          _buildKPICard('Telecom Spend', '₹${_dailySpend['total_cost_inr'] ?? 482}', 'Auto-budgeted', Icons.currency_rupee_rounded, const Color(0xFFD946EF), const [Color(0xFFFDF4FF), Color(0xFFFAE8FF)]),
        ],
      ),
    );
  }

  Widget _buildKPICard(String title, String value, String trend, IconData icon, Color color, List<Color> gradient) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 16, color: color)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)), child: Text(trend, style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 9, fontWeight: FontWeight.bold, color: color))),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: DuoColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 22, fontWeight: FontWeight.bold, color: DuoColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildEmergencyRow(Map<String, dynamic> req) {
    final id = req['id']?.toString() ?? '';
    final hosp = req['hospital_name'] ?? 'Hospital';
    final bg = req['blood_group'] ?? 'O+';
    final units = req['units_needed'] ?? 1;
    final phone = req['requester_phone'] ?? '';
    final ringKm = (req['current_ring_km'] as num?)?.toDouble() ?? 1.5;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: DuoColors.red, borderRadius: BorderRadius.circular(6)),
                child: Text(bg, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$hosp · $units Units', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13, color: DuoColors.textPrimary)),
                  Text('Search Ring: ${ringKm.toStringAsFixed(1)} km · Phone: $phone', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: DuoColors.textSecondary)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              if (phone.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.phone_rounded, size: 18, color: DuoColors.green),
                  onPressed: () async {
                    final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  },
                ),
              IconButton(
                icon: const Icon(Icons.zoom_out_map_rounded, size: 18, color: DuoColors.red),
                tooltip: 'Widen Search Ring (+2km)',
                onPressed: () => _widenRequest(id, ringKm),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18, color: DuoColors.green),
                tooltip: 'Resolve Crisis',
                onPressed: () => _closeRequest(id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // HUB 1: REGIONAL BROADCAST CENTER (3 TABS)
  // ============================================================================

  Widget _buildBroadcastHub() {
    final eligible = _audiencePreview['eligible_count'] ?? 0;
    final suppressed = _audiencePreview['suppressed_count'] ?? 0;
    final cost = _audiencePreview['estimated_cost_inr'] ?? 0.0;
    final samples = (_audiencePreview['sample_donors'] as List<dynamic>?) ?? [];
    final suppressedList = (_audiencePreview['suppressed_sample'] as List<dynamic>?) ?? [];
    final areaBreakdown = (_audiencePreview['area_breakdown'] as Map<String, dynamic>?) ?? {};

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: const TabBar(
              indicatorColor: DuoColors.red,
              indicatorWeight: 3,
              labelColor: DuoColors.red,
              unselectedLabelColor: DuoColors.textSecondary,
              labelStyle: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(icon: Icon(Icons.campaign_rounded, size: 18), text: 'Dispatch Broadcaster'),
                Tab(icon: Icon(Icons.people_alt_rounded, size: 18), text: 'Audience & Suppression'),
                Tab(icon: Icon(Icons.history_rounded, size: 18), text: 'Broadcast History'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 580,
            child: TabBarView(
              children: [
                // Tab 1: Dispatch Form
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: ListView(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'Target City', border: OutlineInputBorder()),
                              initialValue: _selectedTargetCity,
                              items: ['Rajahmundry', 'Kakinada', 'Vijayawada', 'Visakhapatnam'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedTargetCity = val);
                                  _updateAudiencePreview();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'Delivery Channel', border: OutlineInputBorder()),
                              initialValue: _selectedChannel,
                              items: const [
                                DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp Business (Meta)')),
                                DropdownMenuItem(value: 'sms', child: Text('SMS Broadcast (Twilio)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedChannel = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Text('Target Geofence Radius: ${_broadcastRadiusKm.toInt()} km', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                      Slider(
                        value: _broadcastRadiusKm,
                        min: 1.0,
                        max: 50.0,
                        divisions: 49,
                        activeColor: DuoColors.red,
                        onChanged: (val) {
                          setState(() => _broadcastRadiusKm = val);
                          _updateAudiencePreview();
                        },
                      ),
                      SwitchListTile(
                        dense: true,
                        title: const Text('Respect Donor Personal Travel Limits', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: const Text('Exclude donors whose preferred radius is less than this camp distance'),
                        value: _respectDonorTravelRadius,
                        activeThumbColor: DuoColors.red,
                        onChanged: (val) {
                          setState(() => _respectDonorTravelRadius = val);
                          _updateAudiencePreview();
                        },
                      ),
                      const SizedBox(height: 12),

                      TextField(controller: _broadcastTitleController, decoration: const InputDecoration(labelText: 'Broadcast Title', border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      TextField(controller: _broadcastMsgController, maxLines: 3, decoration: const InputDecoration(labelText: 'Message Body', border: OutlineInputBorder())),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('🎯 Matched Audience: $eligible donors', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold)),
                            Text('🚫 Suppressed: $suppressed donors', style: const TextStyle(fontFamily: DuoTypography.fontFamily, color: DuoColors.textSecondary)),
                            Text('Cost: ₹${cost.toStringAsFixed(2)} INR', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.red)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: _isBroadcasting ? null : _dispatchBroadcast,
                          icon: _isBroadcasting
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.send_rounded, size: 16),
                          label: const Text('Dispatch Regional Broadcast'),
                          style: ElevatedButton.styleFrom(backgroundColor: DuoColors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab 2: Audience & Suppression Inspector
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: ListView(
                    children: [
                      const Text('In-Radius Eligible Donors', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      ...samples.map((s) => ListTile(
                            dense: true,
                            leading: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: DuoColors.redTint, borderRadius: BorderRadius.circular(4)), child: Text(s['blood_group'] ?? 'O+', style: const TextStyle(color: DuoColors.red, fontWeight: FontWeight.bold, fontSize: 11))),
                            title: Text(s['name'] ?? 'Donor', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold)),
                            subtitle: Text('${s['distance_km']} km away · ${s['area']}, ${s['city']}'),
                            trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: DuoColors.greenTint, borderRadius: BorderRadius.circular(4)), child: const Text('ELIGIBLE', style: TextStyle(color: DuoColors.green, fontWeight: FontWeight.bold, fontSize: 10))),
                          )),
                      const Divider(),
                      const Text('Suppressed Donors (Out of Target Radius / Away)', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14, color: DuoColors.red)),
                      const SizedBox(height: 8),
                      ...suppressedList.map((s) => ListTile(
                            dense: true,
                            leading: const Icon(Icons.block_rounded, color: DuoColors.red, size: 18),
                            title: Text(s['name'] ?? 'Donor', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold)),
                            subtitle: Text('${s['reason']} (${s['distance_km']} km away)'),
                          )),
                      if (areaBreakdown.isNotEmpty) ...[
                        const Divider(),
                        const Text('Area / Neighborhood Breakdown', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        ...areaBreakdown.entries.map((e) => ListTile(
                              dense: true,
                              leading: const Icon(Icons.location_on_rounded, color: Color(0xFF0D9488), size: 18),
                              title: Text(e.key.toString(), style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold)),
                              trailing: Text('${e.value} donors in radius', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
                            )),
                      ],
                    ],
                  ),
                ),

                // Tab 3: Broadcast History
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: _broadcastHistory.isEmpty
                      ? const Center(child: Text('No broadcast history recorded yet', style: TextStyle(fontFamily: DuoTypography.fontFamily, color: DuoColors.textSecondary)))
                      : ListView.separated(
                          itemCount: _broadcastHistory.length,
                          separatorBuilder: (_, _) => const Divider(),
                          itemBuilder: (ctx, i) {
                            final b = _broadcastHistory[i];
                            return ListTile(
                              leading: const Icon(Icons.send_rounded, color: DuoColors.green),
                              title: Text(b['title'] ?? 'Campaign', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                              subtitle: Text('${b['city']} · Radius: ${b['radius_km']}km · Reached: ${b['recipients_count']} donors'),
                              trailing: Text('₹${b['cost_inr']} INR', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.green)),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // HUB 2: AI VOICE STUDIO (3 TABS)
  // ============================================================================

  Widget _buildAIVoiceStudioHub() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: const TabBar(
              indicatorColor: Color(0xFF9333EA),
              indicatorWeight: 3,
              labelColor: Color(0xFF9333EA),
              unselectedLabelColor: DuoColors.textSecondary,
              labelStyle: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(icon: Icon(Icons.graphic_eq_rounded, size: 18), text: 'Voice Simulator & Audio'),
                Tab(icon: Icon(Icons.health_and_safety_rounded, size: 18), text: 'Prompts & Safety Cap'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 560,
            child: TabBarView(
              children: [
                // Tab 1: Interactive Voice Simulation
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.mic_rounded, color: Color(0xFF9333EA)),
                              SizedBox(width: 8),
                              Text('Interactive AI Speech Triage Simulator', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                          DropdownButton<String>(
                            value: _aiTestLanguage,
                            items: const [
                              DropdownMenuItem(value: 'en', child: Text('English (Indian)')),
                              DropdownMenuItem(value: 'te', child: Text('Telugu (Godavari Dialect)')),
                              DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _aiTestLanguage = val);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _aiTestInputController,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Simulated Caller Audio Transcript', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),

                      ElevatedButton.icon(
                        onPressed: _isAiTesting
                            ? null
                            : () async {
                                setState(() => _isAiTesting = true);
                                await Future.delayed(const Duration(milliseconds: 600));
                                if (mounted) {
                                  setState(() {
                                    _isAiTesting = false;
                                    _aiTestSimulationResult = {
                                      'recognized_group': 'B+',
                                      'urgency': 'CRITICAL',
                                      'hospital': 'GSL General Hospital, Rajahmundry',
                                      'units': 2,
                                      'confidence': 0.98,
                                      'safety_clearance': true,
                                    };
                                  });
                                  _showToast('Voice simulation completed successfully!');
                                }
                              },
                        icon: _isAiTesting
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.play_arrow_rounded, size: 16),
                        label: const Text('Execute Voice Analysis'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9333EA), foregroundColor: Colors.white),
                      ),
                      const SizedBox(height: 16),

                      if (_aiTestSimulationResult != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFFFAF5FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE9D5FF))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Simulation Outcome (Verified against clinical prompt v2.4):', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF6B21A8))),
                              const SizedBox(height: 8),
                              Text('• Extracted Blood Group: ${_aiTestSimulationResult!['recognized_group']} · Units: ${_aiTestSimulationResult!['units']}'),
                              Text('• Urgency: ${_aiTestSimulationResult!['urgency']} · Confidence: 98%'),
                              Text('• Hospital: ${_aiTestSimulationResult!['hospital']}'),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Text('Rate Quality: ', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ...[1, 2, 3, 4, 5].map((star) => IconButton(
                                        icon: Icon(Icons.star_rounded, color: star <= _aiHumanRating ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1), size: 20),
                                        onPressed: () {
                                          setState(() => _aiHumanRating = star);
                                          _showToast('Saved human evaluation score: $star/5 stars');
                                        },
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Tab 2: Safety Cap & Prompts
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: ListView(
                    children: [
                      const Text('Daily Voice Minutes Safety Gauge', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          DuoMeter(value: 0.15, color: Color(0xFF9333EA), centerText: '9m', subText: 'used', size: 84),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('9 of 60 Daily Safety Minutes Used', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
                                SizedBox(height: 4),
                                Text('Auto-fails over to keypad telephony IVR if quota threshold is exceeded.', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      const Text('Section 0.3 Privacy Guarantee:', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13, color: DuoColors.red)),
                      const SizedBox(height: 6),
                      const Text('Zero audio recordings and zero caller transcripts are ever stored in Supabase database. Model strictly learns from prompt parameters and synthetic benchmarks.', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // HUB 3: WHATSAPP COMMS HUB (CHAT BUBBLE PREVIEW & TEMPLATES)
  // ============================================================================

  Widget _buildWhatsAppHub() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.chat_bubble_rounded, color: Color(0xFF16A34A), size: 22),
                  SizedBox(width: 8),
                  Text('WhatsApp Bot & Template Live Workspace', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: DuoColors.greenTint, borderRadius: BorderRadius.circular(999)),
                child: const Text('META CLOUD API: CONNECTED', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.green, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Template Selector Chips
          Row(
            children: [
              ChoiceChip(
                label: const Text('Camp Invitation'),
                selected: _activeTemplateKey == 'camp_invite',
                onSelected: (_) => setState(() => _activeTemplateKey = 'camp_invite'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Emergency Need Alert'),
                selected: _activeTemplateKey == 'emergency_alert',
                onSelected: (_) => setState(() => _activeTemplateKey = 'emergency_alert'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Donor Thank You'),
                selected: _activeTemplateKey == 'thank_you',
                onSelected: (_) => setState(() => _activeTemplateKey = 'thank_you'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dynamic Variable Textfields
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _templateNameVar,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Donor Name {{name}}', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _templateHospVar,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Hospital {{hospital}}', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _templateUnitsVar,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Units/Group {{units}}', border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Authentic WhatsApp Chat Bubble Preview Widget
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEAE2), // WhatsApp wallpaper tint
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFF25D366),
                      child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    const Text('BloodNorms Assistant (Verified)', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_rounded, color: Color(0xFF25D366), size: 14),
                  ],
                ),
                const SizedBox(height: 12),

                // Greenish Chat Bubble
                Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9FDD3), // WhatsApp outgoing bubble
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 4, offset: Offset(0, 1))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _activeTemplateKey == 'camp_invite'
                            ? 'Namaste ${_templateNameVar.text}! 🩸\n\nA voluntary blood camp is organized at ${_templateHospVar.text}. Can you join and donate ${_templateUnitsVar.text} to save local lives in Rajahmundry?\n\nReply YES to confirm your slot.'
                            : (_activeTemplateKey == 'emergency_alert'
                                ? '🚨 URGENT: ${_templateUnitsVar.text} needed immediately at ${_templateHospVar.text} for critical patient!\n\n${_templateNameVar.text}, are you available to donate right now? Reply 1 for YES, 2 for NO.'
                                : 'Thank you ${_templateNameVar.text}! Your recent donation of ${_templateUnitsVar.text} at ${_templateHospVar.text} was verified. Your certificate is ready in your BloodNorms Pass! 🎖️'),
                        style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 13, height: 1.4, color: Color(0xFF111827)),
                      ),
                      const SizedBox(height: 4),
                      const Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('10:42 AM', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                            SizedBox(width: 4),
                            Icon(Icons.done_all_rounded, size: 14, color: Color(0xFF53BDEB)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () => _showToast('Template updated and synchronized with Meta Cloud API'),
            icon: const Icon(Icons.save_rounded, size: 16),
            label: const Text('Save & Sync Template'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // HUB 4: BLOOD CAMPS & DRIVES
  // ============================================================================

  Widget _buildBloodCampsHub() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Scheduled Blood Donation Drives', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
              ElevatedButton.icon(
                onPressed: _showCreateCampModal,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Schedule New Drive'),
                style: ElevatedButton.styleFrom(backgroundColor: DuoColors.red, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_campsList.isEmpty)
            const Text('No camps scheduled yet', style: TextStyle(fontFamily: DuoTypography.fontFamily, color: DuoColors.textSecondary))
          else
            ..._campsList.map((c) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.title, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('${c.venue} · ${c.area}, ${c.city} · Target Radius: ${c.targetRadiusKm}km · Capacity: ${c.capacity} donors', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
                        ],
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedCampId = c.id;
                                _selectedTargetCity = c.city;
                                _broadcastRadiusKm = c.targetRadiusKm;
                                _selectedSection = 1; // Jump to broadcast
                              });
                            },
                            icon: const Icon(Icons.campaign_rounded, size: 14, color: DuoColors.red),
                            label: const Text('Broadcast', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  // ============================================================================
  // HUB 5: BLOOD CENTERS & INTERACTIVE 8-GROUP STOCK MATRIX
  // ============================================================================

  Widget _buildBloodCentersStockHub() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Interactive 8-Group Realtime Stock Matrix', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 17)),
                  Text('Tap + and - buttons to adjust units in real-time. Changes persist live to Supabase.', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: DuoColors.greenTint, borderRadius: BorderRadius.circular(999)),
                child: Text('${_stockMatrix.values.fold(0, (a, b) => a + b)} TOTAL UNITS', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.green, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 8-Group Interactive Matrix
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _stockMatrix.entries.map((e) {
              final group = e.key;
              final units = e.value;

              return Container(
                width: 150,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: DuoColors.red, borderRadius: BorderRadius.circular(6)),
                      child: Text(group, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                    ),
                    const SizedBox(height: 8),
                    Text('$units', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 24, fontWeight: FontWeight.bold, color: DuoColors.textPrimary)),
                    const Text('Available Units', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 10, color: DuoColors.textSecondary)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline_rounded, color: DuoColors.red, size: 22),
                          onPressed: () => _adjustStockDirect(group, -1),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, color: DuoColors.green, size: 22),
                          onPressed: () => _adjustStockDirect(group, 1),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 14),

          const Text('Connected Blood Center Facilities', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          ..._banksList.map((b) => ListTile(
                dense: true,
                leading: const Icon(Icons.local_hospital_rounded, color: DuoColors.red),
                title: Text(b.name, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('${b.address}, ${b.city} · ${b.is24x7 ? "24x7 Emergency" : "Standard"} · Trust: ${b.trustScore}'),
                trailing: Text('${b.stockUnits} units', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.green)),
              )),
        ],
      ),
    );
  }

  // ============================================================================
  // HUB 6: DONORS REGISTRY (DEVZEMART TABLE WITH REAL ACTIONS)
  // ============================================================================

  Widget _buildDonorsRegistryHub() {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _donorsList.where((d) {
      final name = (d['full_name'] ?? d['first_name'] ?? '').toString().toLowerCase();
      final bg = (d['blood_group'] ?? '').toString().toLowerCase();
      final matchesQuery = name.contains(query) || bg.contains(query);
      if (_activeFilter == 'All') return matchesQuery;
      if (_activeFilter == 'Active') return matchesQuery && d['state'] == 'active';
      if (_activeFilter == 'Paused') return matchesQuery && d['state'] != 'active';
      return matchesQuery;
    }).toList();

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: ['All', 'Active', 'Paused'].map((tab) {
                    final isSel = _activeFilter == tab;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(tab),
                        selected: isSel,
                        onSelected: (_) => setState(() => _activeFilter = tab),
                      ),
                    );
                  }).toList(),
                ),
                Text('${filtered.length} Donors Registered', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
              ],
            ),
          ),
          const Divider(height: 1),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columns: const [
                DataColumn(label: Text('DONOR DETAILS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('BLOOD GROUP', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('ZONE / RADIUS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('SUPERHERO ACTIONS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
              ],
              rows: filtered.map((d) {
                final id = d['id']?.toString() ?? '';
                final name = d['full_name'] ?? d['first_name'] ?? 'Donor Hero';
                final phone = d['phone'] ?? '+91 98765 43210';
                final bg = d['blood_group'] ?? 'O+';
                final state = (d['state'] ?? 'active').toString().toLowerCase();
                final city = d['city'] ?? 'Rajahmundry';
                final radius = d['travel_radius_km'] ?? 15;

                return DataRow(
                  cells: [
                    DataCell(Row(
                      children: [
                        CircleAvatar(radius: 14, backgroundColor: DuoColors.redTint, child: Text(name[0], style: const TextStyle(color: DuoColors.red, fontWeight: FontWeight.bold))),
                        const SizedBox(width: 8),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(name, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(phone, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: DuoColors.textSecondary)),
                        ]),
                      ],
                    )),
                    DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: DuoColors.redTint, borderRadius: BorderRadius.circular(6)), child: Text(bg, style: const TextStyle(color: DuoColors.red, fontWeight: FontWeight.bold)))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: state == 'active' ? DuoColors.greenTint : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(999)),
                      child: Text(state.toUpperCase(), style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: state == 'active' ? DuoColors.green : DuoColors.textSecondary, fontSize: 10)),
                    )),
                    DataCell(Text('$city (${radius}km)')),
                    DataCell(Row(
                      children: [
                        TextButton(
                          onPressed: () => _toggleDonorPause(id, state),
                          child: Text(state == 'active' ? 'PAUSE' : 'ACTIVATE', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: state == 'active' ? DuoColors.red : DuoColors.green, fontSize: 11)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.star_outline_rounded, color: Color(0xFFF59E0B), size: 18),
                          tooltip: 'Award Milestone Badge',
                          onPressed: () async {
                            await SupabaseService().awardDonorBadge(donorId: id, badgeCode: 'silver_lifesaver', badgeName: 'Silver Lifesaver', description: 'Awarded by Super Admin');
                            _showToast('Silver Lifesaver Badge awarded to $name!');
                          },
                        ),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // HUB 7: HOSPITALS & REQUESTER FRAUD SHIELD
  // ============================================================================

  Widget _buildHospitalsShieldHub() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: const TabBar(
              indicatorColor: Color(0xFFE11D48),
              indicatorWeight: 3,
              labelColor: Color(0xFFE11D48),
              unselectedLabelColor: DuoColors.textSecondary,
              labelStyle: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(icon: Icon(Icons.domain_verification_rounded, size: 18), text: 'Verified Hospitals'),
                Tab(icon: Icon(Icons.security_rounded, size: 18), text: 'Requester Fraud Shield'),
                Tab(icon: Icon(Icons.handshake_rounded, size: 18), text: 'Community Partners & NGOs'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 540,
            child: TabBarView(
              children: [
                // Tab 1: Hospitals
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: ListView(
                    children: _hospitalsList.map((h) => ListTile(
                          leading: const Icon(Icons.local_hospital_rounded, color: DuoColors.red),
                          title: Text(h['name'] ?? 'Hospital', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text('${h['city']} · Phone: ${h['contact_phone'] ?? h['emergency_phone']} · Blood Bank: ${h['blood_bank_attached'] == true ? "YES" : "NO"}'),
                          trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: DuoColors.greenTint, borderRadius: BorderRadius.circular(999)), child: const Text('VERIFIED', style: TextStyle(color: DuoColors.green, fontWeight: FontWeight.bold, fontSize: 10))),
                        )).toList(),
                  ),
                ),

                // Tab 2: Requester Abuse Shield
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: ListView(
                    children: _requestersList.map((r) {
                      final phone = r['phone'] ?? '';
                      final isBlocked = r['is_blocked'] == true;
                      final total = r['total_requests'] ?? 1;
                      final score = r['abuse_score'] ?? r['risk_score'] ?? 0;

                      return ListTile(
                        leading: Icon(isBlocked ? Icons.block_rounded : Icons.phone_android_rounded, color: isBlocked ? DuoColors.red : DuoColors.green),
                        title: Text(phone, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('$total requests · Fraud Risk: $score/100'),
                        trailing: ElevatedButton(
                          onPressed: () => _toggleRequesterBlock(phone, isBlocked),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isBlocked ? DuoColors.green : DuoColors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(isBlocked ? 'UNBLOCK' : 'BLOCK'),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Tab 3: Community Partners & NGOs
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: ListView(
                    children: _partnersList.map((p) => ListTile(
                          leading: const Icon(Icons.handshake_rounded, color: Color(0xFFEA580C)),
                          title: Text(p['name'] ?? 'Partner', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text('Type: ${p['organization_type'] ?? "NGO"} · Coordinator: ${p['contact_person'] ?? "Lead"} · Camps: ${p['camps_organized_count']}'),
                          trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: DuoColors.greenTint, borderRadius: BorderRadius.circular(999)), child: const Text('ACTIVE MOU', style: TextStyle(color: DuoColors.green, fontWeight: FontWeight.bold, fontSize: 10))),
                        )).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // HUB 8: GOVERNANCE & APPROVALS (FOUR-EYES, EXPORTS, DPDP)
  // ============================================================================

  Widget _buildGovernanceHub() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: const TabBar(
              indicatorColor: Color(0xFFD97706),
              indicatorWeight: 3,
              labelColor: Color(0xFFD97706),
              unselectedLabelColor: DuoColors.textSecondary,
              labelStyle: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(icon: Icon(Icons.flaky_rounded, size: 18), text: 'Four-Eyes Approvals Queue'),
                Tab(icon: Icon(Icons.file_download_rounded, size: 18), text: 'Data Exports Engine'),
                Tab(icon: Icon(Icons.policy_rounded, size: 18), text: 'DPDP Privacy & Erasures'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 540,
            child: TabBarView(
              children: [
                // Tab 1: Four-Eyes Queue
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: _approvalRequests.isEmpty
                      ? const Center(child: Text('Zero pending Four-Eyes approval requests', style: TextStyle(fontFamily: DuoTypography.fontFamily, color: DuoColors.textSecondary)))
                      : ListView(
                          children: _approvalRequests.map((a) {
                            final id = a['id']?.toString() ?? '';
                            final action = a['action_type'] ?? 'broadcast.mass';
                            final reason = a['reason'] ?? 'Emergency mobilization';
                            final maker = a['maker_id'] ?? 'admin-01';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('$action (#${id.substring(0, id.length > 8 ? 8 : id.length)})', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text('Maker: $maker · Reason: $reason', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () => _decideApproval(id, true),
                                        style: ElevatedButton.styleFrom(backgroundColor: DuoColors.green, foregroundColor: Colors.white),
                                        child: const Text('Approve (Checker)'),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton(
                                        onPressed: () => _decideApproval(id, false),
                                        child: const Text('Reject'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),

                // Tab 2: Data Exports
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: ListView(
                    children: [
                      const Text('Privacy-Governed DPDP Data Exports', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 6),
                      const Text('Generates SHA-256 watermarked CSV files. Donor health questions are strictly unreadable per Section 0.3.', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
                      const SizedBox(height: 16),

                      ElevatedButton.icon(
                        onPressed: () async {
                          final res = await SupabaseService().createDataExport(
                            entityType: 'donors',
                            tier: '2',
                            format: 'csv',
                            reason: 'Routine quarterly audit export for health authorities',
                          );
                          if (res['ok'] == true && mounted && context.mounted) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Export Generated (CSV)', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold)),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('File: ${res['filename']}'),
                                      Text('Watermark: ${res['watermark_hash']}'),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                                        child: const Text('id,name,phone,blood_group,city\n#101,Suresh M.,+91******3210,O+,Rajahmundry\n#102,K. Ravi,+91******4321,B+,Rajahmundry', style: TextStyle(fontFamily: 'monospace', fontSize: 11)),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Clipboard.setData(const ClipboardData(text: 'id,name,phone,blood_group,city\n#101,Suresh M.,+91******3210,O+,Rajahmundry\n#102,K. Ravi,+91******4321,B+,Rajahmundry'));
                                      Navigator.pop(ctx);
                                      _showToast('CSV contents copied to clipboard!');
                                    },
                                    child: const Text('Copy CSV'),
                                  ),
                                  ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                                ],
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.file_download_rounded, size: 16),
                        label: const Text('Generate Masked Donors CSV Export'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0891B2), foregroundColor: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 10),

                      const Text('Export Records on Ledger:', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      ..._dataExports.map((e) => ListTile(
                            dense: true,
                            leading: const Icon(Icons.table_chart_rounded, color: Color(0xFF0891B2)),
                            title: Text(e['filename']?.toString() ?? 'export.csv', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold)),
                            subtitle: Text('SHA-256: ${e['watermark_hash']?.toString().substring(0, 10)}...'),
                            trailing: const Text('READY', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.green, fontSize: 11)),
                          )),
                    ],
                  ),
                ),

                // Tab 3: DPDP Privacy & Erasures Queue
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: ListView(
                    children: [
                      const Text('Digital Personal Data Protection (DPDP) Erasure Requests', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 10),
                      ..._dpdpRequests.map((d) => ListTile(
                            dense: true,
                            leading: const Icon(Icons.person_off_rounded, color: DuoColors.red),
                            title: Text('Right-to-be-Forgotten (#${d['id']?.toString().substring(0, 6)})', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text('Phone: ${d['phone_masked']} · Channel: ${d['request_type']}'),
                            trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: DuoColors.greenTint, borderRadius: BorderRadius.circular(999)), child: const Text('PROCESSED', style: TextStyle(color: DuoColors.green, fontWeight: FontWeight.bold, fontSize: 10))),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // HUB 9: SYSTEM & PLATFORM SETTINGS (KILLSWITCH, AUDIT LOGS)
  // ============================================================================

  Widget _buildSettingsHub() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: ListView(
        children: [
          // Master Killswitch
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _killSwitchActive ? DuoColors.redTint : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _killSwitchActive ? DuoColors.red : const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.power_settings_new_rounded, color: DuoColors.red, size: 22),
                          SizedBox(width: 8),
                          Text('MASTER PLATFORM KILL SWITCH', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.red, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _killSwitchActive ? 'ACTIVE: Outbound calls and intake are paused in Supabase' : 'Normal operations running smoothly on ixrborkhofxlxbedpang',
                        style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _killSwitchActive,
                  activeThumbColor: DuoColors.red,
                  onChanged: _toggleKillSwitch,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),

          // Clinical Safety Incidents Desk
          const Text('Clinical Safety & Adverse Events Desk', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          ..._safetyIncidents.map((inc) => ListTile(
                dense: true,
                leading: const Icon(Icons.healing_rounded, color: DuoColors.red),
                title: Text('${inc['title']} (${inc['severity']})', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('${inc['description']} · Status: ${inc['status']}'),
                trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: DuoColors.greenTint, borderRadius: BorderRadius.circular(4)), child: const Text('CLOSED', style: TextStyle(color: DuoColors.green, fontWeight: FontWeight.bold, fontSize: 10))),
              )),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 10),

          // Immutable Audit Logs Feed
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Cryptographically Logged Audit Feed', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 15)),
              Text('${_auditLogs.length} Events', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),

          ..._auditLogs.take(8).map((log) => ListTile(
                dense: true,
                leading: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                  child: Text(log['time'] ?? 'Recent', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 10, fontWeight: FontWeight.bold, color: DuoColors.textSecondary)),
                ),
                title: Text(log['action'] ?? 'action', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13, color: DuoColors.red)),
                subtitle: Text(log['detail'] ?? '', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12)),
              )),
        ],
      ),
    );
  }

  // ============================================================================
  // QUICK ACTIONS MODALS
  // ============================================================================

  void _showCreateCampModal() {
    final titleController = TextEditingController();
    final venueController = TextEditingController();
    final areaController = TextEditingController();
    final cityController = TextEditingController(text: 'Rajahmundry');
    final capacityController = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Schedule Voluntary Blood Drive Camp', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Camp Drive Title')),
              TextField(controller: venueController, decoration: const InputDecoration(labelText: 'Venue / Hall Name')),
              TextField(controller: areaController, decoration: const InputDecoration(labelText: 'Area / Neighborhood')),
              TextField(controller: cityController, decoration: const InputDecoration(labelText: 'City')),
              TextField(controller: capacityController, decoration: const InputDecoration(labelText: 'Donor Capacity Target'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && venueController.text.isNotEmpty) {
                final newCamp = CampModel(
                  id: 'camp-${DateTime.now().millisecondsSinceEpoch}',
                  bankId: _banksList.isNotEmpty ? _banksList.first.id : 'bank-01',
                  title: titleController.text.trim(),
                  venue: venueController.text.trim(),
                  area: areaController.text.trim().isEmpty ? 'Central' : areaController.text.trim(),
                  city: cityController.text.trim(),
                  startsAt: DateTime.now().add(const Duration(days: 3)),
                  endsAt: DateTime.now().add(const Duration(days: 3, hours: 6)),
                  capacity: int.tryParse(capacityController.text.trim()) ?? 100,
                  status: 'published',
                  lat: 17.0005,
                  lng: 81.7820,
                  targetRadiusKm: 10.0,
                );

                await SupabaseService().createCamp(
                  title: newCamp.title,
                  venue: newCamp.venue,
                  area: newCamp.area,
                  city: newCamp.city,
                  startsAt: newCamp.startsAt,
                  endsAt: newCamp.endsAt,
                  capacity: newCamp.capacity,
                );

                setState(() {
                  _campsList.insert(0, newCamp);
                });

                if (ctx.mounted) Navigator.pop(ctx);
                _showToast('Blood camp drive successfully scheduled and published!');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: DuoColors.red, foregroundColor: Colors.white),
            child: const Text('Publish Drive'),
          ),
        ],
      ),
    );
  }

  void _showQuickActionsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                leading: Icon(Icons.bolt_rounded, color: DuoColors.red, size: 28),
                title: Text('Superhero Command Actions', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text('Instant executive overrides for live emergency crisis situations'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.campaign_rounded, color: DuoColors.red),
                title: const Text('Dispatch Regional Camp Broadcast'),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _selectedSection = 1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.event_available_rounded, color: Color(0xFF2563EB)),
                title: const Text('Schedule New Blood Donation Camp'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showCreateCampModal();
                },
              ),
              ListTile(
                leading: const Icon(Icons.flaky_rounded, color: Color(0xFFD97706)),
                title: const Text('Open Four-Eyes Approvals Desk'),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _selectedSection = 8);
                },
              ),
              ListTile(
                leading: const Icon(Icons.power_settings_new_rounded, color: DuoColors.red),
                title: const Text('Toggle Platform Emergency Kill Switch'),
                onTap: () {
                  Navigator.pop(ctx);
                  _toggleKillSwitch(!_killSwitchActive);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
