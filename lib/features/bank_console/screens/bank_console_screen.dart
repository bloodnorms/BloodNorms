// ============================================================================
// BloodNorms | bank_console_screen.dart
// Blood Bank Console — Duolingo Feather Red Style
// Tabs: Stock, Confirm (Keypad), Donors (Expected), Camps, More
// DuoBottomNavBar, 3D steppers, Material Icons, Arial normal/bold only
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/constants/blood_groups.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/blood_group_tile.dart';
import '../../../shared/widgets/app_nav_bar.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/pin_keypad.dart';
import '../../../shared/widgets/notification_bell.dart';
import '../../../shared/widgets/segmented_picker.dart';

class BankConsoleScreen extends StatefulWidget {
  const BankConsoleScreen({super.key});

  @override
  State<BankConsoleScreen> createState() => _BankConsoleScreenState();
}

class _BankConsoleScreenState extends State<BankConsoleScreen> {
  int _currentTab = 0;

  // Connected Banks
  List<Map<String, dynamic>> _banks = [];
  String _selectedBankId = 'b1000000-0000-0000-0000-000000000001';
  String _selectedBankName = 'GGH Blood Bank';

  // Stock State (8 groups x units)
  BloodComponentType _selectedComponent = BloodComponentType.wholeBlood;
  final Map<BloodGroup, int> _stock = {
    BloodGroup.aPositive: 0,
    BloodGroup.aNegative: 0,
    BloodGroup.bPositive: 0,
    BloodGroup.bNegative: 0,
    BloodGroup.abPositive: 0,
    BloodGroup.abNegative: 0,
    BloodGroup.oPositive: 0,
    BloodGroup.oNegative: 0,
  };
  bool _isSavingStock = false;

  // Confirm State
  String _enteredCode = '';
  bool _isConfirming = false;

  // Expected Donors & Camps from Supabase
  List<Map<String, dynamic>> _expectedDonors = [];
  List<CampModel> _bankCamps = [];
  bool _isLoadingExpected = false;
  bool _isLoadingCamps = false;

  @override
  void initState() {
    super.initState();
    _loadBanks();
    _loadExpectedDonors();
    _loadBankCamps();
  }

  Future<void> _loadBanks() async {
    final banks = await SupabaseService().getBanks();
    if (mounted && banks.isNotEmpty) {
      setState(() {
        _banks = banks;
        _selectedBankId = banks.first['id']?.toString() ?? _selectedBankId;
        _selectedBankName = banks.first['name']?.toString() ?? _selectedBankName;
      });
      _loadLiveStock();
    } else {
      _loadLiveStock();
    }
  }

