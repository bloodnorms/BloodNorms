// ============================================================================
// BloodNorms | bank_console_screen.dart
// Blood Bank Console — Duolingo Feather Red Style
// Tabs: Stock, Confirm (Keypad), Donors (Expected), Camps, More
// DuoBottomNavBar, 3D steppers, Material Icons, Arial normal/bold only
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/blood_groups.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/duo_colors.dart';
import '../../../core/theme/duo_typography.dart';
import '../../../core/widgets/duo_blood_tile.dart';
import '../../../core/widgets/duo_bottom_nav_bar.dart';
import '../../../core/widgets/duo_button.dart';
import '../../../core/widgets/duo_header_bar.dart';
import '../../../core/widgets/duo_keypad.dart';
import '../../../core/widgets/duo_segmented_control.dart';

class BankConsoleScreen extends StatefulWidget {
  const BankConsoleScreen({super.key});

  @override
  State<BankConsoleScreen> createState() => _BankConsoleScreenState();
}

class _BankConsoleScreenState extends State<BankConsoleScreen> {
  int _currentTab = 0;

  // Stock State (8 groups x units)
  BloodComponentType _selectedComponent = BloodComponentType.wholeBlood;
  final Map<BloodGroup, int> _stock = {
    BloodGroup.aPositive: 4,
    BloodGroup.aNegative: 1,
    BloodGroup.bPositive: 8,
    BloodGroup.bNegative: 2,
    BloodGroup.abPositive: 2,
    BloodGroup.abNegative: 0,
    BloodGroup.oPositive: 6,
    BloodGroup.oNegative: 1,
  };
  bool _isSavingStock = false;

  // Confirm State
  String _enteredCode = '';
  bool _isConfirming = false;

  // 1. Save Stock
  Future<void> _saveStock() async {
    setState(() => _isSavingStock = true);
    final rows = _stock.entries.map((e) {
      return {
        'group': e.key.label,
        'component': _selectedComponent.code,
        'units': e.value,
      };
    }).toList();

    await SupabaseService().setBankStock(rows);
    setState(() => _isSavingStock = false);

    if (mounted) {
      _showToast(context, 'Blood bank stock updated successfully!');
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
        _showSuccessDialog(res['first_name'] ?? 'Donor', res['blood_group'] ?? 'O+');
      } else {
        _showToast(context, 'Invalid code or already used');
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
              setState(() {
                _stock[BloodGroup.oPositive] = (_stock[BloodGroup.oPositive] ?? 6) + 1;
              });
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

                  // Bank Title Card
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rotary Central Bank', style: DuoTypography.title2(color: DuoColors.textPrimary)),
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
                    onValueChanged: (val) => setState(() => _selectedComponent = val),
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
      appBar: const DuoHeaderBar(
        title: 'Expected Donors',
        showBackButton: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Mascot Speech Bubble
            const DuoSpeechBubble(
              emoji: '👥',
              text: 'Donors heading to requests within 3 km. Keep beds prepared and welcome them with warmth!',
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

            _buildExpectedDonorItem('Ramesh', 'O+', '~15 min ETA', 'ON THE WAY', DuoColors.green, DuoColors.greenTint, DuoColors.greenShadow),
            const SizedBox(height: 12),
            _buildExpectedDonorItem('Priya', 'B+', '~40 min ETA', 'ACCEPTED', DuoColors.red, DuoColors.redTint, DuoColors.redShadow),
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
                    name[0],
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
        ],
      ),
    );
  }

  // --- TAB 4: CAMPS ---
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
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            const DuoSpeechBubble(
              emoji: '⛺',
              text: 'Blood donation drives bring communities together. Organize camps and track donor RSVPs easily!',
            ),
            const SizedBox(height: 20),

            Text('Active Camps', style: DuoTypography.title2(color: DuoColors.textPrimary)),
            const SizedBox(height: 12),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Rotary Community Hall Blood Drive',
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
                        child: const Text(
                          'UPCOMING',
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
                  const SizedBox(height: 6),
                  Text('15 Nov 2026 · 48 registered donors', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateCampModal(BuildContext context) {
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
            Text('Create Blood Drive Camp', style: DuoTypography.title2(color: DuoColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Set venue, date, and target donor capacity.', style: DuoTypography.body(color: DuoColors.textSecondary)),
            const SizedBox(height: 20),
            DuoButton(
              label: 'CONFIRM ROTARY HALL DRIVE',
              variant: DuoButtonVariant.primary,
              onPressed: () {
                Navigator.pop(ctx);
                _showToast(context, 'Blood drive camp created successfully!');
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
