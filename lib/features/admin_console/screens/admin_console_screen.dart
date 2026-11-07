// ============================================================================
// BloodNorms | admin_console_screen.dart
// BloodNorms Admin Console — Duolingo Feather Style
// Desktop & Mobile adaptive 3D paper cards, mascot guidance, tactile controls
// Sections: Live, Needs Human, Donors, Banks, Inbound, Settings (Kill Switch), Audit
// Strict Rules: Arial font only, FontWeight.normal & FontWeight.bold only.
// Primary color: Cardinal Red everywhere. Universal Green strictly for done/success.
// ============================================================================

import 'package:flutter/material.dart';
import '../../../core/theme/duo_colors.dart';
import '../../../core/theme/duo_typography.dart';
import '../../../core/widgets/duo_button.dart';
import '../../../core/widgets/duo_header_bar.dart';
import '../../../core/widgets/duo_meter.dart';
import '../../../core/widgets/duo_text_field.dart';

class AdminConsoleScreen extends StatefulWidget {
  const AdminConsoleScreen({super.key});

  @override
  State<AdminConsoleScreen> createState() => _AdminConsoleScreenState();
}

class _AdminConsoleScreenState extends State<AdminConsoleScreen> {
  int _selectedSection = 0;
  bool _killSwitchActive = false;

  // Live state
  int _activeWave = 2;
  double _activeRadiusKm = 3.0;
  bool _compatibleAllowed = false;
  bool _isRequestClosed = false;
  final TextEditingController _donorSearchController = TextEditingController();

  final List<Map<String, dynamic>> _sections = [
    {'title': 'Live', 'icon': Icons.radar_rounded},
    {'title': 'Needs Human', 'icon': Icons.warning_rounded},
    {'title': 'Donors', 'icon': Icons.people_rounded},
    {'title': 'Banks', 'icon': Icons.local_hospital_rounded},
    {'title': 'Inbound', 'icon': Icons.mic_rounded},
    {'title': 'Settings', 'icon': Icons.settings_rounded},
    {'title': 'Audit Log', 'icon': Icons.description_rounded},
  ];

  @override
  void dispose() {
    _donorSearchController.dispose();
    super.dispose();
  }

