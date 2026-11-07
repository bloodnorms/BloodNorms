// ============================================================================
// BloodNorms | confirm_donation_tab_view.dart
// Blood Bank Console: Confirm Donation Tab with 6-digit PIN Keypad
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/pin_keypad.dart';

class ConfirmDonationTabView extends StatefulWidget {
  final VoidCallback onDonationConfirmed;

  const ConfirmDonationTabView({
    super.key,
    required this.onDonationConfirmed,
  });

  @override
  State<ConfirmDonationTabView> createState() => _ConfirmDonationTabViewState();
}

class _ConfirmDonationTabViewState extends State<ConfirmDonationTabView> {
  String _enteredCode = '';
  bool _isConfirming = false;

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
        widget.onDonationConfirmed();
      } else {
        _showToast(res['error']?.toString() ?? 'Invalid or expired pass code');
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
          side: const BorderSide(color: BrandColors.border, width: 2.0),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BrandColors.greenTint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BrandColors.greenShadow, width: 1.5),
              ),
              child: const Icon(Icons.check_circle_rounded, color: BrandColors.green, size: 24),
            ),
            const SizedBox(width: 12),
            Text('Donation Verified!', style: BrandTypography.title3(color: BrandColors.textPrimary)),
          ],
        ),
        content: Text(
          'Successfully confirmed donation for $name ($group). Blood stock and donor history updated.',
          style: BrandTypography.body(color: BrandColors.textSecondary),
        ),
        actions: [
          ActionButton(
            label: 'DONE',
            height: 44,
            variant: ActionButtonVariant.success,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
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

  void _showNotDonatedModal() {
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
            Text('Reason for Not Donating', style: BrandTypography.title2(color: BrandColors.textPrimary)),
            const SizedBox(height: 8),
            Text('The request search will reopen for other donors.', style: BrandTypography.body(color: BrandColors.textSecondary)),
            const SizedBox(height: 20),
            ActionButton(
              label: 'Medical Deferral (Doctor decision)',
              variant: ActionButtonVariant.secondary,
              height: 48,
              onPressed: () {
                Navigator.pop(ctx);
                _showToast('Recorded: Medical deferral');
              },
            ),
            const SizedBox(height: 10),
            ActionButton(
              label: 'Did Not Come / Cancelled',
              variant: ActionButtonVariant.secondary,
              height: 48,
              onPressed: () {
                Navigator.pop(ctx);
                _showToast('Recorded: Donor did not arrive');
              },
            ),
            const SizedBox(height: 10),
            ActionButton(
              label: 'CANCEL',
              variant: ActionButtonVariant.plain,
              height: 44,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.bgGrouped,
      appBar: const ScreenHeader(
        title: 'Confirm Donation',
        showBackButton: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SpeechBubble(
                emoji: '🎯',
                text: 'Ask the donor for the 6-digit confirmation code shown on their BloodNorms ticket!',
              ),
              const SizedBox(height: 20),
              Text('Enter 6-Digit Code', style: BrandTypography.title1(color: BrandColors.textPrimary)),
              const SizedBox(height: 6),
              Text(
                'Told by donor upon arrival at blood bank',
                style: BrandTypography.subhead(color: BrandColors.textSecondary),
              ),
              const SizedBox(height: 24),
              CodeDisplayDots(code: _enteredCode),
              const SizedBox(height: 24),
              if (_isConfirming)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(color: BrandColors.red),
                ),
              PinKeypad(
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
              ActionButton(
                label: 'NOT DONATED / DEFERRED',
                variant: ActionButtonVariant.plain,
                height: 40,
                onPressed: _showNotDonatedModal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
