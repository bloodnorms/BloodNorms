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
import 'donation_confirmation_dialogs.dart';

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
        showDonationVerifiedSuccessDialog(
          context: context,
          name: res['first_name']?.toString() ?? 'Donor',
          group: res['blood_group']?.toString() ?? 'Blood',
        );
        widget.onDonationConfirmed();
      } else {
        _showToast(res['error']?.toString() ?? 'Invalid or expired pass code');
      }
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
                onPressed: () => showReasonForNotDonatingSheet(context: context, onRecorded: _showToast),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