  void _toggleKillSwitch(bool value) {
    if (value) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: DuoColors.red, width: 2.0),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DuoColors.redTint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: DuoColors.redShadow, width: 1.5),
                ),
                child: const Icon(Icons.power_settings_new_rounded, color: DuoColors.red, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'ACTIVATE KILL SWITCH?',
                style: DuoTypography.title3(color: DuoColors.red),
              ),
            ],
          ),
          content: Text(
            'This will IMMEDIATELY block all new blood requests and halt all outbound WhatsApp messages and voice calls across the entire platform. Public blood bank directory will remain read-only.',
            style: DuoTypography.body(color: DuoColors.textSecondary),
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
                    onPressed: () {
                      setState(() => _killSwitchActive = true);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      setState(() => _killSwitchActive = false);
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

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: DuoHeaderBar(
        title: 'BloodNorms Admin',
        showBackButton: true,
        trailing: [
          if (_killSwitchActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: DuoColors.red,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: DuoColors.redShadow,
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Text(
                'KILL SWITCH ACTIVE',
                style: TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: isDesktop
            ? Row(
                children: [
                  // Desktop Sidebar with 3D Tactile Buttons
                  Container(
                    width: 250,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        right: BorderSide(
                          color: DuoColors.border,
                          width: 2.0,
                        ),
                      ),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      children: List.generate(_sections.length, (index) {
                        final s = _sections[index];
                        final isSelected = _selectedSection == index;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? DuoColors.redTint : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? DuoColors.redShadow : DuoColors.border,
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected ? DuoColors.redShadow : DuoColors.border,
                                offset: const Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => setState(() => _selectedSection = index),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      s['icon'] as IconData,
                                      size: 20,
                                      color: isSelected ? DuoColors.red : DuoColors.textSecondary,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      s['title'] as String,
                                      style: TextStyle(
                                        fontFamily: DuoTypography.fontFamily,
                                        color: isSelected ? DuoColors.red : DuoColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  // Content Pane
                  Expanded(
                    child: _buildSectionContent(context, _selectedSection),
                  ),
                ],
              )
            : Column(
                children: [
                  // Horizontal tab bar for mobile
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: List.generate(_sections.length, (index) {
                        final s = _sections[index];
                        final isSelected = _selectedSection == index;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedSection = index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? DuoColors.redTint : Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: isSelected ? DuoColors.redShadow : DuoColors.border,
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected ? DuoColors.redShadow : DuoColors.border,
                                    offset: const Offset(0, 3),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    s['icon'] as IconData,
                                    size: 16,
                                    color: isSelected ? DuoColors.red : DuoColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    s['title'] as String,
                                    style: TextStyle(
                                      fontFamily: DuoTypography.fontFamily,
                                      color: isSelected ? DuoColors.red : DuoColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Expanded(
                    child: _buildSectionContent(context, _selectedSection),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionContent(BuildContext context, int sectionIndex) {
    switch (sectionIndex) {
      case 0:
        return _buildLiveSection(context);
      case 1:
        return _buildNeedsHumanSection(context);
      case 2:
        return _buildDonorsSection(context);
      case 3:
        return _buildBanksSection(context);
      case 4:
        return _buildInboundSection(context);
      case 5:
        return _buildSettingsSection(context);
      case 6:
      default:
        return _buildAuditSection(context);
    }
  }

  // --- SECTION 1: LIVE REQUESTS ---
  Widget _buildLiveSection(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Mascot Speech Bubble
        const DuoSpeechBubble(
          emoji: '🚨',
          text: 'Emergency requests currently searching donors. You can widen waves or enable compatible groups.',
        ),
        const SizedBox(height: 20),

        Text('Live Emergency Requests', style: DuoTypography.title1(color: DuoColors.textPrimary)),
        const SizedBox(height: 16),

        if (!_isRequestClosed)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: DuoColors.border, width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: DuoColors.border,
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
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
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: DuoColors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('GGH Rajahmundry · O Positive', style: DuoTypography.headline(color: DuoColors.textPrimary)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: DuoColors.redTint,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: DuoColors.redShadow, width: 1.0),
                      ),
                      child: Text(
                        'WAVE $_activeWave · ${_activeRadiusKm.toStringAsFixed(0)} KM',
                        style: const TextStyle(
                          fontFamily: DuoTypography.fontFamily,
                          color: DuoColors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Gamified Metric Badges in Red Brand Theme
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStatBadge('Needed', '2 Units', DuoColors.red, DuoColors.redTint, DuoColors.redShadow),
                    _buildStatBadge('Contacted', '${_activeWave * 6} Donors', DuoColors.textPrimary, const Color(0xFFF7F7F7), DuoColors.border),
                    _buildStatBadge('Accepted', '1 Donor', DuoColors.green, DuoColors.greenTint, DuoColors.greenShadow),
                    if (_compatibleAllowed)
                      _buildStatBadge('Rule', 'Universal On', DuoColors.red, DuoColors.redTint, DuoColors.redShadow),
                  ],
                ),
                const SizedBox(height: 20),

                // 3D Pushable Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    DuoButton(
                      label: 'WIDEN',
                      height: 40,
                      variant: DuoButtonVariant.secondary,
                      onPressed: () {
                        setState(() {
                          _activeWave++;
                          _activeRadiusKm += 2.0;
                        });
                        _showToast('Expanded to Wave $_activeWave (${_activeRadiusKm.toStringAsFixed(0)} km)');
                      },
                    ),
                    const SizedBox(width: 8),
                    DuoButton(
                      label: _compatibleAllowed ? 'EXACT ONLY' : 'COMPATIBLE',
                      height: 40,
                      variant: DuoButtonVariant.secondary,
                      onPressed: () {
                        setState(() => _compatibleAllowed = !_compatibleAllowed);
                        _showToast(_compatibleAllowed ? 'Universal compatible enabled' : 'Exact group only');
                      },
                    ),
                    const SizedBox(width: 8),
                    DuoButton(
                      label: 'CLOSE',
                      height: 40,
                      variant: DuoButtonVariant.destructive,
                      onPressed: () {
                        setState(() => _isRequestClosed = true);
                        _showToast('Request closed');
                      },
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: DuoColors.border, width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: DuoColors.border,
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 48, color: DuoColors.green),
                  const SizedBox(height: 12),
                  Text('All emergency requests fulfilled!', style: DuoTypography.headline(color: DuoColors.textPrimary)),
                  const SizedBox(height: 14),
                  DuoButton(
                    label: 'RESET SIMULATION',
                    icon: Icons.refresh_rounded,
                    height: 40,
                    variant: DuoButtonVariant.secondary,
                    onPressed: () => setState(() => _isRequestClosed = false),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // --- SECTION 2: NEEDS HUMAN ---
  Widget _buildNeedsHumanSection(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Mascot Speech Bubble
        const DuoSpeechBubble(
          emoji: '⚠️',
          text: 'These callers require human volunteer attention due to phone verification or exhausted rings.',
        ),
        const SizedBox(height: 20),

        Text('Needs Human Attention Queue', style: DuoTypography.title1(color: DuoColors.textPrimary)),
        const SizedBox(height: 8),
        Text('Exhausted rings, phone confirmation fallbacks, abuse reports', style: DuoTypography.subhead(color: DuoColors.textSecondary)),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: DuoColors.redShadow, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: DuoColors.border,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Caller Without WhatsApp', style: DuoTypography.headline(color: DuoColors.textPrimary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: DuoColors.redTint,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: DuoColors.redShadow, width: 1.0),
                    ),
                    child: const Text(
                      'ACTION REQUIRED',
                      style: TextStyle(
                        fontFamily: DuoTypography.fontFamily,
                        color: DuoColors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Caller from +91 98481 99999 gave blood requirements by voice but has no WhatsApp. Human volunteer call required.',
                style: DuoTypography.body(color: DuoColors.textSecondary),
              ),
              const SizedBox(height: 16),
              DuoButton(
                label: 'CALL REQUESTER',
                icon: Icons.phone_rounded,
                height: 44,
                variant: DuoButtonVariant.primary,
                onPressed: () => _showToast('Calling +91 98481 99999...'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- SECTION 3: DONORS ---
  Widget _buildDonorsSection(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Donors Management', style: DuoTypography.title1(color: DuoColors.textPrimary)),
        const SizedBox(height: 16),
        DuoTextField(
          controller: _donorSearchController,
          label: 'Search Donors',
          hintText: 'Search by name, blood group, city...',
          prefixIcon: Icons.search_rounded,
          onChanged: (val) {
            setState(() {});
          },
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: DuoColors.border, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: DuoColors.border,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ramesh Varma', style: DuoTypography.headline(color: DuoColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('O+ · Rajahmundry · Proven (2 donations)', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: DuoColors.greenTint,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: DuoColors.greenShadow, width: 1.0),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    fontFamily: DuoTypography.fontFamily,
                    color: DuoColors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- SECTION 4: BANKS ---
  Widget _buildBanksSection(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text('Blood Banks Directory', style: DuoTypography.title1(color: DuoColors.textPrimary)),
            ),
            DuoButton(
              label: 'IMPORT CSV',
              icon: Icons.file_upload_rounded,
              height: 40,
              variant: DuoButtonVariant.secondary,
              onPressed: () => _showToast('CSV imported: 3 banks updated'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('3 Blood Banks active in pilot city (Rajahmundry)', style: DuoTypography.subhead(color: DuoColors.textSecondary)),
        const SizedBox(height: 16),
        _buildBankSummaryCard('Rotary Central Blood Bank', '85 (Reliable)', '22 units in stock'),
        const SizedBox(height: 12),
        _buildBankSummaryCard('Red Cross District Centre', '78 (OK)', '14 units in stock'),
        const SizedBox(height: 12),
        _buildBankSummaryCard('Government Hospital Blood Bank', '92 (Reliable)', '35 units in stock'),
      ],
    );
  }

  Widget _buildBankSummaryCard(String name, String trust, String stock) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DuoColors.border, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: DuoColors.border,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: DuoTypography.headline(color: DuoColors.textPrimary)),
              const SizedBox(height: 4),
              Text(stock, style: DuoTypography.caption(color: DuoColors.textSecondary)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: DuoColors.redTint,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: DuoColors.redShadow, width: 1.0),
            ),
            child: Text(
              trust,
              style: const TextStyle(
                fontFamily: DuoTypography.fontFamily,
                color: DuoColors.red,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SECTION 5: INBOUND ---
  Widget _buildInboundSection(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Inbound Channels & AI Voice', style: DuoTypography.title1(color: DuoColors.textPrimary)),
        const SizedBox(height: 20),
        // AI Minutes usage vs cap
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: DuoColors.border, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: DuoColors.border,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              const DuoMeter(value: 0.25, color: DuoColors.red, centerText: '15m', subText: 'used', size: 84),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Voice Minutes Today', style: DuoTypography.headline(color: DuoColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text('15 min of 60 min daily cap used', style: DuoTypography.body(color: DuoColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text('Falls back to Keypad IVR automatically when cap is reached', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- SECTION 6: SETTINGS (KILL SWITCH) ---
  Widget _buildSettingsSection(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Platform Settings', style: DuoTypography.title1(color: DuoColors.textPrimary)),
        const SizedBox(height: 24),
        // Big Red Kill Switch per BR-19
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _killSwitchActive ? DuoColors.redTint : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: DuoColors.redShadow, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: DuoColors.border,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
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
                        Icon(Icons.power_settings_new_rounded, color: DuoColors.red, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'PLATFORM KILL SWITCH',
                          style: TextStyle(
                            fontFamily: DuoTypography.fontFamily,
                            color: DuoColors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _killSwitchActive ? 'ACTIVE: Outbound alerts and intake are paused' : 'Normal operations running smoothly',
                      style: DuoTypography.caption(color: DuoColors.textSecondary),
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
      ],
    );
  }

  // --- SECTION 7: AUDIT LOG ---
  Widget _buildAuditSection(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Audit Log', style: DuoTypography.title1(color: DuoColors.textPrimary)),
        const SizedBox(height: 8),
        Text('Immutable, rate-limited trail of sensitive actions', style: DuoTypography.subhead(color: DuoColors.textSecondary)),
        const SizedBox(height: 16),
        _buildAuditItem('14:22 IST', 'reveal_donor_phone', 'Requester revealed donor phone (+91 98481...)'),
        _buildAuditItem('14:15 IST', 'bank_confirm_donation', 'Donation code 482910 confirmed at Rotary Bank'),
        _buildAuditItem('14:02 IST', 'create_request', 'O+ 1 Unit emergency request initiated'),
      ],
    );
  }

  Widget _buildAuditItem(String time, String action, String detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DuoColors.border, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: DuoColors.border,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              time,
              style: const TextStyle(
                fontFamily: DuoTypography.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: DuoColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            action,
            style: const TextStyle(
              fontFamily: DuoTypography.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: DuoColors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(detail, style: DuoTypography.caption(color: DuoColors.textPrimary))),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, String value, Color color, Color bg, Color shadow) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: shadow, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontFamily: DuoTypography.fontFamily,
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: DuoTypography.fontFamily,
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
