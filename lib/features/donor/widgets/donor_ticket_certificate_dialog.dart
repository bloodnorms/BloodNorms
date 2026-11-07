// ============================================================================
// BloodNorms | donor_ticket_certificate_dialog.dart
// Certificate of Appreciation modal dialog for verified donor emergency responses
// ============================================================================

import 'package:flutter/material.dart';
import '../../../../../shared/constants/blood_groups.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';

void showTicketCertificateModal({
  required BuildContext context,
  required String donationCode,
  required String hospitalName,
  required BloodGroup bloodGroup,
}) {
  final certId = 'AP-GGH-$donationCode';
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD4AF37), width: 3.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              offset: Offset(0, 8),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4D1),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4AF37), width: 2.0),
              ),
              child: const Center(
                child: Text('🏆', style: TextStyle(fontSize: 30)),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'GOVERNMENT GENERAL HOSPITAL\n& BLOODNORMS INITIATIVE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                color: Color(0xFF8B6508),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'CERTIFICATE OF APPRECIATION',
              textAlign: TextAlign.center,
              style: BrandTypography.title2(color: BrandColors.textPrimary).copyWith(
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFD4AF37), thickness: 1.5),
            const SizedBox(height: 12),
            Text(
              'This Certificate of Lifetime Honor is awarded for active emergency response to:',
              textAlign: TextAlign.center,
              style: BrandTypography.caption(color: BrandColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              'PASS: $donationCode',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                color: BrandColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'In response to emergency request at $hospitalName for blood group ${bloodGroup.label}. Verified and recorded in Supabase.',
              textAlign: TextAlign.center,
              style: BrandTypography.body(color: BrandColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_rounded, size: 18, color: BrandColors.green),
                  const SizedBox(width: 8),
                  Text(
                    'SEAL ID: $certId',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      color: BrandColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ActionButton(
              label: 'DOWNLOAD / SHARE',
              icon: Icons.share_rounded,
              variant: ActionButtonVariant.success,
              height: 46,
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Certificate $certId downloaded & shared!',
                      style: TextStyle(fontFamily: BrandTypography.fontFamily),
                    ),
                    backgroundColor: BrandColors.green,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ActionButton(
              label: 'CLOSE',
              variant: ActionButtonVariant.plain,
              height: 40,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    ),
  );
}
