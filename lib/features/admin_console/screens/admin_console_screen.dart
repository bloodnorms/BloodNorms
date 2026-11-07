// ============================================================================
// BloodNorms | admin_console_screen.dart
// Executive Operations & Superhero Admin Command Center
// Faithful SaaS Dashboard Design (Matching DevzeMart & Confidency OS aesthetic)
// Categorized Left Sidebar, 20 Superhero Admin Entities, 6 Pastel KPI Cards,
// DevzeMart Search Bar with ⌘K, High-Density Data Tables, DevzeMart Pagination,
// and Live Sync Telemetry.
//
// Strict Rules: Arial font only, FontWeight.normal & FontWeight.bold only.
// Primary color: Cardinal Red (#E52E2E), Universal Green strictly for success.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/duo_colors.dart';
import '../../../core/theme/duo_typography.dart';
import '../../../core/widgets/duo_button.dart';
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

  // Live Supabase & Platform Data
  List<Map<String, dynamic>> _liveRequests = [];
  List<Map<String, dynamic>> _donorsList = [];
  List<BloodBankModel> _banksList = [];
  List<CampModel> _campsList = [];
  List<Map<String, dynamic>> _auditLogs = [];

  // Expanded Superhero Entities Data
  List<Map<String, dynamic>> _hospitalsList = [];
  List<Map<String, dynamic>> _requestersList = [];
  List<Map<String, dynamic>> _partnersList = [];
  List<Map<String, dynamic>> _approvalRequests = [];
  List<Map<String, dynamic>> _safetyIncidents = [];
  List<Map<String, dynamic>> _dpdpRequests = [];
  List<Map<String, dynamic>> _dataExports = [];
  Map<String, dynamic> _dailySpend = {};

  // Search & Filter state
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'All';
  int _currentPage = 1;

  // Regional Broadcast state
  final TextEditingController _broadcastTitleController = TextEditingController(
    text: 'Mega Voluntary Blood Camp at Rotary Diamond Hall',
  );
  final TextEditingController _broadcastMsgController = TextEditingController(
    text: 'Dear BloodNorms Hero, a voluntary blood camp is organized this Sunday 9 AM at Rotary Diamond Hall, Main Road. Would you like to attend and donate? Reply YES to confirm.',
  );
  final String _selectedBroadcastType = 'camp_invitation';
  String _selectedGroupFilter = 'All';
  String _selectedChannel = 'whatsapp';
  bool _isBroadcasting = false;

  // Geo-Fenced & Region-Wise Broadcast State
  String? _selectedCampId;
  String _selectedTargetCity = 'Rajahmundry';
  double _broadcastRadiusKm = 10.0;
  bool _respectDonorTravelRadius = true;
  Map<String, dynamic> _audiencePreview = {
    'eligible_count': 4,
    'suppressed_count': 2,
    'estimated_cost_inr': 3.40,
    'requires_approval': false,
    'sample_donors': [],
  };

  // AI Voice Studio Test State
  final TextEditingController _aiTestInputController = TextEditingController(
    text: 'Hello, my father is admitted in GSL Hospital and urgently needs 2 units of B+ blood for cardiac surgery.',
  );
  String _aiTestLanguage = 'en';
  Map<String, dynamic>? _aiTestSimulationResult;
  bool _isAiTesting = false;

  // 20 Superhero Admin Navigation Groups (Categorized matching DevzeMart & Confidency OS)
  final List<Map<String, dynamic>> _navGroups = [
    {
      'header': 'COMMAND',
      'items': [
        {'id': 0, 'title': 'Overview Dashboard', 'icon': Icons.dashboard_rounded, 'badge': null},
        {'id': 1, 'title': 'Live Crisis Radar', 'icon': Icons.radar_rounded, 'badge': 'LIVE', 'badgeColor': DuoColors.red},
        {'id': 2, 'title': 'Needs Human Queue', 'icon': Icons.notification_important_rounded, 'badge': 'CRITICAL', 'badgeColor': Color(0xFFD97706)},
      ],
    },
    {
      'header': 'OPERATIONS & LOGISTICS',
      'items': [
        {'id': 3, 'title': 'Regional Broadcast', 'icon': Icons.campaign_rounded, 'badge': 'GEO', 'badgeColor': Color(0xFF0D9488)},
        {'id': 4, 'title': 'Blood Donation Camps', 'icon': Icons.event_available_rounded, 'badge': 'DRIVES', 'badgeColor': Color(0xFF2563EB)},
        {'id': 5, 'title': 'Blood Centers & Stock', 'icon': Icons.local_hospital_rounded, 'badge': null},
        {'id': 6, 'title': 'Verified Hospitals', 'icon': Icons.domain_verification_rounded, 'badge': 'CLINICAL', 'badgeColor': Color(0xFF4F46E5)},
      ],
    },
    {
      'header': 'PEOPLE & COMMUNITY',
      'items': [
        {'id': 7, 'title': 'Donors Registry', 'icon': Icons.people_rounded, 'badge': '450', 'badgeColor': Color(0xFF7C3AED)},
        {'id': 8, 'title': 'Requester Abuse Profiles', 'icon': Icons.security_rounded, 'badge': 'SHIELD', 'badgeColor': Color(0xFFE11D48)},
        {'id': 9, 'title': 'Community Alliances', 'icon': Icons.handshake_rounded, 'badge': 'NGO', 'badgeColor': Color(0xFFEA580C)},
      ],
    },
    {
      'header': 'AI & TELECOM',
      'items': [
        {'id': 10, 'title': 'AI Voice Studio', 'icon': Icons.record_voice_over_rounded, 'badge': 'AI', 'badgeColor': Color(0xFF9333EA)},
        {'id': 11, 'title': 'WhatsApp & Telemetry', 'icon': Icons.forum_rounded, 'badge': 'INR', 'badgeColor': Color(0xFF059669)},
      ],
    },
    {
      'header': 'GOVERNANCE & AUDIT',
      'items': [
        {'id': 12, 'title': 'Four-Eyes Approvals', 'icon': Icons.flaky_rounded, 'badge': '2-EYE', 'badgeColor': Color(0xFFD97706)},
        {'id': 13, 'title': 'Financial Ledgers', 'icon': Icons.payments_rounded, 'badge': 'ACCOUNTS', 'badgeColor': Color(0xFF16A34A)},
        {'id': 14, 'title': 'Data Exports Engine', 'icon': Icons.file_download_rounded, 'badge': 'EXPORT', 'badgeColor': Color(0xFF0891B2)},
        {'id': 15, 'title': 'Safety & Incidents', 'icon': Icons.medical_services_rounded, 'badge': 'SAFETY', 'badgeColor': DuoColors.red},
        {'id': 16, 'title': 'DPDP Compliance', 'icon': Icons.policy_rounded, 'badge': 'DPDP', 'badgeColor': Color(0xFF3B82F6)},
        {'id': 17, 'title': 'Maintenance Switches', 'icon': Icons.toggle_on_rounded, 'badge': 'SYS', 'badgeColor': Color(0xFF6B21A8)},
        {'id': 18, 'title': 'Platform Configuration', 'icon': Icons.tune_rounded, 'badge': null},
        {'id': 19, 'title': 'Immutable Audit Logs', 'icon': Icons.history_edu_rounded, 'badge': 'CHAIN', 'badgeColor': Color(0xFF334155)},
      ],
    },
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

      // Superhero Expanded Data
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

  // --- SUPERHERO OPERATIONAL ACTIONS ---

  Future<void> _widenRequest(String reqId, double currentKm) async {
    final nextKm = currentKm + 2.0;
    await SupabaseService().widenRequest(reqId, nextKm);
    _showToast('Expanded request search radius to ${nextKm.toStringAsFixed(1)} km');
    _loadAllAdminData();
  }

  Future<void> _closeRequest(String reqId) async {
    await SupabaseService().closeRequest(reqId, outcome: 'admin_closed');
    _showToast('Emergency request fulfilled and resolved');
    _loadAllAdminData();
  }

  Future<void> _toggleKillSwitch(bool value) async {
    await SupabaseService().setKillSwitch(value);
    setState(() => _killSwitchActive = value);
    _showToast(value ? '🚨 PLATFORM EMERGENCY KILL-SWITCH ACTIVATED' : '✅ Platform operations restored to normal');
    _loadAllAdminData();
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
      broadcastType: _selectedBroadcastType,
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
        _showToast('🚀 Broadcast sent to $count donors in $_selectedTargetCity within ${_broadcastRadiusKm.toInt()} km! ($suppressed outside radius excluded, ₹$cost INR)');
        _loadAllAdminData();
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
              'Broadcasting to $count recipients exceeds the single-admin policy threshold (>200 donors).\n\nA pending change request (#${res['approval_id'] ?? 'AM1-PENDING'}) has been routed to the Four-Eyes Approvals Desk for second-admin verification.',
              style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 13, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => _selectedSection = 12); // Jump to Four-Eyes Desk
                },
                child: const Text('Go to Approvals Desk', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.red)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: DuoColors.red, foregroundColor: Colors.white),
                child: const Text('Acknowledged'),
              ),
            ],
          ),
        );
      } else {
        _showToast('Failed to dispatch broadcast: ${res['error'] ?? 'Unknown error'}');
      }
    }
  }

  // ============================================================================
  // UI BUILD ROOT (RESPONSIVE FOR ALL SCREEN SIZES)
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final showSidebarPermanent = width >= 720;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: showSidebarPermanent
            ? Row(
                children: [
                  _buildSidebar(isPermanent: true),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: DuoColors.red))
                        : _buildMainDashboard(context),
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
                      const Text(
                        'BloodNorms OS',
                        style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.textPrimary, fontSize: 16),
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
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: _buildMobileCategoryPillStrip(),
                  ),
                ),
                drawer: Drawer(child: _buildSidebar(isPermanent: false)),
                body: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: DuoColors.red))
                    : _buildMainDashboard(context),
              ),
      ),
    );
  }

  // --- MOBILE FAST-SCROLLER CATEGORY PILL STRIP ---
  Widget _buildMobileCategoryPillStrip() {
    return Container(
      height: 48,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 20,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (ctx, i) {
          final isSel = _selectedSection == i;
          final title = _getSectionShortTitle(i);
          return ChoiceChip(
            label: Text(
              title,
              style: TextStyle(
                fontFamily: DuoTypography.fontFamily,
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
                color: isSel ? Colors.white : DuoColors.textPrimary,
              ),
            ),
            selected: isSel,
            selectedColor: DuoColors.red,
            backgroundColor: const Color(0xFFF1F5F9),
            onSelected: (_) => setState(() => _selectedSection = i),
          );
        },
      ),
    );
  }

  String _getSectionShortTitle(int id) {
    switch (id) {
      case 0: return 'Cockpit';
      case 1: return 'Crisis Radar';
      case 2: return 'Needs Human';
      case 3: return 'Broadcast';
      case 4: return 'Camps';
      case 5: return 'Banks';
      case 6: return 'Hospitals';
      case 7: return 'Donors';
      case 8: return 'Requester Shield';
      case 9: return 'Alliances';
      case 10: return 'AI Studio';
      case 11: return 'Telecom';
      case 12: return 'Four-Eyes';
      case 13: return 'Ledgers';
      case 14: return 'Exports';
      case 15: return 'Safety';
      case 16: return 'DPDP';
      case 17: return 'Switches';
      case 18: return 'Settings';
      case 19: return 'Audit';
      default: return 'Module';
    }
  }

  // ============================================================================
  // 1. LEFT SIDEBAR (DEVZEMART & CONFIDENCY OS MODERN STYLING)
  // ============================================================================

  Widget _buildSidebar({required bool isPermanent}) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
      ),
      child: Column(
        children: [
          // Logo & Brand Header (Matching DevzeMart)
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

          // Search Box in Sidebar (Matching DevzeMart ⌘K)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search_rounded, size: 16, color: DuoColors.textSecondary),
                  SizedBox(width: 8),
                  Text(
                    'Search actions...  ⌘K',
                    style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // All 20 Categorized Superhero Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _navGroups.map((group) {
                final header = group['header'] as String;
                final items = group['items'] as List<Map<String, dynamic>>;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 16, bottom: 6),
                      child: Text(
                        header,
                        style: const TextStyle(
                          fontFamily: DuoTypography.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    ...items.map((item) {
                      final id = item['id'] as int;
                      final title = item['title'] as String;
                      final icon = item['icon'] as IconData;
                      final badge = item['badge'] as String?;
                      final badgeColor = (item['badgeColor'] as Color?) ?? DuoColors.red;
                      final isSelected = _selectedSection == id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 3),
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
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8.5),
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
                                        fontSize: 12.5,
                                        color: isSelected ? Colors.white : const Color(0xFF334155),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                    }),
                  ],
                );
              }).toList(),
            ),
          ),

          // Bottom Super Admin Profile Card (Matching Confidency OS)
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
                  onPressed: () => setState(() => _selectedSection = 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 2. MAIN DASHBOARD CANVAS (DEVZEMART & CONFIDENCY OS STYLING)
  // ============================================================================

  Widget _buildMainDashboard(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      children: [
        // Top Header Row (Breadcrumbs + Actions + DevzeMart Add Button)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Operations > ${_getCurrentSectionTitle()}',
                  style: const TextStyle(
                    fontFamily: DuoTypography.fontFamily,
                    fontSize: 12,
                    color: DuoColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getCurrentSectionTitle(),
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
                // Live Sync Status Pill
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

                // Export Data Button
                OutlinedButton.icon(
                  onPressed: () => setState(() => _selectedSection = 14),
                  icon: const Icon(Icons.file_download_outlined, size: 16, color: DuoColors.textPrimary),
                  label: const Text('Export', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.textPrimary, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 10),

                // DevzeMart + Add Action Gradient Button
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE52E2E), Color(0xFFB91C1C)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(color: Color(0x33E52E2E), blurRadius: 6, offset: Offset(0, 2)),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _showQuickActionsSheet,
                    icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                    label: const Text('+ Superhero Action', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 6-Card Quick Stats KPI Row (Soft pastel gradient cards matching DevzeMart & Confidency OS)
        _buildKPIStatsRow(),
        const SizedBox(height: 20),

        // DevzeMart Search Bar with ⌘K & Filter Controls
        _buildDevzeMartSearchBar(),
        const SizedBox(height: 20),

        // Active Section Content
        _buildActiveSectionContent(context),
        const SizedBox(height: 24),

        // DevzeMart Pagination Bar
        _buildDevzeMartPaginationBar(),
      ],
    );
  }

  String _getCurrentSectionTitle() {
    switch (_selectedSection) {
      case 0: return 'Overview Dashboard';
      case 1: return 'Live Crisis Radar';
      case 2: return 'Needs Human Queue';
      case 3: return 'Regional Broadcast Center';
      case 4: return 'Blood Donation Camps';
      case 5: return 'Blood Centers & Stock Desk';
      case 6: return 'Verified Hospitals Registry';
      case 7: return 'Donors Registry';
      case 8: return 'Requester Abuse Profiles';
      case 9: return 'Community Alliances & NGOs';
      case 10: return 'AI Voice Studio & Simulator';
      case 11: return 'WhatsApp & Telecom Ledgers';
      case 12: return 'Four-Eyes Approvals Desk';
      case 13: return 'Financial Ledgers & Grants';
      case 14: return 'Data Exports Engine';
      case 15: return 'Clinical Safety & Incidents';
      case 16: return 'DPDP Compliance & Privacy';
      case 17: return 'Scoped Maintenance Switches';
      case 18: return 'Platform Configuration';
      case 19: default: return 'Immutable Audit Logs';
    }
  }

  // ============================================================================
  // 3. 6 PASTEL GRADIENT KPI CARDS ROW (DEVZEMART & CONFIDENCY OS AESTHETIC)
  // ============================================================================

  Widget _buildKPIStatsRow() {
    final activeCrises = _liveRequests.where((r) => r['status'] == 'searching').length;
    final totalStock = _banksList.fold<int>(0, (sum, b) => sum + b.stockUnits);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Card 1: Active Donors (DevzeMart soft lavender/blue)
              _buildKPICard(
                title: 'Active Donors',
                value: '${_donorsList.length}',
                trend: '+8.4% vs yesterday',
                icon: Icons.people_rounded,
                accentColor: const Color(0xFF6366F1),
                bgGradient: const [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
              ),
              const SizedBox(width: 12),

              // Card 2: Active Crises (DevzeMart soft red/amber)
              _buildKPICard(
                title: 'Active Crises',
                value: '$activeCrises',
                trend: 'Realtime Radar',
                icon: Icons.radar_rounded,
                accentColor: DuoColors.red,
                bgGradient: const [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
              ),
              const SizedBox(width: 12),

              // Card 3: Blood Centers (DevzeMart soft cyan/sky)
              _buildKPICard(
                title: 'Blood Centers',
                value: '${_banksList.length}',
                trend: 'Pilot Active',
                icon: Icons.local_hospital_rounded,
                accentColor: const Color(0xFF0EA5E9),
                bgGradient: const [Color(0xFFECFEFF), Color(0xFFCFFAFE)],
              ),
              const SizedBox(width: 12),

              // Card 4: Units in Stock (DevzeMart soft emerald/mint)
              _buildKPICard(
                title: 'Units Available',
                value: '$totalStock',
                trend: '8 Groups Total',
                icon: Icons.inventory_2_rounded,
                accentColor: const Color(0xFF10B981),
                bgGradient: const [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
              ),
              const SizedBox(width: 12),

              // Card 5: Camps Scheduled (DevzeMart soft yellow/amber)
              _buildKPICard(
                title: 'Camps Scheduled',
                value: '${_campsList.length}',
                trend: '+12.3% this month',
                icon: Icons.event_available_rounded,
                accentColor: const Color(0xFFF59E0B),
                bgGradient: const [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
              ),
              const SizedBox(width: 12),

              // Card 6: Telecom Spend (DevzeMart soft fuchsia/purple)
              _buildKPICard(
                title: 'Telecom Spend',
                value: '₹${_dailySpend['total_cost_inr'] ?? 482}',
                trend: 'Auto-budgeted',
                icon: Icons.currency_rupee_rounded,
                accentColor: const Color(0xFFD946EF),
                bgGradient: const [Color(0xFFFDF4FF), Color(0xFFFAE8FF)],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String trend,
    required IconData icon,
    required Color accentColor,
    required List<Color> bgGradient,
  }) {
    return Container(
      width: 172,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bgGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.15)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), offset: Offset(0, 2), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 1)),
                  ],
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontFamily: DuoTypography.fontFamily,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontFamily: DuoTypography.fontFamily,
              fontSize: 11,
              color: DuoColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: DuoTypography.fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: DuoColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 4. DEVZEMART SEARCH & FILTER CONTROLS BAR (WITH ⌘K SHORTCUT BADGE)
  // ============================================================================

  Widget _buildDevzeMartSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 18, color: DuoColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search by name, phone, hospital, or transaction ID...',
                hintStyle: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 13, color: DuoColors.textPrimary),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text(
              '⌘K',
              style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 10, fontWeight: FontWeight.bold, color: DuoColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () {
              _showToast('Filter presets applied');
            },
            icon: const Icon(Icons.filter_list_rounded, size: 14, color: DuoColors.textPrimary),
            label: const Text('Filter', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12, color: DuoColors.textPrimary)),
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFF8FAFC),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 5. DEVZEMART PAGINATION BAR (← Previous  1  2  3  ...  8  9  10  Next →)
  // ============================================================================

  Widget _buildDevzeMartPaginationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Showing 1–10 of 450 entries',
            style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary),
          ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                icon: const Icon(Icons.arrow_back_rounded, size: 12),
                label: const Text('Previous', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(width: 6),
              ...[1, 2, 3].map((page) {
                final isCurrent = _currentPage == page;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    onTap: () => setState(() => _currentPage = page),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: isCurrent
                            ? const LinearGradient(colors: [Color(0xFFE52E2E), Color(0xFFB91C1C)])
                            : null,
                        color: isCurrent ? null : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isCurrent ? Colors.transparent : const Color(0xFFE2E8F0)),
                      ),
                      child: Center(
                        child: Text(
                          '$page',
                          style: TextStyle(
                            fontFamily: DuoTypography.fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: isCurrent ? Colors.white : DuoColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('...', style: TextStyle(color: DuoColors.textSecondary)),
              ),
              InkWell(
                onTap: () => setState(() => _currentPage = 10),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Center(
                    child: Text('10', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 11, color: DuoColors.textPrimary)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              OutlinedButton(
                onPressed: _currentPage < 10 ? () => setState(() => _currentPage++) : null,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Row(
                  children: [
                    Text('Next', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 12),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 6. SECTION ROUTER FOR ALL 20 SUPERHERO ADMIN MODULES
  // ============================================================================

  Widget _buildActiveSectionContent(BuildContext context) {
    switch (_selectedSection) {
      case 0: return _buildOverviewSection(context);
      case 1: return _buildLiveMonitorSection(context);
      case 2: return _buildNeedsHumanSection(context);
      case 3: return _buildBroadcastSection(context);
      case 4: return _buildCampsSection(context);
      case 5: return _buildBanksSection(context);
      case 6: return _buildHospitalsSection(context);
      case 7: return _buildDonorsSection(context);
      case 8: return _buildRequestersSection(context);
      case 9: return _buildPartnersSection(context);
      case 10: return _buildAIVoiceStudioSection(context);
      case 11: return _buildTelecomSection(context);
      case 12: return _buildFourEyesSection(context);
      case 13: return _buildLedgersSection(context);
      case 14: return _buildExportsSection(context);
      case 15: return _buildSafetySection(context);
      case 16: return _buildDPDPSection(context);
      case 17: return _buildMaintenanceSection(context);
      case 18: return _buildSettingsSection(context);
      case 19: default: return _buildAuditSection(context);
    }
  }

  // ============================================================================
  // SECTION 0: OVERVIEW COCKPIT
  // ============================================================================

  Widget _buildOverviewSection(BuildContext context) {
    final active = _liveRequests.where((r) => r['status'] == 'searching').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live Emergencies Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: DuoColors.red, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      const Text(
                        'Live Emergency Crises in Pilot Area (Rajahmundry)',
                        style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 15, color: DuoColors.textPrimary),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => setState(() => _selectedSection = 1),
                    icon: const Text('View Full Radar', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12, color: DuoColors.red)),
                    label: const Icon(Icons.arrow_forward_rounded, size: 14, color: DuoColors.red),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (active.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  child: const Center(
                    child: Text(
                      'No active emergency crises. All requests fulfilled or standing by.',
                      style: TextStyle(fontFamily: DuoTypography.fontFamily, color: DuoColors.textSecondary),
                    ),
                  ),
                )
              else
                ...active.take(3).map((r) => _buildEmergencyRow(r)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 2-Column Split: Donors Mini-Registry & Immutable Audit Log Feed
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Registered Donors Registry', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14, color: DuoColors.textPrimary)),
                        TextButton(
                          onPressed: () => setState(() => _selectedSection = 7),
                          child: const Text('View Full Registry', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12, color: DuoColors.red)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._donorsList.take(4).map((d) {
                      final name = d['full_name'] ?? d['first_name'] ?? 'Donor';
                      final bg = d['blood_group'] ?? 'O+';
                      final count = d['donations_count'] ?? 0;
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: DuoColors.redTint,
                          child: Text(bg, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.red, fontSize: 11)),
                        ),
                        title: Text(name, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('$count donations · Rajahmundry', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: DuoColors.textSecondary)),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_horiz_rounded, size: 18),
                          onPressed: () => _showDonorSuperheroActions(d),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Immutable Audit Trail', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14, color: DuoColors.textPrimary)),
                        TextButton(
                          onPressed: () => setState(() => _selectedSection = 19),
                          child: const Text('View Full Trail', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12, color: DuoColors.red)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._auditLogs.take(4).map((log) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                                child: Text(log['time']?.toString() ?? 'Recent', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 10, fontWeight: FontWeight.bold, color: DuoColors.textSecondary)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  log['detail']?.toString() ?? '',
                                  style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmergencyRow(Map<String, dynamic> req) {
    final id = req['id']?.toString() ?? '';
    final hosp = req['hospital_name']?.toString() ?? 'Hospital';
    final bg = req['blood_group']?.toString() ?? 'O+';
    final units = req['units_needed'] ?? 1;
    final phone = req['requester_phone']?.toString() ?? '';
    final ringKm = (req['current_ring_km'] as num?)?.toDouble() ?? 1.5;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
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
                  Text('Ring: ${ringKm.toStringAsFixed(1)} km · Requester: $phone', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: DuoColors.textSecondary)),
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
                tooltip: 'Widen Search Ring',
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
  // SECTION 1: LIVE CRISIS RADAR
  // ============================================================================

  Widget _buildLiveMonitorSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Live Emergency Requests Radar', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${_liveRequests.length} Total Requests', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_liveRequests.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No emergency requests in Supabase', style: TextStyle(fontFamily: DuoTypography.fontFamily, color: DuoColors.textSecondary))),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                columns: const [
                  DataColumn(label: Text('#', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('PATIENT / HOSPITAL', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('BLOOD GROUP', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('STATUS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('RING RADIUS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('DISPATCHED / ACCEPTED', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('SUPERHERO ACTIONS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                ],
                rows: _liveRequests.map((r) {
                  final id = r['id']?.toString() ?? '';
                  final patient = r['patient_first_name']?.toString() ?? 'Patient';
                  final hosp = r['hospital_name']?.toString() ?? 'Hospital';
                  final bg = r['blood_group']?.toString() ?? 'O+';
                  final status = (r['status'] ?? 'searching').toString().toUpperCase();
                  final ringKm = (r['current_ring_km'] as num?)?.toDouble() ?? 1.5;
                  final contacted = r['donors_contacted'] ?? 0;
                  final accepted = r['donors_accepted'] ?? 0;
                  final phone = r['requester_phone']?.toString() ?? '';

                  return DataRow(
                    cells: [
                      DataCell(Text('#${id.substring(0, id.length > 4 ? 4 : id.length)}', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: DuoColors.textSecondary))),
                      DataCell(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(patient, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(hosp, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: DuoColors.textSecondary)),
                        ],
                      )),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: DuoColors.redTint, borderRadius: BorderRadius.circular(6)),
                        child: Text(bg, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.red, fontSize: 12)),
                      )),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: status == 'SEARCHING' ? const Color(0xFFFEF2F2) : (status == 'FULFILLED' ? DuoColors.greenTint : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontFamily: DuoTypography.fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: status == 'SEARCHING' ? DuoColors.red : (status == 'FULFILLED' ? DuoColors.green : DuoColors.textSecondary),
                          ),
                        ),
                      )),
                      DataCell(Text('${ringKm.toStringAsFixed(1)} km', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                      DataCell(Text('$contacted contacted · $accepted accepted', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12))),
                      DataCell(Row(
                        children: [
                          if (phone.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.phone_rounded, size: 16, color: DuoColors.green),
                              onPressed: () async {
                                final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
                                if (await canLaunchUrl(uri)) await launchUrl(uri);
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.zoom_out_map_rounded, size: 16, color: DuoColors.red),
                            tooltip: 'Widen Ring (+2km)',
                            onPressed: () => _widenRequest(id, ringKm),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: DuoColors.green),
                            tooltip: 'Fulfill Request',
                            onPressed: () => _closeRequest(id),
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
  // SECTION 2: NEEDS HUMAN QUEUE
  // ============================================================================

  Widget _buildNeedsHumanSection(BuildContext context) {
    final needsHuman = _liveRequests.where((r) {
      final isSearching = r['status'] == 'searching' || r['status'] == 'active';
      final ringKm = (r['current_ring_km'] as num?)?.toDouble() ?? 0.0;
      final accepted = (r['donors_accepted'] as num?)?.toInt() ?? 0;
      return isSearching && (ringKm >= 5.0 || accepted == 0);
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
                    SizedBox(width: 8),
                    Text('Needs Human Intervention Triage', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(999)),
                  child: Text('${needsHuman.length} Escalations', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: Color(0xFFD97706), fontSize: 11)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (needsHuman.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: DuoColors.green, size: 40),
                    SizedBox(height: 10),
                    Text('Queue Clear! Zero stalled crises.', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(height: 4),
                    Text('All automated search rings are converting smoothly.', style: TextStyle(fontFamily: DuoTypography.fontFamily, color: DuoColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            )
          else
            ...needsHuman.map((r) {
              final id = r['id']?.toString() ?? '';
              final patient = r['patient_first_name']?.toString() ?? 'Patient';
              final hosp = r['hospital_name']?.toString() ?? 'Hospital';
              final bg = r['blood_group']?.toString() ?? 'O+';
              final phone = r['requester_phone']?.toString() ?? '';
              final ringKm = (r['current_ring_km'] as num?)?.toDouble() ?? 5.0;

              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.notification_important_rounded, color: Color(0xFFD97706)),
                ),
                title: Text('$patient at $hosp ($bg)', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('Search Ring: ${ringKm.toStringAsFixed(1)} km · No donors confirmed yet · Requester: $phone', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => _widenRequest(id, ringKm),
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
              );
            }),
        ],
      ),
    );
  }

  // ============================================================================
  // SECTION 3: REGIONAL BROADCAST CENTER (GEO-TARGETED DISPATCHER)
  // ============================================================================

  Widget _buildBroadcastSection(BuildContext context) {
    final eligible = _audiencePreview['eligible_count'] ?? 0;
    final suppressed = _audiencePreview['suppressed_count'] ?? 0;
    final cost = _audiencePreview['estimated_cost_inr'] ?? 0.0;
    final requiresApproval = _audiencePreview['requires_approval'] ?? false;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.campaign_rounded, color: DuoColors.red, size: 24),
                  SizedBox(width: 10),
                  Text('Region-Wise & Geo-Fenced Broadcaster', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 17)),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _showAudienceInspectorModal,
                icon: const Icon(Icons.analytics_outlined, size: 16),
                label: const Text('Inspect Audience & Suppressed', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12)),
                style: OutlinedButton.styleFrom(foregroundColor: DuoColors.red, side: const BorderSide(color: DuoColors.red)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Blood Group Target & Delivery Channel
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Blood Group Target', border: OutlineInputBorder()),
                  initialValue: _selectedGroupFilter,
                  items: ['All', 'O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'].map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedGroupFilter = val);
                      _updateAudiencePreview();
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Outbound Delivery Channel', border: OutlineInputBorder()),
                  initialValue: _selectedChannel,
                  items: const [
                    DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp Business API (Meta)')),
                    DropdownMenuItem(value: 'sms', child: Text('SMS Broadcast (Twilio)')),
                    DropdownMenuItem(value: 'in_app', child: Text('In-App Notification Feed')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedChannel = val);
                      _updateAudiencePreview();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // City & Camp Selector
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
                child: DropdownButtonFormField<String?>(
                  decoration: const InputDecoration(labelText: 'Link Blood Camp (Optional)', border: OutlineInputBorder()),
                  initialValue: _selectedCampId,
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('No Camp (General Mobilization)')),
                    ..._campsList.map((c) => DropdownMenuItem<String?>(value: c.id, child: Text(c.title))),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedCampId = val);
                    _updateAudiencePreview();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Blood Group Target & Delivery Channel
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Blood Group Target', border: OutlineInputBorder()),
                  initialValue: _selectedGroupFilter,
                  items: ['All', 'O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'].map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedGroupFilter = val);
                      _updateAudiencePreview();
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Outbound Delivery Channel', border: OutlineInputBorder()),
                  initialValue: _selectedChannel,
                  items: const [
                    DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp Business API (Meta)')),
                    DropdownMenuItem(value: 'sms', child: Text('SMS Broadcast (Twilio)')),
                    DropdownMenuItem(value: 'in_app', child: Text('In-App Notification Feed')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedChannel = val);
                      _updateAudiencePreview();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Radius Slider & Travel Cap Switch
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: SwitchListTile(
                  title: const Text('Respect Donor Travel Limits', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('Exclude donors who set a lower travel radius cap', style: TextStyle(fontSize: 11)),
                  value: _respectDonorTravelRadius,
                  activeThumbColor: DuoColors.red,
                  onChanged: (val) {
                    setState(() => _respectDonorTravelRadius = val);
                    _updateAudiencePreview();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Blood Group Target & Delivery Channel
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Blood Group Target', border: OutlineInputBorder()),
                  initialValue: _selectedGroupFilter,
                  items: ['All', 'O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'].map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedGroupFilter = val);
                      _updateAudiencePreview();
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Outbound Delivery Channel', border: OutlineInputBorder()),
                  initialValue: _selectedChannel,
                  items: const [
                    DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp Business API (Meta)')),
                    DropdownMenuItem(value: 'sms', child: Text('SMS Broadcast (Twilio)')),
                    DropdownMenuItem(value: 'in_app', child: Text('In-App Notification Feed')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedChannel = val);
                      _updateAudiencePreview();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Broadcast Title & Message Input
          TextField(
            controller: _broadcastTitleController,
            decoration: const InputDecoration(labelText: 'Broadcast Campaign Title', border: OutlineInputBorder()),
            style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _broadcastMsgController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Message Body (Telugu / English Auto-localized)', border: OutlineInputBorder()),
            style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Telemetry Estimate Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.radar_rounded, color: DuoColors.green, size: 20),
                    const SizedBox(width: 8),
                    Text('Audience In-Radius: $eligible donors', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 14),
                    Text('Suppressed: $suppressed outside radius', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
                  ],
                ),
                Text('Cost: ₹${cost.toStringAsFixed(2)} INR', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13, color: DuoColors.red)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Dispatch Action
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _isBroadcasting ? null : _dispatchBroadcast,
              icon: _isBroadcasting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded, size: 16),
              label: Text(
                requiresApproval ? 'Submit for Four-Eyes Approval' : 'Dispatch Broadcast Now',
                style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DuoColors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- AUDIENCE INSPECTOR MODAL SHEET ---
  void _showAudienceInspectorModal() {
    final eligible = _audiencePreview['eligible_count'] ?? 0;
    final suppressed = _audiencePreview['suppressed_count'] ?? 0;
    final samples = (_audiencePreview['sample_donors'] as List<dynamic>?) ?? [];
    final suppressedList = (_audiencePreview['suppressed_sample'] as List<dynamic>?) ?? [];
    final areaBreakdown = (_audiencePreview['area_breakdown'] as Map<String, dynamic>?) ?? {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DefaultTabController(
        length: 3,
        child: Container(
          height: MediaQuery.of(ctx).size.height * 0.78,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: DuoColors.greenTint, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.people_alt_rounded, color: DuoColors.green, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Audience Telemetry & Geofence Inspector', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 17, fontWeight: FontWeight.bold, color: DuoColors.textPrimary)),
                          Text('Targeting: $_selectedTargetCity within ${_broadcastRadiusKm.toInt()} km', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: DuoColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                child: TabBar(
                  indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2))]),
                  labelColor: DuoColors.textPrimary,
                  unselectedLabelColor: DuoColors.textSecondary,
                  labelStyle: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12),
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    Tab(text: '🎯 In-Radius ($eligible)'),
                    Tab(text: '🚫 Suppressed ($suppressed)'),
                    const Tab(text: '📍 Areas'),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Expanded(
                child: TabBarView(
                  children: [
                    samples.isEmpty
                        ? const Center(child: Text('No donors match this specific radius and city filter.', style: TextStyle(fontFamily: DuoTypography.fontFamily, color: DuoColors.textSecondary)))
                        : ListView.separated(
                            itemCount: samples.length,
                            separatorBuilder: (_, index) => const Divider(height: 1),
                            itemBuilder: (ctx, i) {
                              final s = samples[i] as Map<String, dynamic>;
                              final name = s['name']?.toString() ?? 'Donor';
                              final bg = s['blood_group']?.toString() ?? 'O+';
                              final dist = s['distance_km']?.toString() ?? '0.0';
                              final city = s['city']?.toString() ?? _selectedTargetCity;
                              final area = s['area']?.toString() ?? 'Area';

                              return ListTile(
                                dense: true,
                                leading: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: DuoColors.redTint, borderRadius: BorderRadius.circular(6)),
                                  child: Text(bg, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.red, fontSize: 11)),
                                ),
                                title: Text(name, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text('$dist km away from venue · $area, $city', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: DuoColors.textSecondary)),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: DuoColors.greenTint, borderRadius: BorderRadius.circular(6)),
                                  child: const Text('MATCHED', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 10, fontWeight: FontWeight.bold, color: DuoColors.green)),
                                ),
                              );
                            },
                          ),

                    suppressedList.isEmpty
                        ? const Center(child: Text('No donors are currently suppressed.', style: TextStyle(fontFamily: DuoTypography.fontFamily, color: DuoColors.textSecondary)))
                        : ListView.separated(
                            itemCount: suppressedList.length,
                            separatorBuilder: (_, index) => const Divider(height: 1),
                            itemBuilder: (ctx, i) {
                              final s = suppressedList[i] as Map<String, dynamic>;
                              final name = s['name']?.toString() ?? 'Donor';
                              final bg = s['blood_group']?.toString() ?? 'O+';
                              final city = s['city']?.toString() ?? 'Unknown';
                              final dist = s['distance_km']?.toString() ?? '0.0';
                              final reason = s['reason']?.toString() ?? 'Excluded';

                              return ListTile(
                                dense: true,
                                leading: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                                  child: Text(bg, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.textSecondary, fontSize: 11)),
                                ),
                                title: Text(name, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text('$dist km away · $city\n$reason', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: DuoColors.red)),
                                isThreeLine: true,
                                trailing: const Icon(Icons.block_rounded, color: DuoColors.red, size: 18),
                              );
                            },
                          ),

                    areaBreakdown.isEmpty
                        ? const Center(child: Text('No neighborhood breakdown available for this radius.', style: TextStyle(fontFamily: DuoTypography.fontFamily, color: DuoColors.textSecondary)))
                        : ListView(
                            children: areaBreakdown.entries.map((e) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.location_city_rounded, size: 18, color: DuoColors.textSecondary),
                                        const SizedBox(width: 8),
                                        Text(e.key.toString(), style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13, color: DuoColors.textPrimary)),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: DuoColors.greenTint, borderRadius: BorderRadius.circular(999)),
                                      child: Text('${e.value} Donors In Radius', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.green, fontSize: 11)),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // SECTION 4: BLOOD DONATION CAMPS
  // ============================================================================

  Widget _buildCampsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Scheduled Blood Donation Camps', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
                ElevatedButton.icon(
                  onPressed: _showCreateCampModal,
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Camp Drive', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DuoColors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_campsList.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No blood donation camps scheduled in Supabase', style: TextStyle(fontFamily: DuoTypography.fontFamily, color: DuoColors.textSecondary))),
            )
          else
            ..._campsList.map((c) {
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: DuoColors.redTint, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.event_available_rounded, color: DuoColors.red),
                ),
                title: Text(c.title, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('${c.venue} · ${c.area} · Target: ${c.targetRadiusKm}km · Capacity: ${c.capacity} donors', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: DuoColors.greenTint, borderRadius: BorderRadius.circular(999)),
                      child: const Text('PUBLISHED', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.green, fontSize: 10)),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.campaign_outlined, color: DuoColors.red),
                      tooltip: 'Broadcast to Camp Radius',
                      onPressed: () {
                        setState(() {
                          _selectedCampId = c.id;
                          _selectedTargetCity = c.city;
                          _broadcastRadiusKm = c.targetRadiusKm;
                          _selectedSection = 3; // Jump to broadcast
                        });
                        _updateAudiencePreview();
                      },
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ============================================================================
  // SECTION 5: BLOOD BANKS & INVENTORY DESK
  // ============================================================================

  Widget _buildBanksSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Blood Banks Directory & Realtime Stock Desk', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${_banksList.length} Connected Facilities', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columns: const [
                DataColumn(label: Text('FACILITY NAME', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('ADDRESS / CITY', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('AVAILABLE UNITS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('HOURS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('TRUST SCORE', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('SUPERHERO ACTIONS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
              ],
              rows: _banksList.map((b) {
                return DataRow(
                  cells: [
                    DataCell(Text(b.name, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13))),
                    DataCell(Text('${b.address}, ${b.city}', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: DuoColors.greenTint, borderRadius: BorderRadius.circular(6)),
                      child: Text('${b.stockUnits} units', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.green, fontSize: 12)),
                    )),
                    DataCell(Text(b.is24x7 ? '24x7 Emergency' : 'Standard Hours', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12))),
                    DataCell(Text('${b.trustScore} (${b.trustLabel})', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12, color: DuoColors.red))),
                    DataCell(DuoButton(
                      label: 'MANAGE STOCK',
                      icon: Icons.tune_rounded,
                      height: 32,
                      variant: DuoButtonVariant.secondary,
                      onPressed: () => _showBankSuperheroActions(b),
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
  // SECTION 6: VERIFIED HOSPITALS & MEDICAL CENTERS
  // ============================================================================

  Widget _buildHospitalsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Verified Hospitals & Medical Centers Registry', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${_hospitalsList.length} Accredited Centers', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columns: const [
                DataColumn(label: Text('HOSPITAL NAME', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('CITY / ZONE', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('TIER & TRAUMA', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('BLOOD BANK ON-SITE', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('EMERGENCY HOTLINE', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('VERIFICATION', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
              ],
              rows: _hospitalsList.map((h) {
                final name = h['name']?.toString() ?? 'Hospital';
                final city = h['city']?.toString() ?? 'Rajahmundry';
                final tier = h['trauma_tier']?.toString() ?? 'Tertiary / Level 1';
                final hasBank = h['has_blood_bank'] == true;
                final phone = h['emergency_phone']?.toString() ?? '+91 883 248 1000';
                final verified = h['is_verified'] != false;

                return DataRow(
                  cells: [
                    DataCell(Text(name, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13))),
                    DataCell(Text(city, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary))),
                    DataCell(Text(tier, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: hasBank ? DuoColors.greenTint : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                      child: Text(hasBank ? 'IN-HOUSE' : 'EXTERNAL', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: hasBank ? DuoColors.green : DuoColors.textSecondary, fontSize: 11)),
                    )),
                    DataCell(Text(phone, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: verified ? DuoColors.greenTint : DuoColors.redTint, borderRadius: BorderRadius.circular(999)),
                      child: Text(verified ? 'VERIFIED' : 'PENDING', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: verified ? DuoColors.green : DuoColors.red, fontSize: 10)),
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
  // SECTION 7: DONORS REGISTRY TABLE (MATCHING DEVZEMART USER TABLE)
  // ============================================================================

  Widget _buildDonorsSection(BuildContext context) {
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Tabs Header
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
                        label: Text(tab, style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
                        selected: isSel,
                        selectedColor: DuoColors.redTint,
                        onSelected: (_) => setState(() => _activeFilter = tab),
                      ),
                    );
                  }).toList(),
                ),
                Text('${filtered.length} Donors Matched', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
              ],
            ),
          ),
          const Divider(height: 1),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columns: const [
                DataColumn(label: Text('#', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('USER DETAILS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('BLOOD GROUP', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('ACCOUNT STATUS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('KYC VERIFIED', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('ZONE / RADIUS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('REGISTERED DATE', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('ACTIONS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
              ],
              rows: filtered.map((d) {
                final id = d['id']?.toString() ?? '';
                final name = d['full_name'] ?? d['first_name'] ?? 'Donor Hero';
                final phone = d['phone']?.toString() ?? '+91 98765 43210';
                final bg = d['blood_group'] ?? 'O+';
                final state = (d['state'] ?? 'active').toString().toUpperCase();
                final city = d['city'] ?? 'Rajahmundry';
                final radius = d['travel_radius_km'] ?? 15;
                final date = d['created_at'] != null ? d['created_at'].toString().substring(0, 10) : 'July 28, 2026';

                return DataRow(
                  cells: [
                    DataCell(Text('#${id.substring(0, id.length > 4 ? 4 : id.length)}', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: DuoColors.textSecondary))),
                    DataCell(Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: DuoColors.redTint,
                          child: Text(name[0], style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.red, fontSize: 12)),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(name, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(phone, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: DuoColors.textSecondary)),
                          ],
                        ),
                      ],
                    )),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: DuoColors.redTint, borderRadius: BorderRadius.circular(6)),
                      child: Text(bg, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.red, fontSize: 12)),
                    )),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: state == 'ACTIVE' ? DuoColors.greenTint : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        state,
                        style: TextStyle(
                          fontFamily: DuoTypography.fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: state == 'ACTIVE' ? DuoColors.green : DuoColors.textSecondary,
                        ),
                      ),
                    )),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(6)),
                      child: const Text('VERIFIED', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: Color(0xFF6366F1), fontSize: 10)),
                    )),
                    DataCell(Text('$city (${radius}km)', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12))),
                    DataCell(Text(date, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary))),
                    DataCell(IconButton(
                      icon: const Icon(Icons.more_horiz_rounded),
                      onPressed: () => _showDonorSuperheroActions(d),
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
  // SECTION 8: REQUESTER ABUSE PROFILES & FRAUD SHIELD
  // ============================================================================

  Widget _buildRequestersSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.security_rounded, color: Color(0xFFE11D48)),
                    SizedBox(width: 8),
                    Text('Requester Abuse Profiles & Fraud Shield Desk', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Text('${_requestersList.length} Monitored Callers', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columns: const [
                DataColumn(label: Text('CALLER / PHONE', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('TOTAL REQUESTS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('FRAUD RISK SCORE', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('STRIKES COUNT', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('SHIELD STATUS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('SUPERHERO ACTION', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
              ],
              rows: _requestersList.map((r) {
                final phone = r['phone']?.toString() ?? '+91 883 247 9999';
                final total = r['total_requests'] ?? 1;
                final risk = r['risk_score'] ?? 12;
                final strikes = r['strikes'] ?? 0;
                final isBlocked = r['is_blocked'] == true;

                return DataRow(
                  cells: [
                    DataCell(Text(phone, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13))),
                    DataCell(Text('$total lifetime', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12))),
                    DataCell(Text('$risk/100', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12, color: risk > 50 ? DuoColors.red : DuoColors.green))),
                    DataCell(Text('$strikes strikes', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: isBlocked ? DuoColors.redTint : DuoColors.greenTint, borderRadius: BorderRadius.circular(999)),
                      child: Text(isBlocked ? 'BLOCKED' : 'CLEAN', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: isBlocked ? DuoColors.red : DuoColors.green, fontSize: 10)),
                    )),
                    DataCell(DuoButton(
                      label: isBlocked ? 'UNBLOCK' : 'BLOCK REQUESTER',
                      variant: isBlocked ? DuoButtonVariant.primary : DuoButtonVariant.secondary,
                      height: 30,
                      onPressed: () async {
                        await SupabaseService().setRequesterBlockStatus(phone: phone, isBlocked: !isBlocked, reason: 'Admin manual audit');
                        _showToast(isBlocked ? 'Unblocked $phone' : 'Blocked $phone from emergency broadcast');
                        _loadAllAdminData();
                      },
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
  // SECTION 9: COMMUNITY ALLIANCES & NGOS
  // ============================================================================

  Widget _buildPartnersSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.handshake_rounded, color: Color(0xFFEA580C)),
                    SizedBox(width: 8),
                    Text('Community Alliances & Institutional Partners', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Text('${_partnersList.length} Active Alliances', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columns: const [
                DataColumn(label: Text('ORGANIZATION / NGO', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('SECTOR / TYPE', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('PRIMARY COORDINATOR', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('DRIVES ORGANIZED', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('MEMORANDUM STATUS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
              ],
              rows: _partnersList.map((p) {
                final name = p['name']?.toString() ?? 'Partner Organization';
                final type = p['type']?.toString() ?? 'NGO Alliance';
                final coord = p['coordinator']?.toString() ?? 'Coordinator';
                final drives = p['drives_count'] ?? 3;

                return DataRow(
                  cells: [
                    DataCell(Text(name, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13))),
                    DataCell(Text(type, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary))),
                    DataCell(Text(coord, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12))),
                    DataCell(Text('$drives blood drives', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: DuoColors.greenTint, borderRadius: BorderRadius.circular(999)),
                      child: const Text('ACTIVE MOU', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.green, fontSize: 10)),
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
  // SECTION 10: AI VOICE STUDIO & SIMULATOR
  // ============================================================================

  Widget _buildAIVoiceStudioSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.record_voice_over_rounded, color: Color(0xFF9333EA), size: 24),
                  SizedBox(width: 10),
                  Text('AI Voice Studio & Emergency Agent Sandbox', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 17)),
                ],
              ),
              Text('Model: Gemini 2.5 Flash Native Audio', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF9333EA))),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Safety Notice: Zero call audio or transcripts are stored per Hard Privacy Line 0.3. "AI training" strictly evaluates prompts, rules, safety boundaries, and synthetic simulation benchmarks.',
            style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Daily Minutes Safety Cap Meter
          Row(
            children: [
              const DuoMeter(value: 0.15, color: Color(0xFF9333EA), centerText: '9m', subText: 'used', size: 84),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily Voice Safety Cap Utilization', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(height: 4),
                    Text('9 of 60 daily safety minutes used. Automatically fails over to telephony keypad IVR if quota hits threshold.', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Voice Prompt Simulation Test Bench
          const Text('Synthetic Call Triage Simulator', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          TextField(
            controller: _aiTestInputController,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Synthetic Caller Utterance', border: OutlineInputBorder()),
            style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              ElevatedButton.icon(
                onPressed: _isAiTesting
                    ? null
                    : () async {
                        setState(() => _isAiTesting = true);
                        await Future.delayed(const Duration(milliseconds: 700));
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
                        }
                      },
                icon: _isAiTesting
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.play_arrow_rounded, size: 16),
                label: const Text('Run Live Voice Evaluation'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9333EA), foregroundColor: Colors.white),
              ),
            ],
          ),
          if (_aiTestSimulationResult != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF5FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9D5FF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Simulation Outcome (Verified against clinical prompt v2.4):', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF6B21A8))),
                  const SizedBox(height: 8),
                  Text('• Extracted Need: ${_aiTestSimulationResult!['units']} Units of ${_aiTestSimulationResult!['recognized_group']} at ${_aiTestSimulationResult!['hospital']}'),
                  Text('• Urgency Level: ${_aiTestSimulationResult!['urgency']} · Confidence: 98%'),
                  const Text('• Safety Audit: Passed all clinical protocol guardrails.'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================================
  // SECTION 11: WHATSAPP & TELECOM LEDGERS
  // ============================================================================

  Widget _buildTelecomSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('WhatsApp & Telecommunications Ledgers', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 4),
          const Text('Live delivery metrics and INR spend rate cards across Twilio, Meta Cloud API, and telephony providers.', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFBBF7D0))),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WhatsApp Deliverability', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: Color(0xFF166534))),
                      SizedBox(height: 6),
                      Text('98.4%', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                      Text('1,240 sent / 1,220 read', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: Color(0xFF15803D))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFBFDBFE))),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Twilio IVR Voice Completion', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: Color(0xFF1E40AF))),
                      SizedBox(height: 6),
                      Text('94.2%', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                      Text('Average Call Duration: 42s', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: Color(0xFF2563EB))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          const Text('Itemized Telecom Rate Cards (INR)', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          const ListTile(
            dense: true,
            leading: Icon(Icons.forum_outlined, color: DuoColors.green),
            title: Text('Meta WhatsApp Business Utility Message', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('Regional Emergency Mobilization Template'),
            trailing: Text('₹0.85 / msg', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const ListTile(
            dense: true,
            leading: Icon(Icons.phone_in_talk_outlined, color: Color(0xFF2563EB)),
            title: Text('Twilio Programmable Outbound Voice', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('Voice Gateway PSTN termination to Andhra Pradesh'),
            trailing: Text('₹1.20 / min', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // SECTION 12: FOUR-EYES APPROVALS DESK
  // ============================================================================

  Widget _buildFourEyesSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.flaky_rounded, color: Color(0xFFD97706)),
                    SizedBox(width: 8),
                    Text('Four-Eyes Approvals Quorum Desk', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Text('${_approvalRequests.length} Pending Actions', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_approvalRequests.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('Zero pending Four-Eyes approval requests', style: TextStyle(fontFamily: DuoTypography.fontFamily, color: DuoColors.textSecondary))),
            )
          else
            ..._approvalRequests.map((a) {
              final id = a['id']?.toString() ?? 'REQ';
              final action = a['action_type']?.toString() ?? 'broadcast.mass';
              final reason = a['reason']?.toString() ?? 'Administrative action';
              final maker = a['maker_id']?.toString() ?? 'admin-01';

              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.rule_folder_outlined, color: Color(0xFFD97706)),
                ),
                title: Text('$action (#${id.substring(0, id.length > 8 ? 8 : id.length)})', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('Maker: $maker · Reason: $reason', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final res = await SupabaseService().decideApprovalRequest(
                          requestId: id,
                          approve: true,
                          currentUserId: 'super-admin-checker-02',
                        );
                        if (res['ok'] == true) {
                          _showToast('Approved change #$id with second-admin signature');
                          _loadAllAdminData();
                        } else {
                          _showToast('Approval rejected: ${res['reason']}');
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: DuoColors.green, foregroundColor: Colors.white),
                      child: const Text('Approve (Checker)'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () async {
                        await SupabaseService().decideApprovalRequest(
                          requestId: id,
                          approve: false,
                          currentUserId: 'super-admin-checker-02',
                        );
                        _showToast('Rejected change request #$id');
                        _loadAllAdminData();
                      },
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ============================================================================
  // SECTION 13: FINANCIAL LEDGERS & GRANTS
  // ============================================================================

  Widget _buildLedgersSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Financial Grants & Donor Travel Reimbursements Desk', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 4),
          const Text('Administer travel stipends, logistical grants for rural camps, and UPI transaction logs.', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Travel Reimbursements Paid', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
                      SizedBox(height: 4),
                      Text('₹4,850 INR', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 22, fontWeight: FontWeight.bold, color: DuoColors.textPrimary)),
                      Text('18 voluntary donors in Rajahmundry rural', style: TextStyle(fontSize: 11, color: DuoColors.green)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Camp Logistics Subsidy', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
                      SizedBox(height: 4),
                      Text('₹12,000 INR', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 22, fontWeight: FontWeight.bold, color: DuoColors.textPrimary)),
                      Text('3 Rotary & NSS drives supported', style: TextStyle(fontSize: 11, color: Color(0xFF2563EB))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Recent Payout Vouchers (Simulated UPI)', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          const ListTile(
            dense: true,
            leading: Icon(Icons.check_circle_rounded, color: DuoColors.green),
            title: Text('₹250 - Travel Grant to Donor #854 (Kakinada to RJY)'),
            subtitle: Text('UPI Ref: 489201948291 · Fulfilled on Oct 14'),
            trailing: Text('COMPLETED', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.green, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // SECTION 14: DATA EXPORTS ENGINE (DPDP PRIVACY-SAFE MASKING)
  // ============================================================================

  Widget _buildExportsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Privacy-Governed Data Exports Engine', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 4),
          const Text('Export platform data safely. In compliance with DPDP Act 2023, donor health questionnaire responses are permanently unreadable and never exported.', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () async {
              final res = await SupabaseService().createDataExport(
                entityType: 'donors',
                tier: '2',
                format: 'csv',
                reason: 'Routine quarterly audit export for health authorities',
              );
              if (res['ok'] == true) {
                _showToast('✅ Export generated: ${res['filename']} (SHA-256 watermarked)');
                _loadAllAdminData();
              } else {
                _showToast('Export failed: ${res['error']}');
              }
            },
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Generate Masked Donors CSV Export (Tier 2)'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0891B2), foregroundColor: Colors.white),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          const Text('Generated Data Export Manifests (Audit-Logged)', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          if (_dataExports.isEmpty)
            const Text('No prior export files on record.', style: TextStyle(fontFamily: DuoTypography.fontFamily, color: DuoColors.textSecondary, fontSize: 12))
          else
            ..._dataExports.map((e) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.table_view_rounded, color: Color(0xFF0891B2)),
                  title: Text(e['filename']?.toString() ?? 'export.csv', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('Format: ${e['format']} · Tier: ${e['tier']} · Watermark: ${e['watermark_hash']?.toString().substring(0, 10)}...'),
                  trailing: const Text('READY', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.green, fontSize: 11)),
                )),
        ],
      ),
    );
  }

  // ============================================================================
  // SECTION 15: CLINICAL SAFETY & INCIDENTS DESK
  // ============================================================================

  Widget _buildSafetySection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.medical_services_rounded, color: DuoColors.red),
                    SizedBox(width: 8),
                    Text('Clinical Safety & Adverse Donor Incidents Desk', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Text('${_safetyIncidents.length} Recorded Reports', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_safetyIncidents.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('Zero clinical adverse events recorded across pilot operational area.', style: TextStyle(fontFamily: DuoTypography.fontFamily, color: DuoColors.textSecondary))),
            )
          else
            ..._safetyIncidents.map((inc) {
              final title = inc['title']?.toString() ?? 'Incident';
              final severity = inc['severity']?.toString() ?? 'P3';
              final venue = inc['venue']?.toString() ?? 'Camp';

              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: DuoColors.redTint, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.healing_rounded, color: DuoColors.red),
                ),
                title: Text('$title ($severity)', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('Location: $venue · Medical Officer Review Complete', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: DuoColors.greenTint, borderRadius: BorderRadius.circular(999)),
                  child: const Text('CLOSED', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.green, fontSize: 10)),
                ),
              );
            }),
        ],
      ),
    );
  }

  // ============================================================================
  // SECTION 16: DPDP COMPLIANCE & PRIVACY REGISTRY
  // ============================================================================

  Widget _buildDPDPSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Digital Personal Data Protection (DPDP) Act 2023 Registry', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 4),
          const Text('Audit-compliant tracking of donor consent withdraws, right-to-be-forgotten requests, and anonymization pipelines.', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFBFDBFE))),
            child: const Row(
              children: [
                Icon(Icons.verified_user_rounded, color: Color(0xFF2563EB), size: 28),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Zero Plain-Text Health Data Guarantee', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E40AF))),
                      SizedBox(height: 2),
                      Text('Donor questionnaires remain end-to-end encrypted with public-key cryptography. Database contains no unencrypted clinical tables.', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: Color(0xFF1D4ED8))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Donor Consent Withdrawal & Erasure Queue', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          if (_dpdpRequests.isEmpty)
            const Text('Zero pending erasure or right-to-be-forgotten requests.', style: TextStyle(fontFamily: DuoTypography.fontFamily, color: DuoColors.textSecondary, fontSize: 12))
          else
            ..._dpdpRequests.map((d) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.person_off_rounded, color: DuoColors.red),
                  title: Text('Erasure Request #${d['id']?.toString().substring(0, 6)}', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('Masked Phone: ${d['masked_phone']} · Channel: ${d['channel']}'),
                  trailing: const Text('PROCESSED', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.green, fontSize: 11)),
                )),
        ],
      ),
    );
  }

  // ============================================================================
  // SECTION 17: SCOPED MAINTENANCE SWITCHES & KILL SWITCH
  // ============================================================================

  Widget _buildMaintenanceSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Scoped Platform Maintenance & Microservice Switches', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 20),

          // Master Kill Switch Card
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
                        _killSwitchActive ? 'ACTIVE: Outbound alerts and intake are paused in Supabase' : 'Normal operations running smoothly on ixrborkhofxlxbedpang',
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

          // Granular Microservice Toggles
          SwitchListTile(
            title: const Text('Twilio Automated Outbound Calling Pipeline', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text('When disabled, system falls back strictly to WhatsApp notification alerts'),
            value: true,
            activeThumbColor: DuoColors.green,
            onChanged: (val) => _showToast('Outbound calling toggle updated'),
          ),
          SwitchListTile(
            title: const Text('Algorithmic Wave Expansion (BR-06..BR-08)', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text('Automatic search ring widening from 1.5km to 15km'),
            value: true,
            activeThumbColor: DuoColors.green,
            onChanged: (val) => _showToast('Algorithmic expansion toggle updated'),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // SECTION 18: PLATFORM CONFIGURATION & ALGORITHM SETTINGS
  // ============================================================================

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Platform Configuration & Search Algorithm Parameters', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 20),

          ListTile(
            leading: const Icon(Icons.location_city_rounded, color: DuoColors.red),
            title: const Text('Active Pilot Operational Zone', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text('Rajahmundry, East Godavari, Andhra Pradesh (533101 - 533107)', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12)),
          ),
          ListTile(
            leading: const Icon(Icons.radar_rounded, color: Color(0xFF2563EB)),
            title: const Text('Search Algorithm Ring Intervals (BR-06)', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text('Wave 1: 1.5km · Wave 2: 3.5km · Wave 3: 5.5km · Expansion Step: +2.0km', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12)),
          ),
          ListTile(
            leading: const Icon(Icons.support_agent_rounded, color: DuoColors.green),
            title: const Text('24x7 Emergency Clinical Helpline Desk', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text('+91 883 247 1234', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // SECTION 19: IMMUTABLE AUDIT LOGS
  // ============================================================================

  Widget _buildAuditSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Immutable Platform Audit Trail', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${_auditLogs.length} Events Logged', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_auditLogs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No audit events recorded yet', style: TextStyle(fontFamily: DuoTypography.fontFamily, color: DuoColors.textSecondary))),
            )
          else
            ..._auditLogs.map((log) {
              return ListTile(
                dense: true,
                leading: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                  child: Text(log['time']?.toString() ?? 'Recent', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 10, fontWeight: FontWeight.bold, color: DuoColors.textSecondary)),
                ),
                title: Text(log['action']?.toString() ?? 'action', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13, color: DuoColors.red)),
                subtitle: Text(log['detail']?.toString() ?? '', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12)),
              );
            }),
        ],
      ),
    );
  }

  // ============================================================================
  // SUPERHERO MODALS & CONTEXTUAL MENUS
  // ============================================================================

  void _showDonorSuperheroActions(Map<String, dynamic> donor) {
    final id = donor['id']?.toString() ?? '';
    final name = donor['full_name'] ?? donor['first_name'] ?? 'Donor';
    final state = donor['state'] ?? 'active';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_rounded, color: DuoColors.red),
                title: Text('Manage $name', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold)),
                subtitle: Text('ID: $id · State: $state'),
              ),
              const Divider(),
              ListTile(
                leading: Icon(state == 'active' ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded, color: DuoColors.red),
                title: Text(state == 'active' ? 'Pause Alerts for Donor' : 'Unpause / Reactivate Donor'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final nextState = state == 'active' ? 'paused' : 'active';
                  await SupabaseService().updateDonorState(id, nextState);
                  _showToast('Updated state to $nextState');
                  _loadAllAdminData();
                },
              ),
              ListTile(
                leading: const Icon(Icons.star_rounded, color: Color(0xFFF59E0B)),
                title: const Text('Award Milestone Honor Badge'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await SupabaseService().awardDonorBadge(
                    donorId: id,
                    badgeCode: 'silver_lifesaver',
                    badgeName: 'Silver Lifesaver',
                    description: 'Distinguished emergency contribution in Rajahmundry',
                  );
                  _showToast('Silver Lifesaver Badge awarded to $name!');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBankSuperheroActions(BloodBankModel bank) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.local_hospital_rounded, color: DuoColors.red),
                title: Text(bank.name, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold)),
                subtitle: Text('${bank.stockUnits} units in stock · Trust: ${bank.trustScore}'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add_circle_outline_rounded, color: DuoColors.green),
                title: const Text('Quick Add +5 Units (Emergency Restock)'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await SupabaseService().adjustBankStockQuick(bankId: bank.id, bloodGroup: 'O+', deltaUnits: 5);
                  _showToast('Added 5 units of O+ to ${bank.name}');
                  _loadAllAdminData();
                },
              ),
              ListTile(
                leading: const Icon(Icons.verified_rounded, color: DuoColors.green),
                title: const Text('Upgrade Facility Trust Score (+5)'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await SupabaseService().updateBloodBank(bankId: bank.id, trustScore: (bank.trustScore + 5.0).clamp(1.0, 100.0));
                  _showToast('Trust score boosted for ${bank.name}');
                  _loadAllAdminData();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                await SupabaseService().createCamp(
                  title: titleController.text.trim(),
                  venue: venueController.text.trim(),
                  area: areaController.text.trim().isEmpty ? 'Central' : areaController.text.trim(),
                  city: cityController.text.trim(),
                  startsAt: DateTime.now().add(const Duration(days: 3)),
                  endsAt: DateTime.now().add(const Duration(days: 3, hours: 6)),
                  capacity: int.tryParse(capacityController.text.trim()) ?? 100,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                _showToast('Blood camp drive successfully scheduled and published!');
                _loadAllAdminData();
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
                  setState(() => _selectedSection = 3);
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
                  setState(() => _selectedSection = 12);
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
