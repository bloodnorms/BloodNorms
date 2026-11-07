// ============================================================================
// BloodNorms | donor_ticket_actions.dart
// Action buttons for donor ticket (Call, Navigate, Certificate, or Back)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../shared/constants/blood_groups.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
import 'donor_ticket_certificate_dialog.dart';

class DonorTicketActions extends StatelessWidget {
  final bool isCancelled;
  final String hospitalName;
  final String hospitalArea;
  final String requesterPhone;
  final String donationCode;
  final BloodGroup bloodGroup;

  const DonorTicketActions({
    super.key,
    required this.isCancelled,
    required this.hospitalName,
    required this.hospitalArea,
    required this.requesterPhone,
    required this.donationCode,
    required this.bloodGroup,
  });

  Future<void> _callRequester(BuildContext context) async {
    final uri = Uri.parse('tel:${requesterPhone.replaceAll(' ', '')}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else if (context.mounted) {
        _showPhoneFallback(context);
      }
    } catch (_) {
      if (context.mounted) _showPhoneFallback(context);
    }
  }

  void _showPhoneFallback(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: BrandColors.border, width: 2.0),
        ),
        title: Text('Contact Requester', style: BrandTypography.title3(color: BrandColors.textPrimary)),
        content: Text('Requester contact number: $requesterPhone', style: BrandTypography.body(color: BrandColors.textSecondary)),
        actions: [
          ActionButton(
            label: 'OK',
            variant: ActionButtonVariant.primary,
            height: 44,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isCancelled) {
      return ActionButton(
        label: 'BACK TO EMERGENCY ALERTS',
        icon: Icons.arrow_back_rounded,
        variant: ActionButtonVariant.primary,
        height: 52,
        onPressed: () => context.go('/donor/alerts'),
      );
    }

    return Column(
      children: [
        ActionButton(
          label: 'CALL REQUESTER',
          icon: Icons.phone_rounded,
          variant: ActionButtonVariant.primary,
          height: 52,
          onPressed: () => _callRequester(context),
        ),
        const SizedBox(height: 12),
        ActionButton(
          label: 'NAVIGATE IN MAPS',
          icon: Icons.navigation_rounded,
          variant: ActionButtonVariant.secondary,
          height: 52,
          onPressed: () async {
            final url = Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$hospitalName $hospitalArea')}',
            );
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            }
          },
        ),
        const SizedBox(height: 12),
        ActionButton(
          label: 'CERTIFICATE OF APPRECIATION',
          icon: Icons.workspace_premium_rounded,
          variant: ActionButtonVariant.success,
          height: 52,
          onPressed: () => showTicketCertificateModal(
            context: context,
            donationCode: donationCode,
            hospitalName: hospitalName,
            bloodGroup: bloodGroup,
          ),
        ),
      ],
    );
  }
}