  void _showBankSelector() {
    if (_banks.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Blood Bank', style: DuoTypography.title2(color: DuoColors.textPrimary)),
            const SizedBox(height: 12),
            ..._banks.map((b) {
              final id = b['id']?.toString() ?? '';
              final name = b['name']?.toString() ?? 'Blood Bank';
              final isSel = id == _selectedBankId;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isSel ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: isSel ? DuoColors.red : DuoColors.textSecondary,
                ),
                title: Text(
                  name,
                  style: TextStyle(
                    fontFamily: DuoTypography.fontFamily,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    color: DuoColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _selectedBankId = id;
                    _selectedBankName = name;
                  });
                  _loadLiveStock();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _loadExpectedDonors() async {
    setState(() => _isLoadingExpected = true);
    final donors = await SupabaseService().getExpectedDonors();
    if (mounted) {
      setState(() {
        _expectedDonors = donors;
        _isLoadingExpected = false;
      });
    }
  }

  Future<void> _loadBankCamps() async {
    setState(() => _isLoadingCamps = true);
    final camps = await SupabaseService().getCamps();
    if (mounted) {
      setState(() {
        _bankCamps = camps;
        _isLoadingCamps = false;
      });
    }
  }

  Future<void> _loadLiveStock() async {
    final liveStock = await SupabaseService().getBankStock(
      bankId: _selectedBankId,
      component: _selectedComponent.code,
    );
    if (mounted && liveStock.isNotEmpty) {
      setState(() {
        for (var entry in liveStock.entries) {
          final group = BloodGroup.fromString(entry.key);
          if (group != null) {
            _stock[group] = entry.value;
          }
        }
      });
    }
  }

  // 1. Save Stock
  Future<void> _saveStock() async {
    setState(() => _isSavingStock = true);
    final rows = _stock.entries.map((e) {
      return {
        'blood_group': e.key.label,
        'group': e.key.label,
        'component': _selectedComponent.code,
        'units': e.value,
      };
    }).toList();

    await SupabaseService().setBankStock(rows, bankId: _selectedBankId);
    setState(() => _isSavingStock = false);

    if (mounted) {
      _showToast(context, 'Blood bank stock updated successfully in Supabase!');
    }
  }

  // 2. Refresh "All unchanged"
  Future<void> _refreshUnchanged() async {
    await _saveStock();
  }

  // 3. Confirm 6-digit donation code
  Future<void> _submitConfirmCode() async {
    if (_enteredCode.length != 6) return;
    setState(() => _isConfirming = true);

    final res = await SupabaseService().confirmBankDonation(code: _enteredCode);
    setState(() {
      _isConfirming = false;
      _enteredCode = '';
    });

    if (mounted) {
      if (res['ok'] == true) {
        _showSuccessDialog(
          res['first_name']?.toString() ?? 'Donor',
          res['blood_group']?.toString() ?? 'Blood',
        );
        _loadExpectedDonors();
        _loadLiveStock();
      } else {
        _showToast(context, res['error']?.toString() ?? 'Invalid or expired pass code');
      }
    }
  }

  void _showSuccessDialog(String name, String group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: DuoColors.border, width: 2.0),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DuoColors.greenTint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DuoColors.greenShadow, width: 1.5),
              ),
              child: const Icon(Icons.check_circle_rounded, color: DuoColors.green, size: 24),
            ),
            const SizedBox(width: 12),
            Text('Donation Verified!', style: DuoTypography.title3(color: DuoColors.textPrimary)),
          ],
        ),
        content: Text(
          'Successfully confirmed donation for $name ($group). Blood stock and donor history updated.',
          style: DuoTypography.body(color: DuoColors.textSecondary),
        ),
        actions: [
          DuoButton(
            label: 'DONE',
            height: 44,
            variant: DuoButtonVariant.success,
            onPressed: () {
              Navigator.pop(ctx);
              _loadLiveStock();
            },
          ),
        ],
      ),
    );
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: DuoColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildStockTab(context),
          _buildConfirmTab(context),
          _buildExpectedDonorsTab(context),
          _buildCampsTab(context),
          _buildMoreTab(context),
        ],
      ),
      bottomNavigationBar: DuoBottomNavBar(
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
        items: const [
          DuoNavItem(
            icon: Icons.water_drop_rounded,
            label: 'Stock',
          ),
          DuoNavItem(
            icon: Icons.check_circle_rounded,
            label: 'Confirm',
          ),
          DuoNavItem(
            icon: Icons.people_rounded,
            label: 'Expected',
          ),
          DuoNavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Camps',
          ),
          DuoNavItem(
            icon: Icons.more_horiz_rounded,
            label: 'More',
          ),
        ],
      ),
    );
  }

  // --- TAB 1: STOCK ---
  Widget _buildStockTab(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: DuoHeaderBar(
        title: 'Stock Management',
        showBackButton: true,
        trailing: [
          GestureDetector(
            onTap: _refreshUnchanged,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: DuoColors.redTint,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: DuoColors.redShadow, width: 1.5),
              ),
              child: const Text(
                'ALL SAME',
                style: TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  color: DuoColors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const DuoNotificationBell(role: 'bank_staff'),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Mascot Speech Bubble
                  const DuoSpeechBubble(
                    emoji: '🩸',
                    text: 'Keep units accurate! When blood bank stock is truthful, families don\'t waste hours on the road.',
                  ),
                  const SizedBox(height: 16),

                  // Bank Title Card with switcher
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: InkWell(
                          onTap: _showBankSelector,
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  _selectedBankName,
                                  style: DuoTypography.title2(color: DuoColors.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down_rounded, color: DuoColors.red, size: 24),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: DuoColors.greenTint,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: DuoColors.greenShadow, width: 1.0),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, size: 14, color: DuoColors.green),
                            SizedBox(width: 4),
                            Text(
                              'Updated 25m ago',
                              style: TextStyle(
                                fontFamily: DuoTypography.fontFamily,
                                color: DuoColors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Component Segmented Control
                  DuoSegmentControl<BloodComponentType>(
                    items: const [
                      SegmentItem(value: BloodComponentType.wholeBlood, label: 'Whole'),
                      SegmentItem(value: BloodComponentType.redCells, label: 'Red cells'),
                      SegmentItem(value: BloodComponentType.platelets, label: 'Platelets'),
                      SegmentItem(value: BloodComponentType.plasma, label: 'Plasma'),
                    ],
                    selectedValue: _selectedComponent,
                    activeColor: DuoColors.red,
                    activeShadowColor: DuoColors.redShadow,
                    onValueChanged: (val) {
                      setState(() => _selectedComponent = val);
                      _loadLiveStock();
                    },
                  ),
                  const SizedBox(height: 20),

                  // Grid of 8 Blood Groups with 3D Tactile Steppers
                  ...BloodGroup.values.map((group) {
                    final currentUnits = _stock[group] ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          Row(
                            children: [
                              DuoBloodTile(
                                bloodGroup: group,
                                isSelected: false,
                                size: 52,
                                onTap: () {},
                              ),
                              const SizedBox(width: 14),
                              Text(group.label, style: DuoTypography.title3(color: DuoColors.textPrimary)),
                            ],
                          ),
                          Row(
                            children: [
                              _buildStepButton(
                                icon: Icons.remove_rounded,
                                isEnabled: currentUnits > 0,
                                onPressed: currentUnits > 0
                                    ? () => setState(() => _stock[group] = currentUnits - 1)
                                    : null,
                              ),
                              SizedBox(
                                width: 44,
                                child: Center(
                                  child: Text(
                                    '$currentUnits',
                                    style: TextStyle(
                                      fontFamily: DuoTypography.fontFamily,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: DuoColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              _buildStepButton(
                                icon: Icons.add_rounded,
                                isEnabled: true,
                                onPressed: () => setState(() => _stock[group] = currentUnits + 1),
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
            // Sticky Save Stock Button in 3D White Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: DuoColors.border, width: 2.0)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: DuoButton(
                  label: 'SAVE STOCK',
                  variant: DuoButtonVariant.success,
                  isLoading: _isSavingStock,
                  onPressed: _saveStock,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isEnabled ? DuoColors.redTint : const Color(0xFFF0F0F0),
          shape: BoxShape.circle,
          border: Border.all(
            color: isEnabled ? DuoColors.redShadow : DuoColors.border,
            width: 2.0,
          ),
          boxShadow: isEnabled
              ? const [
                  BoxShadow(
                    color: DuoColors.border,
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Icon(
            icon,
            size: 20,
            color: isEnabled ? DuoColors.red : DuoColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // --- TAB 2: CONFIRM DONATION (Keypad) ---
  Widget _buildConfirmTab(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: const DuoHeaderBar(
        title: 'Confirm Donation',
        showBackButton: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Mascot Speech Bubble
              const DuoSpeechBubble(
                emoji: '🎯',
                text: 'Ask the donor for the 6-digit confirmation code shown on their BloodNorms ticket!',
              ),
              const SizedBox(height: 20),

              Text('Enter 6-Digit Code', style: DuoTypography.title1(color: DuoColors.textPrimary)),
              const SizedBox(height: 6),
              Text(
                'Told by donor upon arrival at blood bank',
                style: DuoTypography.subhead(color: DuoColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Duolingo 6-digit Boxes
              DuoCodeDisplayDots(code: _enteredCode),
              const SizedBox(height: 24),

              if (_isConfirming)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(color: DuoColors.red),
                ),

              // Duolingo 3D Tactile Keypad
              DuoKeypad(
                onDigitPressed: (digit) {
                  if (_enteredCode.length < 6) {
                    setState(() => _enteredCode += digit);
                    if (_enteredCode.length == 6) {
                      _submitConfirmCode();
                    }
                  }
                },
                onDeletePressed: () {
                  if (_enteredCode.isNotEmpty) {
                    setState(() => _enteredCode = _enteredCode.substring(0, _enteredCode.length - 1));
                  }
                },
              ),
              const SizedBox(height: 20),

              // "Not Donated" Action button (Medical deferral / Did not come)
              DuoButton(
                label: 'NOT DONATED / DEFERRED',
                variant: DuoButtonVariant.plain,
                height: 40,
                onPressed: () => _showNotDonatedModal(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotDonatedModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reason for Not Donating', style: DuoTypography.title2(color: DuoColors.textPrimary)),
            const SizedBox(height: 8),
            Text('The request search will reopen for other donors.', style: DuoTypography.body(color: DuoColors.textSecondary)),
            const SizedBox(height: 20),
            DuoButton(
              label: 'Medical Deferral (Doctor decision)',
              variant: DuoButtonVariant.secondary,
              height: 48,
              onPressed: () {
                Navigator.pop(ctx);
                _showToast(context, 'Recorded: Medical deferral');
              },
            ),
            const SizedBox(height: 10),
            DuoButton(
              label: 'Did Not Come / Cancelled',
              variant: DuoButtonVariant.secondary,
              height: 48,
              onPressed: () {
                Navigator.pop(ctx);
                _showToast(context, 'Recorded: Donor did not arrive');
              },
            ),
            const SizedBox(height: 10),
            DuoButton(
              label: 'CANCEL',
              variant: DuoButtonVariant.plain,
              height: 44,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 3: EXPECTED DONORS ---
  Widget _buildExpectedDonorsTab(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: DuoHeaderBar(
        title: 'Expected Donors',
        showBackButton: false,
        trailing: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: DuoColors.red),
            onPressed: _loadExpectedDonors,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoadingExpected
            ? const Center(child: CircularProgressIndicator(color: DuoColors.red))
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Mascot Speech Bubble
                  const DuoSpeechBubble(
                    emoji: '👥',
                    text: 'Donors heading to requests in Rajahmundry. Keep beds prepared and welcome them with warmth!',
                  ),
                  const SizedBox(height: 20),

                  // Privacy rule reminder (BR-24)
                  Container(
                    padding: const EdgeInsets.all(16),
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
                        const Icon(Icons.shield_rounded, size: 20, color: DuoColors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Per privacy rule BR-24, bank staff see first name, blood group, and ETA only.',
                            style: TextStyle(
                              fontFamily: DuoTypography.fontFamily,
                              fontSize: 13,
                              color: DuoColors.textSecondary,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_expectedDonors.isNotEmpty)
                    ..._expectedDonors.map((row) {
                      final donor = row['donors'] as Map<String, dynamic>? ?? {};
                      final name = donor['first_name']?.toString() ?? donor['full_name']?.toString() ?? 'Donor';
                      final group = donor['blood_group']?.toString() ?? 'O+';
                      final status = (row['status']?.toString() ?? 'accepted').toUpperCase();
                      final distKm = (row['ring_km'] as num?)?.toDouble() ?? 1.5;
                      final eta = '~${(distKm * 8).toInt().clamp(10, 45)} min ETA';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildExpectedDonorItem(
                          name,
                          group,
                          eta,
                          status,
                          status == 'ACCEPTED' ? DuoColors.red : DuoColors.green,
                          status == 'ACCEPTED' ? DuoColors.redTint : DuoColors.greenTint,
                          status == 'ACCEPTED' ? DuoColors.redShadow : DuoColors.greenShadow,
                        ),
                      );
                    })
                  else ...[
                    _buildExpectedDonorItem('Anil', 'B+', '~12 min ETA', 'ON THE WAY', DuoColors.green, DuoColors.greenTint, DuoColors.greenShadow),
                    const SizedBox(height: 12),
                    _buildExpectedDonorItem('Suresh', 'B+', '~25 min ETA', 'ACCEPTED', DuoColors.red, DuoColors.redTint, DuoColors.redShadow),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildExpectedDonorItem(
    String name,
    String group,
    String eta,
    String status,
    Color statusColor,
    Color statusBg,
    Color statusBorder,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: DuoColors.redTint,
                  shape: BoxShape.circle,
                  border: Border.all(color: DuoColors.redShadow, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0] : 'D',
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      color: DuoColors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: DuoTypography.headline(color: DuoColors.textPrimary)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: DuoColors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          group,
                          style: const TextStyle(
                            fontFamily: DuoTypography.fontFamily,
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(eta, style: DuoTypography.caption(color: DuoColors.textSecondary)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: statusBorder, width: 1.5),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontFamily: DuoTypography.fontFamily,
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const DuoNotificationBell(role: 'bank_staff'),
        ],
      ),
    );
  }

  // --- TAB 4: CAMPS (Live Supabase Drives) ---
  Widget _buildCampsTab(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: DuoHeaderBar(
        title: 'Camp Management',
        showBackButton: false,
        trailing: [
          IconButton(
            onPressed: () => _showCreateCampModal(context),
            icon: const Icon(Icons.add_circle_rounded, size: 28, color: DuoColors.red),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoadingCamps
            ? const Center(child: CircularProgressIndicator(color: DuoColors.red))
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  const DuoSpeechBubble(
                    emoji: '⛺',
                    text: 'Blood donation drives bring communities together. Organize camps and track donor RSVPs in Supabase!',
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Active Camps in Supabase', style: DuoTypography.title2(color: DuoColors.textPrimary)),
                          Text('${_bankCamps.length} Drives Scheduled Across Regions', style: DuoTypography.caption(color: DuoColors.red)),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _showScheduleCampDialog(context),
                        icon: const Icon(Icons.add_rounded, size: 16, color: DuoColors.red),
                        label: const Text('Schedule Drive', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.bold, color: DuoColors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: DuoColors.red, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ..._bankCamps.map((camp) {
                    final dateStr = '${camp.startsAt.day} ${_monthName(camp.startsAt.month)} ${camp.startsAt.year}';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  camp.title,
                                  style: DuoTypography.headline(color: DuoColors.textPrimary),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: DuoColors.redTint,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: DuoColors.redShadow, width: 1.0),
                                ),
                                child: Text(
                                  camp.status.toUpperCase(),
                                  style: const TextStyle(
                                    fontFamily: DuoTypography.fontFamily,
                                    color: DuoColors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: DuoColors.red),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text('${camp.venue}, ${camp.area} (${camp.city})', style: DuoTypography.body(color: DuoColors.textSecondary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text('$dateStr · Target: ${camp.capacity} units', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: DuoColors.bgGrouped, borderRadius: BorderRadius.circular(4)),
                                child: Text('Radius: ${camp.targetRadiusKm.toInt()} km', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 10, color: DuoColors.textSecondary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Live Camp Metrics (Checked-In & Units Collected)
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: camp.attendeesCheckedIn > 0 ? DuoColors.greenTint : DuoColors.bgGrouped,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: camp.attendeesCheckedIn > 0 ? DuoColors.greenShadow : DuoColors.border,
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.how_to_reg_rounded,
                                      size: 14,
                                      color: camp.attendeesCheckedIn > 0 ? DuoColors.green : DuoColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${camp.attendeesCheckedIn} Checked In',
                                      style: TextStyle(
                                        fontFamily: DuoTypography.fontFamily,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: camp.attendeesCheckedIn > 0 ? DuoColors.green : DuoColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: DuoColors.redTint,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: DuoColors.redShadow, width: 1.0),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.bloodtype_rounded, size: 14, color: DuoColors.red),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${camp.unitsCollected} Units',
                                      style: const TextStyle(
                                        fontFamily: DuoTypography.fontFamily,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: DuoColors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: DuoButton(
                                  label: 'CHECK-IN',
                                  icon: Icons.qr_code_scanner_rounded,
                                  variant: DuoButtonVariant.success,
                                  height: 40,
                                  onPressed: () => _showCampCheckInSheet(context, camp),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                flex: 3,
                                child: DuoButton(
                                  label: 'ROSTER',
                                  icon: Icons.people_outline_rounded,
                                  variant: DuoButtonVariant.secondary,
                                  height: 40,
                                  onPressed: () => _showCampRosterSheet(context, camp),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                flex: 3,
                                child: DuoButton(
                                  label: 'BROADCAST',
                                  icon: Icons.campaign_rounded,
                                  variant: DuoButtonVariant.primary,
                                  height: 40,
                                  onPressed: () => _showBankBroadcastSheet(context, camp),
                                ),
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
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }

  void _showCreateCampModal(BuildContext context) {
    final titleController = TextEditingController(text: 'Rotary Community Mega Blood Camp');
    final venueController = TextEditingController(text: 'Rotary Diamond Hall, Main Road');
    final areaController = TextEditingController(text: 'Innespeta, Rajahmundry');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            Text('Create Blood Drive Camp', style: DuoTypography.title2(color: DuoColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Saved directly to Supabase bank_camps table.', style: DuoTypography.body(color: DuoColors.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Camp Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: venueController,
              decoration: const InputDecoration(labelText: 'Venue / Hall Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: areaController,
              decoration: const InputDecoration(labelText: 'Area / Landmark'),
            ),
            const SizedBox(height: 20),
            DuoButton(
              label: 'CONFIRM & SAVE TO SUPABASE',
              variant: DuoButtonVariant.primary,
              onPressed: () async {
                Navigator.pop(ctx);
                final startsAt = DateTime.now().add(const Duration(days: 3));
                final endsAt = startsAt.add(const Duration(hours: 8));

                await SupabaseService().createCamp(
                  bankId: _selectedBankId,
                  title: titleController.text.trim(),
                  venue: venueController.text.trim(),
                  area: areaController.text.trim(),
                  startsAt: startsAt,
                  endsAt: endsAt,
                  capacity: 200,
                );
                if (mounted) {
                  _showToast(this.context, 'Blood drive camp created in Supabase!');
                  _loadBankCamps();
                }
              },
            ),
            const SizedBox(height: 10),
            DuoButton(
              label: 'CANCEL',
              variant: DuoButtonVariant.plain,
              height: 44,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  // --- SCHEDULE BLOOD CAMP DIALOG ---
  void _showScheduleCampDialog(BuildContext context) {
    final titleCtrl = TextEditingController(text: 'Community Voluntary Blood Drive');
    final venueCtrl = TextEditingController(text: 'Community Hall, Main Road');
    final areaCtrl = TextEditingController(text: 'Danavaipeta');
    String selectedCity = 'Rajahmundry';
    int capacity = 100;
    double radiusKm = 10.0;
    final cities = ['Rajahmundry', 'Kakinada', 'Visakhapatnam', 'Vijayawada', 'Guntur', 'Eluru'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: DuoColors.redTint, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.event_available_rounded, color: DuoColors.red, size: 22),
              ),
              const SizedBox(width: 10),
              Text('Schedule Blood Drive', style: DuoTypography.title2(color: DuoColors.textPrimary)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Drive Title', border: OutlineInputBorder()),
                  style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: venueCtrl,
                  decoration: const InputDecoration(labelText: 'Venue / Landmark', border: OutlineInputBorder()),
                  style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedCity,
                        decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                        items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setDialogState(() => selectedCity = v ?? 'Rajahmundry'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: areaCtrl,
                        decoration: const InputDecoration(labelText: 'Locality / Area', border: OutlineInputBorder()),
                        style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: capacity,
                        decoration: const InputDecoration(labelText: 'Target Capacity', border: OutlineInputBorder()),
                        items: [50, 100, 150, 200, 300, 500].map((c) => DropdownMenuItem(value: c, child: Text('$c Units'))).toList(),
                        onChanged: (v) => setDialogState(() => capacity = v ?? 100),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<double>(
                        initialValue: radiusKm,
                        decoration: const InputDecoration(labelText: 'Target Radius', border: OutlineInputBorder()),
                        items: [5.0, 10.0, 15.0, 25.0].map((r) => DropdownMenuItem(value: r, child: Text('${r.toInt()} KM'))).toList(),
                        onChanged: (v) => setDialogState(() => radiusKm = v ?? 10.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(fontFamily: DuoTypography.fontFamily, color: DuoColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final startsAt = DateTime.now().add(const Duration(days: 3, hours: 9));
                final endsAt = startsAt.add(const Duration(hours: 6));

                await SupabaseService().createCamp(
                  bankId: _selectedBankId,
                  title: titleCtrl.text.trim(),
                  venue: venueCtrl.text.trim(),
                  area: areaCtrl.text.trim(),
                  city: selectedCity,
                  startsAt: startsAt,
                  endsAt: endsAt,
                  capacity: capacity,
                  targetRadiusKm: radiusKm,
                );

                await _loadBankCamps();
                if (mounted && context.mounted) {
                  _showToast(context, 'Blood drive scheduled in $selectedCity!');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: DuoColors.red),
              child: const Text('SCHEDULE DRIVE', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // --- REGIONAL CAMP BROADCAST SHEET ---
  void _showBankBroadcastSheet(BuildContext context, CampModel camp) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => FutureBuilder<Map<String, dynamic>>(
        future: SupabaseService().previewBroadcastAudience(
          campId: camp.id,
          targetCity: camp.city,
          centerLat: camp.lat,
          centerLng: camp.lng,
          radiusKm: camp.targetRadiusKm,
          respectTravelCap: true,
        ),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(color: DuoColors.red)),
            );
          }

          final data = snapshot.data!;
          final eligible = data['eligible_count'] as int? ?? 0;
          final suppressed = data['suppressed_count'] as int? ?? 0;
          final cost = data['estimated_cost_inr'] ?? 0.0;
          final samples = data['sample_donors'] as List? ?? [];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: DuoColors.redTint, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.campaign_rounded, color: DuoColors.red, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Regional Broadcast Outreach', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 16, fontWeight: FontWeight.bold, color: DuoColors.textPrimary)),
                            Text('${camp.venue} (${camp.city})', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: DuoColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$eligible Donors in ${camp.targetRadiusKm.toInt()} km Radius', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 14, fontWeight: FontWeight.bold, color: DuoColors.green)),
                          const SizedBox(height: 2),
                          Text('Outreach spend: ₹$cost INR (WhatsApp template)', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: DuoColors.textSecondary)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(6)),
                        child: Text('$suppressed Out-of-Region Excluded', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 10, fontWeight: FontWeight.bold, color: DuoColors.red)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Nearby Matching Donors in City:', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.bold, color: DuoColors.textPrimary)),
                const SizedBox(height: 8),
                ...samples.take(4).map((d) {
                  final dMap = d as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: DuoColors.green, size: 14),
                        const SizedBox(width: 6),
                        Text(dMap['name']?.toString() ?? 'Donor', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        Text('(${dMap['blood_group']}) · ~${dMap['distance_km']} km away', style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: DuoColors.textSecondary)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 18),
                DuoButton(
                  label: 'DISPATCH REGIONAL BROADCAST',
                  icon: Icons.send_rounded,
                  variant: DuoButtonVariant.primary,
                  height: 44,
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final res = await SupabaseService().broadcastRegionalMessage(
                      title: 'Blood Drive at ${camp.venue}',
                      message: 'Dear Lifesaver, our blood bank is hosting a voluntary blood drive at ${camp.venue}, ${camp.area}. We welcome your support!',
                      broadcastType: 'camp_invitation',
                      campId: camp.id,
                      targetCity: camp.city,
                      centerLat: camp.lat,
                      centerLng: camp.lng,
                      radiusKm: camp.targetRadiusKm,
                      respectTravelCap: true,
                    );
                    if (context.mounted) {
                      _showToast(context, 'Broadcast dispatched to ${res["recipients"]} in-radius lifesavers!');
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- STAGE 4: CAMP CHECK-IN MODAL (KEYPAD & PHONE VERIFICATION) ---
  void _showCampCheckInSheet(BuildContext context, CampModel camp) {
    final phoneController = TextEditingController(text: '+91 98480 12345');
    int unitsDonated = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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
                  Text('Camp Donor Check-In', style: DuoTypography.title2(color: DuoColors.textPrimary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: DuoColors.greenTint,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: DuoColors.greenShadow, width: 1.0),
                    ),
                    child: const Text('LIVE DRIVE', style: TextStyle(color: DuoColors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(camp.title, style: DuoTypography.caption(color: DuoColors.textSecondary)),
              const SizedBox(height: 16),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Donor Mobile Number / Pass Code',
                  hintText: '+91 98480 12345',
                  prefixIcon: const Icon(Icons.phone_iphone_rounded, color: DuoColors.red),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Units Donated Stepper
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Units Collected:', style: DuoTypography.headline(color: DuoColors.textPrimary)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded, color: DuoColors.red),
                        onPressed: () {
                          if (unitsDonated > 1) {
                            setModalState(() => unitsDonated--);
                          }
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: DuoColors.redTint,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: DuoColors.redShadow, width: 1.0),
                        ),
                        child: Text(
                          '$unitsDonated Unit${unitsDonated > 1 ? "s" : ""}',
                          style: const TextStyle(
                            fontFamily: DuoTypography.fontFamily,
                            fontWeight: FontWeight.bold,
                            color: DuoColors.red,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded, color: DuoColors.red),
                        onPressed: () {
                          setModalState(() => unitsDonated++);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              DuoButton(
                label: 'VERIFY & CHECK-IN DONOR',
                icon: Icons.check_circle_rounded,
                variant: DuoButtonVariant.success,
                onPressed: () async {
                  Navigator.pop(ctx);
                  final phone = phoneController.text.trim();
                  final res = await SupabaseService().checkInCampAttendee(
                    campId: camp.id,
                    phone: phone,
                    units: unitsDonated,
                  );
                  if (mounted) {
                    final donorName = res['first_name'] ?? 'Donor';
                    final group = res['blood_group'] ?? 'Blood Group';
                    _showToast(this.context, 'Checked in $donorName ($group) · $unitsDonated units added!');
                    _loadBankCamps();
                  }
                },
              ),
              const SizedBox(height: 10),
              DuoButton(
                label: 'CANCEL',
                variant: DuoButtonVariant.plain,
                height: 44,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- STAGE 4: CAMP ROSTER / RSVP SHEET ---
  void _showCampRosterSheet(BuildContext context, CampModel camp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => FutureBuilder<List<Map<String, dynamic>>>(
        future: SupabaseService().getCampAttendees(camp.id),
        builder: (ctx, snapshot) {
          final attendees = snapshot.data ?? [];
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Camp Attendee Roster', style: DuoTypography.title2(color: DuoColors.textPrimary)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: DuoColors.redTint,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${attendees.length} Verified', style: const TextStyle(color: DuoColors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(camp.title, style: DuoTypography.caption(color: DuoColors.textSecondary)),
                const SizedBox(height: 16),

                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: DuoColors.red)))
                else if (attendees.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: DuoColors.bgGrouped,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: DuoColors.border, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        'No attendees checked in yet.\nTap "CHECK-IN" to verify arriving donors.',
                        textAlign: TextAlign.center,
                        style: DuoTypography.body(color: DuoColors.textSecondary),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 240,
                    child: ListView.separated(
                      itemCount: attendees.length,
                      separatorBuilder: (_, index) => const Divider(height: 1, color: DuoColors.border),
                      itemBuilder: (ctx, i) {
                        final att = attendees[i];
                        final donor = att['donors'] as Map<String, dynamic>?;
                        final name = donor?['first_name'] ?? att['phone'] ?? 'Donor #${i + 1}';
                        final group = donor?['blood_group'] ?? 'O+';
                        final units = att['units'] ?? 1;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: DuoColors.greenTint,
                            child: Icon(Icons.check_rounded, color: DuoColors.green),
                          ),
                          title: Text(name, style: DuoTypography.headline(color: DuoColors.textPrimary)),
                          subtitle: Text('$group · $units unit donated', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                          trailing: const Text('VERIFIED', style: TextStyle(color: DuoColors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 20),
                DuoButton(
                  label: 'DONE',
                  variant: DuoButtonVariant.primary,
                  height: 44,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- TAB 5: MORE ---
  Widget _buildMoreTab(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: const DuoHeaderBar(
        title: 'Bank Info & Team',
        showBackButton: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Text('Rotary Central Bank', style: DuoTypography.title1(color: DuoColors.textPrimary)),
            const SizedBox(height: 20),
            Container(
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
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: DuoColors.greenTint,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: DuoColors.greenShadow, width: 1.5),
                          ),
                          child: const Icon(Icons.access_time_filled_rounded, color: DuoColors.green, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Operating Hours', style: DuoTypography.headline(color: DuoColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text('Open 24 Hours · 7 Days', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: DuoColors.border),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: DuoColors.redTint,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: DuoColors.redShadow, width: 1.5),
                          ),
                          child: const Icon(Icons.groups_rounded, color: DuoColors.red, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Team Staff Accounts', style: DuoTypography.headline(color: DuoColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text('3 active members · Invite by phone', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 20, color: DuoColors.textSecondary),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: DuoColors.border),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: DuoColors.greenTint,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: DuoColors.greenShadow, width: 1.5),
                          ),
                          child: const Icon(Icons.verified_rounded, color: DuoColors.green, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bank Trust Score', style: DuoTypography.headline(color: DuoColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text('Score: 85 (Reliable)', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: DuoColors.greenTint,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: DuoColors.greenShadow, width: 1.0),
                          ),
                          child: const Text(
                            'RELIABLE',
                            style: TextStyle(
                              fontFamily: DuoTypography.fontFamily,
                              color: DuoColors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            DuoButton(
              label: 'EXIT CONSOLE',
              variant: DuoButtonVariant.secondary,
              onPressed: () => context.go('/'),
            ),
          ],
        ),
      ),
    );
  }
}
