// ============================================================================
// BloodNorms | admin_console_screen.dart
// Executive Operations & Superhero Admin Command Center
// Faithful SaaS Dashboard Design (Matching DevzeMart & Confidency OS aesthetic)
// Categorized Left Sidebar, KPI metric cards with subtle accents, dense tables,
// live auto-refresh telemetry, pagination, and Superhero Admin superpowers.
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

  // Live Supabase data
  List<Map<String, dynamic>> _liveRequests = [];
  List<Map<String, dynamic>> _donorsList = [];
  List<BloodBankModel> _banksList = [];
  List<CampModel> _campsList = [];
  List<Map<String, dynamic>> _auditLogs = [];
  List<Map<String, dynamic>> _broadcastHistory = [];

  // Search & Filter state
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'All';

  // Broadcast state
  final TextEditingController _broadcastTitleController = TextEditingController(
    text: 'Mega Voluntary Blood Camp at Rotary Diamond Hall',
  );
  final TextEditingController _broadcastMsgController = TextEditingController(
    text: 'Dear BloodNorms Hero, a voluntary blood camp is organized this Sunday 9 AM at Rotary Diamond Hall, Main Road. Would you like to attend and donate? Reply YES to confirm.',
  );
  String _selectedBroadcastType = 'camp_invitation';
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
  String _previewLanguage = 'en';

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

  // Sidebar Menu Structure (Matching DevzeMart & Confidency OS layout)
  final List<Map<String, dynamic>> _navGroups = [
    {
      'header': 'COMMAND',
      'items': [
        {'id': 0, 'title': 'Overview', 'icon': Icons.dashboard_rounded},
        {'id': 1, 'title': 'Live Monitor', 'icon': Icons.radar_rounded, 'badge': 'LIVE'},
        {'id': 2, 'title': 'Needs Human', 'icon': Icons.warning_rounded},
      ],
    },
    {
      'header': 'OPERATIONS',
      'items': [
        {'id': 3, 'title': 'Regional Broadcast', 'icon': Icons.campaign_rounded},
        {'id': 4, 'title': 'Blood Camps', 'icon': Icons.event_available_rounded},
        {'id': 5, 'title': 'Banks & Inventory', 'icon': Icons.local_hospital_rounded},
      ],
    },
    {
      'header': 'PEOPLE',
      'items': [
        {'id': 6, 'title': 'Donors Registry', 'icon': Icons.people_rounded},
      ],
    },
    {
      'header': 'TELEMETRY & AI',
      'items': [
        {'id': 7, 'title': 'Inbound & Voice AI', 'icon': Icons.mic_rounded},
      ],
    },
    {
      'header': 'SYSTEM',
      'items': [
        {'id': 8, 'title': 'Platform Settings', 'icon': Icons.settings_rounded},
        {'id': 9, 'title': 'Audit Logs', 'icon': Icons.shield_rounded},
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
    super.dispose();
  }

  Future<void> _loadAllAdminData() async {
    setState(() => _isLoading = true);
    try {
      final reqs = await SupabaseService().getActiveRequests();
      final donors = await SupabaseService().getAllDonors();
      final banks = await SupabaseService().getNearestBanks(
        lat: AppConstants.defaultLat,
        lng: AppConstants.defaultLng,
      );
      final camps = await SupabaseService().getCamps();
      final kill = await SupabaseService().getKillSwitch();
      final audit = await SupabaseService().getRecentActivityLog();
      final broadcasts = await SupabaseService().getBroadcastHistory();

      if (mounted) {
        setState(() {
          _liveRequests = reqs;
          _donorsList = donors;
          _banksList = banks;
          _campsList = camps;
          _killSwitchActive = kill;
          _auditLogs = audit;
          _broadcastHistory = broadcasts;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
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

  // --- SUPERHERO ACTIONS ---

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
              'This broadcast reaches $count donors, which exceeds the 200-recipient policy threshold. It must be submitted to the Approvals Inbox for a second checker.',
              style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 13, color: DuoColors.textSecondary),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: DuoColors.red),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await SupabaseService().submitApprovalRequest(
                    actionType: 'broadcast.mass',
                    reason: 'Mass regional outreach: $title for $count recipients',
                    diffPayload: {'title': title, 'city': _selectedTargetCity, 'radius_km': _broadcastRadiusKm, 'recipients': count},
                  );
                  _showToast('Queued for Four-Eyes approval in Approvals Inbox');
                },
                child: const Text('SUBMIT APPROVAL REQUEST', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      } else {
        _showToast('Broadcast notice: ${res['error']}');
      }
    }
  }

  Future<void> _toggleKillSwitch(bool value) async {
    if (value) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: DuoColors.red, width: 2.0),
          ),
          title: const Row(
            children: [
              Icon(Icons.power_settings_new_rounded, color: DuoColors.red, size: 24),
              SizedBox(width: 10),
              Text(
                'ACTIVATE KILL SWITCH?',
                style: TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  color: DuoColors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: const Text(
            'This will IMMEDIATELY halt all new emergency broadcasts and outbound alerts across Supabase. Public blood bank directory will remain read-only.',
            style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 13, color: DuoColors.textSecondary),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: DuoButton(
                    label: 'CANCEL',
                    height: 44,
                    variant: DuoButtonVariant.secondary,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DuoButton(
                    label: 'ACTIVATE NOW',
                    height: 44,
                    variant: DuoButtonVariant.destructive,
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await SupabaseService().setKillSwitch(true);
                      setState(() => _killSwitchActive = true);
                      _showToast('Platform Kill Switch Activated in Supabase');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      await SupabaseService().setKillSwitch(false);
      setState(() => _killSwitchActive = false);
      _showToast('Platform returned to Normal Operations');
    }
  }

  void _showCreateCampModal() {
    final titleCtrl = TextEditingController(text: 'Rotary Community Blood Camp');
    final venueCtrl = TextEditingController(text: 'Rotary Diamond Hall, Main Road');
    final areaCtrl = TextEditingController(text: 'Innespeta, Rajahmundry');
    int capacity = 200;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Create Blood Donation Camp', style: DuoTypography.title2(color: DuoColors.textPrimary)),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: 'Camp Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: venueCtrl,
              decoration: InputDecoration(
                labelText: 'Venue Address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: const TextStyle(fontFamily: DuoTypography.fontFamily),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: areaCtrl,
              decoration: InputDecoration(
                labelText: 'Area / Landmark',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: const TextStyle(fontFamily: DuoTypography.fontFamily),
            ),
            const SizedBox(height: 20),
            DuoButton(
              label: 'PUBLISH CAMP DRIVE',
              icon: Icons.campaign_rounded,
              variant: DuoButtonVariant.primary,
              height: 48,
              onPressed: () async {
                Navigator.pop(ctx);
                await SupabaseService().createCamp(
                  title: titleCtrl.text.trim(),
                  venue: venueCtrl.text.trim(),
                  area: areaCtrl.text.trim(),
                  startsAt: DateTime.now().add(const Duration(days: 2)),
                  endsAt: DateTime.now().add(const Duration(days: 2, hours: 8)),
                  capacity: capacity,
                );
                _showToast('New blood donation camp published to Supabase');
                _loadAllAdminData();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDonorSuperheroActions(Map<String, dynamic> donor) {
    final id = donor['id']?.toString() ?? '';
    final name = donor['full_name'] ?? donor['first_name'] ?? 'Donor';
    final phone = donor['phone']?.toString() ?? '';
    final bg = donor['blood_group']?.toString() ?? 'O+';
    final state = (donor['state'] ?? 'active').toString().toLowerCase();
    final trust = (donor['trust_level'] as num?)?.toInt() ?? 1;
    final donations = donor['donations_count'] ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: DuoTypography.title2(color: DuoColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text('$bg · $phone · $donations donations', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: DuoColors.redTint,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: DuoColors.redShadow, width: 1.5),
                  ),
                  child: Text(
                    'TRUST LEVEL $trust',
                    style: const TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      color: DuoColors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            Text('SUPERHERO DONOR ACTIONS', style: DuoTypography.caption(color: DuoColors.textSecondary)),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: DuoButton(
                    label: 'CALL DIRECTLY',
                    icon: Icons.phone_rounded,
                    height: 44,
                    variant: DuoButtonVariant.primary,
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
                      if (await canLaunchUrl(uri)) await launchUrl(uri);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DuoButton(
                    label: 'WHATSAPP',
                    icon: Icons.chat_bubble_rounded,
                    height: 44,
                    variant: DuoButtonVariant.success,
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
                      final uri = Uri.parse('https://wa.me/$cleanPhone');
                      if (await canLaunchUrl(uri)) await launchUrl(uri);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: DuoButton(
                    label: 'PROMOTE TRUST LEVEL',
                    icon: Icons.verified_user_rounded,
                    height: 44,
                    variant: DuoButtonVariant.secondary,
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final nextLevel = (trust % 3) + 1;
                      await SupabaseService().updateDonorTrustLevel(id, nextLevel);
                      _showToast('Promoted $name to Trust Level $nextLevel in Supabase');
                      _loadAllAdminData();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: DuoButton(
                    label: state == 'active' ? 'PAUSE DONOR' : 'ACTIVATE DONOR',
                    height: 44,
                    variant: state == 'active' ? DuoButtonVariant.secondary : DuoButtonVariant.success,
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final newState = state == 'active' ? 'paused' : 'active';
                      await SupabaseService().updateDonorState(id, newState);
                      _showToast('Donor state set to ${newState.toUpperCase()}');
                      _loadAllAdminData();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DuoButton(
                    label: 'DELETE DONOR',
                    height: 44,
                    variant: DuoButtonVariant.destructive,
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await SupabaseService().deleteDonor(id);
                      _showToast('Donor deleted from Supabase');
                      _loadAllAdminData();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showBankSuperheroActions(BloodBankModel bank) {
    String selectedGroup = 'O+';
    int delta = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bank.name, style: DuoTypography.title2(color: DuoColors.textPrimary)),
              const SizedBox(height: 4),
              Text(bank.address, style: DuoTypography.caption(color: DuoColors.textSecondary)),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              Text('QUICK STOCK INJECTION / OVERRIDE', style: DuoTypography.caption(color: DuoColors.textSecondary)),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedGroup,
                      decoration: InputDecoration(
                        labelText: 'Blood Group',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'O+', child: Text('O+')),
                        DropdownMenuItem(value: 'O-', child: Text('O-')),
                        DropdownMenuItem(value: 'A+', child: Text('A+')),
                        DropdownMenuItem(value: 'A-', child: Text('A-')),
                        DropdownMenuItem(value: 'B+', child: Text('B+')),
                        DropdownMenuItem(value: 'B-', child: Text('B-')),
                        DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                        DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                      ],
                      onChanged: (val) => setModalState(() => selectedGroup = val ?? 'O+'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: DuoColors.red),
                        onPressed: () => setModalState(() {
                          if (delta > -10) delta -= 1;
                        }),
                      ),
                      Text(
                        delta > 0 ? '+$delta' : '$delta',
                        style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: DuoColors.green),
                        onPressed: () => setModalState(() => delta += 1),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DuoButton(
                label: 'APPLY STOCK UPDATE ($selectedGroup ${delta >= 0 ? '+$delta' : '$delta'})',
                icon: Icons.inventory_2_rounded,
                height: 44,
                variant: DuoButtonVariant.primary,
                onPressed: () async {
                  Navigator.pop(ctx);
                  await SupabaseService().adjustBankStockQuick(
                    bankId: bank.id,
                    bloodGroup: selectedGroup,
                    deltaUnits: delta,
                  );
                  _showToast('Updated $selectedGroup stock by $delta units at ${bank.name}');
                  _loadAllAdminData();
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: DuoButton(
                      label: bank.is24x7 ? 'SET AS STANDARD HOURS' : 'SET AS 24x7 FACILITY',
                      height: 44,
                      variant: DuoButtonVariant.secondary,
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await SupabaseService().updateBloodBank(
                          bankId: bank.id,
                          is24x7: !bank.is24x7,
                        );
                        _showToast('Toggled 24x7 status for ${bank.name}');
                        _loadAllAdminData();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickActionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Superhero Quick Actions', style: DuoTypography.title2(color: DuoColors.textPrimary)),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: DuoColors.redTint, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.campaign_rounded, color: DuoColors.red),
              ),
              title: const Text('Dispatch Regional Broadcast', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold)),
              subtitle: const Text('Send camp invitations or shortage alerts to donors'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _selectedSection = 3);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: DuoColors.greenTint, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.event_available_rounded, color: DuoColors.green),
              ),
              title: const Text('Publish Blood Camp Drive', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold)),
              subtitle: const Text('Schedule community donation drive in Rajahmundry'),
              onTap: () {
                Navigator.pop(ctx);
                _showCreateCampModal();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Color(0xFFEFF6FF), borderRadius: BorderRadius.all(Radius.circular(12))),
                child: const Icon(Icons.power_settings_new_rounded, color: Color(0xFF2563EB)),
              ),
              title: const Text('Toggle Platform Kill Switch', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold)),
              subtitle: const Text('Emergency platform broadcast halt'),
              onTap: () {
                Navigator.pop(ctx);
                _toggleKillSwitch(!_killSwitchActive);
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- BUILD UI ---

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: isDesktop
            ? Row(
                children: [
                  _buildSidebar(isDesktop: true),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: DuoColors.red))
                        : _buildMainDashboard(context),
                  ),
                ],
              )
            : Scaffold(
                backgroundColor: const Color(0xFFF4F6F9),
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: DuoColors.red,
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
                      icon: const Icon(Icons.add_circle_outline_rounded, color: DuoColors.red),
                      onPressed: _showQuickActionsSheet,
                    ),
                  ],
                ),
                drawer: Drawer(child: _buildSidebar(isDesktop: false)),
                body: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: DuoColors.red))
                    : _buildMainDashboard(context),
              ),
      ),
    );
  }

  // --- 1. LEFT SIDEBAR (Matching DevzeMart & Confidency OS) ---
  Widget _buildSidebar({required bool isDesktop}) {
    return Container(
      width: 260,
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
                      'Admin Command',
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

          // Search Box in Sidebar
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
          const SizedBox(height: 12),

          // Navigation Links
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
                      final isSelected = _selectedSection == id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 3),
                        decoration: BoxDecoration(
                          color: isSelected ? DuoColors.red : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              setState(() => _selectedSection = id);
                              if (!isDesktop) Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                              child: Row(
                                children: [
                                  Icon(
                                    icon,
                                    size: 18,
                                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 12),
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
                                        color: isSelected ? Colors.white.withValues(alpha: 0.2) : DuoColors.redTint,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        badge,
                                        style: TextStyle(
                                          fontFamily: DuoTypography.fontFamily,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : DuoColors.red,
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

          // Bottom Super Admin Profile Card
          Container(
            padding: const EdgeInsets.all(16),
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
                        'Super Admin',
                        style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12, color: DuoColors.textPrimary),
                      ),
                      Text(
                        'ixrborkhofxlxbedpang',
                        style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 10, color: DuoColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
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

  // --- 2. MAIN DASHBOARD CONTENT ---
  Widget _buildMainDashboard(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      children: [
        // Top Header Row (Breadcrumbs + Actions)
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
                        'Live Sync: Connected',
                        style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Sync Button
                OutlinedButton.icon(
                  onPressed: () {
                    _loadAllAdminData();
                    _showToast('Synced all tables with Supabase');
                  },
                  icon: const Icon(Icons.sync_rounded, size: 16, color: DuoColors.textPrimary),
                  label: const Text('Sync', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.textPrimary, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 10),

                // Quick Action Primary Button (Gradient matching image)
                ElevatedButton.icon(
                  onPressed: _showQuickActionsSheet,
                  icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                  label: const Text('Quick Action', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DuoColors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 6-Card Quick Stats KPI Row (Matching DevzeMart & Confidency OS)
        _buildKPIStatsRow(),
        const SizedBox(height: 24),

        // Section Content
        _buildActiveSectionContent(context),
      ],
    );
  }

  String _getCurrentSectionTitle() {
    switch (_selectedSection) {
      case 0:
        return 'Overview Dashboard';
      case 1:
        return 'Live Crisis Monitor';
      case 2:
        return 'Needs Human Queue';
      case 3:
        return 'Regional Broadcast Center';
      case 4:
        return 'Blood Donation Camps';
      case 5:
        return 'Blood Banks & Stock Desk';
      case 6:
        return 'Donors Registry';
      case 7:
        return 'Inbound Telemetry & AI';
      case 8:
        return 'Platform Settings';
      case 9:
      default:
        return 'Audit Logs';
    }
  }

  // --- 3. KPI STATS CARDS ROW (6 Horizontal Cards) ---
  Widget _buildKPIStatsRow() {
    final activeCrises = _liveRequests.where((r) => r['status'] == 'searching').length;
    final totalStock = _banksList.fold<int>(0, (sum, b) => sum + b.stockUnits);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildKPICard(
                title: 'Active Crises',
                value: '$activeCrises',
                delta: 'Realtime Radar',
                icon: Icons.radar_rounded,
                accentColor: DuoColors.red,
                bgGradient: const [Color(0xFFFEF2F2), Colors.white],
              ),
              const SizedBox(width: 12),
              _buildKPICard(
                title: 'Donors Registered',
                value: '${_donorsList.length}',
                delta: 'Verified Heroes',
                icon: Icons.people_rounded,
                accentColor: const Color(0xFF6366F1),
                bgGradient: const [Color(0xFFEEF2FF), Colors.white],
              ),
              const SizedBox(width: 12),
              _buildKPICard(
                title: 'Blood Centers',
                value: '${_banksList.length}',
                delta: 'Pilot Active',
                icon: Icons.local_hospital_rounded,
                accentColor: const Color(0xFF0EA5E9),
                bgGradient: const [Color(0xFFF0F9FF), Colors.white],
              ),
              const SizedBox(width: 12),
              _buildKPICard(
                title: 'Units Available',
                value: '$totalStock',
                delta: '8 Groups Total',
                icon: Icons.inventory_2_rounded,
                accentColor: DuoColors.green,
                bgGradient: const [Color(0xFFF0FDF4), Colors.white],
              ),
              const SizedBox(width: 12),
              _buildKPICard(
                title: 'Camps Scheduled',
                value: '${_campsList.length}',
                delta: 'Drives Live',
                icon: Icons.event_available_rounded,
                accentColor: const Color(0xFFF59E0B),
                bgGradient: const [Color(0xFFFFFBEB), Colors.white],
              ),
              const SizedBox(width: 12),
              _buildKPICard(
                title: 'Broadcast Reach',
                value: '${_broadcastHistory.length}',
                delta: 'Outbound Dispatches',
                icon: Icons.send_rounded,
                accentColor: const Color(0xFFEC4899),
                bgGradient: const [Color(0xFFFDF2F8), Colors.white],
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
    required String delta,
    required IconData icon,
    required Color accentColor,
    required List<Color> bgGradient,
  }) {
    return Container(
      width: 175,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), offset: Offset(0, 2), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: bgGradient.first,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: bgGradient.first,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  delta,
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

  // --- 4. SECTION ROUTER ---
  Widget _buildActiveSectionContent(BuildContext context) {
    switch (_selectedSection) {
      case 0:
        return _buildOverviewSection(context);
      case 1:
        return _buildLiveMonitorSection(context);
      case 2:
        return _buildNeedsHumanSection(context);
      case 3:
        return _buildBroadcastSection(context);
      case 4:
        return _buildCampsSection(context);
      case 5:
        return _buildBanksSection(context);
      case 6:
        return _buildDonorsSection(context);
      case 7:
        return _buildInboundSection(context);
      case 8:
        return _buildSettingsSection(context);
      case 9:
      default:
        return _buildAuditSection(context);
    }
  }

  // --- SECTION 0: OVERVIEW (DASHBOARD) ---
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
                    icon: const Text('View All in Radar', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12, color: DuoColors.red)),
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
        const SizedBox(height: 24),

        // 2-Column Split: Recent Donors & Recent Activity
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
                          onPressed: () => setState(() => _selectedSection = 6),
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
                          onPressed: () => setState(() => _selectedSection = 9),
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

  // --- SECTION 1: LIVE MONITOR (CRISIS RADAR TABLE) ---
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
                const Text('Live Emergency Requests', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
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
                  DataColumn(label: Text('CONTACTED / ACCEPTED', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
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
                      DataCell(Text('#${id.substring(0, 4)}', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: DuoColors.textSecondary))),
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

  // --- SECTION 2: NEEDS HUMAN QUEUE ---
  Widget _buildNeedsHumanSection(BuildContext context) {
    final needsHuman = _liveRequests.where((r) {
      final isSearching = r['status'] == 'searching' || r['status'] == 'active';
      final ringKm = (r['current_ring_km'] as num?)?.toDouble() ?? 0.0;
      final accepted = (r['donors_accepted'] as num?)?.toInt() ?? 0;
      return isSearching && (ringKm >= 5.0 || accepted == 0);
    }).toList();

    return Column(
      children: [
        if (needsHuman.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.check_circle_rounded, color: DuoColors.green, size: 48),
                  SizedBox(height: 12),
                  Text('All Automated Systems Functioning Normally', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Zero caller escalations or exhausted search rings pending manual review.', style: TextStyle(fontFamily: DuoTypography.fontFamily, color: DuoColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          )
        else
          ...needsHuman.map((r) => _buildEmergencyRow(r)),
      ],
    );
  }

  // --- SECTION 3: REGIONAL BROADCAST (CAMP INVITES & ALERTS) ---
  Widget _buildBroadcastSection(BuildContext context) {
    final eligibleCount = _audiencePreview['eligible_count'] as int? ?? 0;
    final suppressedCount = _audiencePreview['suppressed_count'] as int? ?? 0;
    final costEstimate = _audiencePreview['estimated_cost_inr'] ?? 0.0;
    final requiresApproval = _audiencePreview['requires_approval'] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Broadcast Composer Card
        Container(
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
                      Icon(Icons.location_on_rounded, color: DuoColors.red, size: 22),
                      SizedBox(width: 8),
                      Text('Geo-Targeted Regional Broadcast Dispatcher', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: DuoColors.greenTint, borderRadius: BorderRadius.circular(999)),
                    child: const Text('Radius & City Fenced', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.green, fontSize: 10)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Target donors strictly within a camp venue radius and city to avoid messaging out-of-region donors.', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
              const SizedBox(height: 16),

              // 1. Camp Selection Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCampId,
                decoration: InputDecoration(
                  labelText: 'Select Blood Camp / Event Venue',
                  prefixIcon: const Icon(Icons.event_available_rounded, color: DuoColors.red, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Custom Outreach (Coordinates / Manual City)')),
                  ..._campsList.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text('${c.title} — ${c.venue} (${c.area})', overflow: TextOverflow.ellipsis),
                  )),
                ],
                onChanged: (campId) {
                  setState(() {
                    _selectedCampId = campId;
                    if (campId != null) {
                      final c = _campsList.firstWhere((x) => x.id == campId, orElse: () => _campsList.first);
                      _broadcastTitleController.text = 'Mega Voluntary Blood Camp at ${c.venue}';
                      _broadcastMsgController.text = 'Dear BloodNorms Hero, a voluntary blood camp is organized at ${c.venue}, ${c.area} on ${c.startsAt.day}/${c.startsAt.month}. Reply YES to confirm participation!';
                      _selectedTargetCity = 'Rajahmundry';
                    }
                  });
                  _updateAudiencePreview();
                },
              ),
              const SizedBox(height: 16),

              // 2. Region & Geo-Fencing Controls
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('GEOGRAPHIC TARGETING & RADIUS CONTROLS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, fontWeight: FontWeight.bold, color: DuoColors.textSecondary)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedTargetCity,
                            decoration: InputDecoration(
                              labelText: 'Target Region / City',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Rajahmundry', child: Text('Rajahmundry (Pilot District)')),
                              DropdownMenuItem(value: 'Kakinada', child: Text('Kakinada (Coastal Hub)')),
                              DropdownMenuItem(value: 'Visakhapatnam', child: Text('Visakhapatnam (North Coast)')),
                              DropdownMenuItem(value: 'Vijayawada', child: Text('Vijayawada (Krishna Region)')),
                              DropdownMenuItem(value: 'All', child: Text('All Cities (Cross-Region Alert)')),
                            ],
                            onChanged: (city) {
                              setState(() => _selectedTargetCity = city ?? 'Rajahmundry');
                              _updateAudiencePreview();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedGroupFilter,
                            decoration: InputDecoration(
                              labelText: 'Blood Group Target',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            items: const [
                              DropdownMenuItem(value: 'All', child: Text('All Groups (Compatible)')),
                              DropdownMenuItem(value: 'O+', child: Text('O+ Only')),
                              DropdownMenuItem(value: 'O-', child: Text('O- Universal Red')),
                              DropdownMenuItem(value: 'A+', child: Text('A+ Only')),
                              DropdownMenuItem(value: 'B+', child: Text('B+ Only')),
                              DropdownMenuItem(value: 'AB+', child: Text('AB+ Universal Plasma')),
                            ],
                            onChanged: (v) {
                              setState(() => _selectedGroupFilter = v ?? 'All');
                              _updateAudiencePreview();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedChannel,
                            decoration: InputDecoration(
                              labelText: 'Outbound Channel',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            items: const [
                              DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp Cloud API')),
                              DropdownMenuItem(value: 'sms', child: Text('SMS Failover')),
                            ],
                            onChanged: (ch) {
                              setState(() => _selectedChannel = ch ?? 'whatsapp');
                              _updateAudiencePreview();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Geofence Radius: ', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Wrap(
                          spacing: 6,
                          children: [3.0, 5.0, 10.0, 15.0, 25.0, 50.0].map((r) {
                            final isSel = _broadcastRadiusKm == r;
                            return ChoiceChip(
                              label: Text('${r.toInt()} km', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                              selected: isSel,
                              selectedColor: DuoColors.redTint,
                              onSelected: (_) {
                                setState(() => _broadcastRadiusKm = r);
                                _updateAudiencePreview();
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Respect Donor Max Travel Radius', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('Excludes donors whose profile travel preference is smaller than the distance to camp', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: DuoColors.textSecondary)),
                            ],
                          ),
                        ),
                        Switch(
                          value: _respectDonorTravelRadius,
                          activeThumbColor: DuoColors.green,
                          onChanged: (v) {
                            setState(() => _respectDonorTravelRadius = v);
                            _updateAudiencePreview();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Live Audience & Spend Telemetry Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF0FDF4), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('$eligibleCount Donors in Radius', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 18, fontWeight: FontWeight.bold, color: DuoColors.green)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(6)),
                              child: Text('$suppressedCount out-of-region excluded', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, fontWeight: FontWeight.bold, color: DuoColors.red)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Estimated Outreach Cost: ₹${costEstimate.toStringAsFixed(2)} INR (${_selectedChannel == 'sms' ? 'SMS rate' : 'WhatsApp template rate'})',
                          style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary),
                        ),
                        if (requiresApproval) ...[
                          const SizedBox(height: 4),
                          const Text('⚠️ >200 Donors: Four-Eyes Maker-Checker approval required before dispatch.', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, fontWeight: FontWeight.bold, color: DuoColors.red)),
                        ],
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showAudienceInspectionModal(context),
                      icon: const Icon(Icons.people_outline_rounded, size: 16, color: DuoColors.textPrimary),
                      label: const Text('Inspect Audience', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.bold, color: DuoColors.textPrimary)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Template Pills Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTemplateChip(
                      label: '🏕️ Blood Camp Invitation',
                      isSelected: _selectedBroadcastType == 'camp_invitation',
                      onTap: () {
                        setState(() {
                          _selectedBroadcastType = 'camp_invitation';
                          _broadcastTitleController.text = 'Mega Voluntary Blood Camp at Rotary Diamond Hall';
                          _broadcastMsgController.text = 'Dear Hero, a voluntary blood camp is organized this Sunday 9 AM at Rotary Diamond Hall, Main Road. Would you like to attend and donate? Reply YES to confirm.';
                        });
                        _updateAudiencePreview();
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildTemplateChip(
                      label: '🚨 Critical Shortage Alert',
                      isSelected: _selectedBroadcastType == 'shortage_alert',
                      onTap: () {
                        setState(() {
                          _selectedBroadcastType = 'shortage_alert';
                          _broadcastTitleController.text = 'CRITICAL ALERT: Emergency Blood Shortage in Rajahmundry';
                          _broadcastMsgController.text = 'URGENT: Government General Hospital (GGH) is facing an acute blood shortage. If you are eligible to donate today, please visit or reply to this message.';
                        });
                        _updateAudiencePreview();
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildTemplateChip(
                      label: '❤️ Community Appreciation',
                      isSelected: _selectedBroadcastType == 'awareness_campaign',
                      onTap: () {
                        setState(() {
                          _selectedBroadcastType = 'awareness_campaign';
                          _broadcastTitleController.text = 'National Voluntary Blood Donation Day';
                          _broadcastMsgController.text = 'One Drop of Humanity, Give Blood, Save Lives. Thank you for standing as a registered lifesaver in Rajahmundry!';
                        });
                        _updateAudiencePreview();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Title & Message Body
              TextField(
                controller: _broadcastTitleController,
                decoration: InputDecoration(
                  labelText: 'Broadcast Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _broadcastMsgController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Message Body (English / Multi-lingual)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 13),
              ),
              const SizedBox(height: 14),

              // Trilingual Tab Bar for Telugu & Hindi preview
              Row(
                children: [
                  const Text('Preview Language: ', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('English (EN)'),
                    selected: _previewLanguage == 'en',
                    onSelected: (_) => setState(() => _previewLanguage = 'en'),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('తెలుగు (TE)'),
                    selected: _previewLanguage == 'te',
                    onSelected: (_) => setState(() => _previewLanguage = 'te'),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('हिंदी (HI)'),
                    selected: _previewLanguage == 'hi',
                    onSelected: (_) => setState(() => _previewLanguage = 'hi'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  _previewLanguage == 'te'
                      ? 'రక్తదాతకు నమస్కారం! రాజమండ్రి రోటరీ డైమండ్ హాల్‌లో రక్తదాన శిబిరం జరుగుతోంది. పాల్గొనడానికి YES అని రిప్లై ఇవ్వండి.'
                      : (_previewLanguage == 'hi'
                          ? 'रक्तदाता को नमस्कार! राजमुंदरी रोटरी डायमंड हॉल में रक्तदान शिविर आयोजित है। पुष्टि के लिए YES भेजें।'
                          : _broadcastMsgController.text),
                  style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textPrimary),
                ),
              ),
              const SizedBox(height: 20),

              DuoButton(
                label: _isBroadcasting ? 'TRANSMITTING GEO-BROADCAST...' : 'DISPATCH TO $eligibleCount LOCAL DONORS',
                icon: Icons.send_rounded,
                variant: DuoButtonVariant.primary,
                height: 46,
                onPressed: _isBroadcasting ? null : _dispatchBroadcast,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Recent Dispatches Table
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
                  const Text('Recent Broadcast Transmissions', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('${_broadcastHistory.length} Total', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 12),
              if (_broadcastHistory.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No previous broadcast logs', style: TextStyle(fontFamily: DuoTypography.fontFamily, color: DuoColors.textSecondary))))
              else
                ..._broadcastHistory.map((item) {
                  final channel = (item['channel'] ?? 'whatsapp').toString().toUpperCase();
                  final meta = item['payload_meta'] as Map<String, dynamic>? ?? {};
                  final title = meta['title']?.toString() ?? 'Regional Campaign';
                  final time = (item['created_at']?.toString() ?? '');
                  final displayTime = time.length >= 16 ? time.substring(0, 16) : 'Recent';

                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: DuoColors.greenTint, borderRadius: BorderRadius.circular(6)),
                      child: Text(channel, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.green, fontSize: 10)),
                    ),
                    title: Text(title, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(displayTime, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: DuoColors.textSecondary)),
                    trailing: const Icon(Icons.check_circle_rounded, color: DuoColors.green, size: 16),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? DuoColors.redTint : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: isSelected ? DuoColors.red : const Color(0xFFCBD5E1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: DuoTypography.fontFamily,
            color: isSelected ? DuoColors.red : DuoColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  void _showAudienceInspectionModal(BuildContext context) {
    final samples = _audiencePreview['sample_donors'] as List? ?? [];
    final suppressedList = _audiencePreview['suppressed_donors'] as List? ?? [];
    final eligible = _audiencePreview['eligible_count'] as int? ?? 0;
    final suppressed = _audiencePreview['suppressed_count'] as int? ?? 0;
    final areaBreakdown = _audiencePreview['area_breakdown'] as Map? ?? {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DefaultTabController(
        length: 3,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.72,
          padding: const EdgeInsets.all(20),
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

              // Tab Bar
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
                    // Tab 1: Eligible Donors
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

                    // Tab 2: Suppressed Donors with explicit exclusion reason
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

                    // Tab 3: Area Breakdown
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

  // --- SECTION 4: BLOOD CAMPS & DRIVES ---
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
                subtitle: Text('${c.venue} · ${c.area} · Capacity: ${c.capacity} donors', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: DuoColors.greenTint, borderRadius: BorderRadius.circular(999)),
                  child: const Text('PUBLISHED', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: DuoColors.green, fontSize: 10)),
                ),
              );
            }),
        ],
      ),
    );
  }

  // --- SECTION 5: BANKS & INVENTORY DESK ---
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
                DataColumn(label: Text('ADDRESS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('AVAILABLE UNITS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('HOURS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('TRUST SCORE', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('SUPERHERO ACTIONS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
              ],
              rows: _banksList.map((b) {
                return DataRow(
                  cells: [
                    DataCell(Text(b.name, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13))),
                    DataCell(Text(b.address, style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary))),
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

  // --- SECTION 6: DONORS REGISTRY TABLE (Matching DevzeMart User Table) ---
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
          // Filter Tabs & Search Header
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
                SizedBox(
                  width: 240,
                  height: 38,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search donor...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 16),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12),
                  ),
                ),
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
                DataColumn(label: Text('DONOR DETAILS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('BLOOD GROUP', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('TRUST LEVEL', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('DONATIONS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('ACTIONS', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
              ],
              rows: filtered.map((d) {
                final id = d['id']?.toString() ?? '';
                final name = d['full_name'] ?? d['first_name'] ?? 'Donor';
                final phone = d['phone']?.toString() ?? '';
                final bg = d['blood_group'] ?? 'O+';
                final state = (d['state'] ?? 'active').toString().toUpperCase();
                final trust = d['trust_level'] ?? 1;
                final donations = d['donations_count'] ?? 0;

                return DataRow(
                  cells: [
                    DataCell(Text('#${id.substring(0, 4)}', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: DuoColors.textSecondary))),
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
                    DataCell(Text('Level $trust', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12))),
                    DataCell(Text('$donations units', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12))),
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

  // --- SECTION 7: INBOUND & AI TELEMETRY ---
  Widget _buildInboundSection(BuildContext context) {
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
          const Text('Inbound Telemetry & AI Speech Assistant', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Realtime monitoring of AI voice intake and WhatsApp bot assistants', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
          const SizedBox(height: 24),

          Row(
            children: [
              const DuoMeter(value: 0.15, color: DuoColors.red, centerText: '9m', subText: 'used', size: 84),
              const SizedBox(width: 24),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Voice Minutes Today', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(height: 4),
                    Text('9 of 60 daily safety minutes utilized. Auto-fails over to keypad IVR when cap is reached.', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Inbound WhatsApp Assistant Bot', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text('Receives requester messages and auto-triages blood needs in Rajahmundry', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12)),
            value: true,
            activeThumbColor: DuoColors.green,
            onChanged: (val) => _showToast('WhatsApp assistant status updated'),
          ),
        ],
      ),
    );
  }

  // --- SECTION 8: PLATFORM SETTINGS & KILL SWITCH ---
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
          const Text('Platform Security & Operational Controls', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),

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

          ListTile(
            leading: const Icon(Icons.location_city_rounded, color: DuoColors.red),
            title: const Text('Active Pilot Operational Zone', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text('Rajahmundry, Andhra Pradesh (533101 - 533107)', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12)),
          ),
          ListTile(
            leading: const Icon(Icons.support_agent_rounded, color: DuoColors.green),
            title: const Text('24x7 Emergency Helpline Number', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text('+91 883 247 1234', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // --- SECTION 9: AUDIT LOGS ---
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
}
