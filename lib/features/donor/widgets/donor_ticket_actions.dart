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
import '../../../shared/widgets/app_pill_button.dart';

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
        backgroundColor: BrandColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BrandColors.radiusDialog),
          side: const BorderSide(color: BrandColors.borderSubtle, width: 1.0),
        ),
        title: Text('Contact Requester', style: BrandTypography.title3(color: BrandColors.textPrimary)),
        content: Text('Requester contact number: $requesterPhone', style: BrandTypography.body(color: BrandColors.textSecondary)),
        actions: [
          AppPillButton(
            label: 'OK',
            variant: AppPillButtonVariant.primary,
            height: 40,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isCancelled) {
      return AppPillButton(
        label: 'Back to Emergency Alerts',
        icon: Icons.arrow_back_rounded,
        variant: AppPillButtonVariant.primary,
        isFullWidth: true,
        onPressed: () => context.go('/donor/alerts'),
      );
    }

    return Column(
      children: [
        AppPillButton(
          label: 'Call Requester',
          icon: Icons.phone_outlined,
          variant: AppPillButtonVariant.primary,
          isFullWidth: true,
          onPressed: () => _callRequester(context),
        ),
        const SizedBox(height: 12),
        AppPillButton(
          label: 'Navigate in Maps',
          icon: Icons.navigation_outlined,
          variant: AppPillButtonVariant.secondary,
          isFullWidth: true,
          onPressed: () async {
            final url = Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$hospitalName $hospitalArea')}',
            );
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
        ),
      ],
    );
  }
}
