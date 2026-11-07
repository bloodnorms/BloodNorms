// ============================================================================
// BloodNorms | donor_ticket_screen.dart
// Donor Ticket Screen — Duolingo Feather Red Style
// Physical 3D paper pass card, big 6-digit code box, Material Icons, Arial
// ============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/blood_groups.dart';
import '../../../core/theme/duo_colors.dart';
import '../../../core/theme/duo_typography.dart';
import '../../../core/widgets/duo_button.dart';
import '../../../core/widgets/duo_header_bar.dart';

class DonorTicketScreen extends StatelessWidget {
  final String donationCode;
  final String hospitalName;
  final String hospitalArea;
  final String wardDetail;
  final String requesterName;
  final String requesterPhone;
  final BloodGroup bloodGroup;

  const DonorTicketScreen({
    super.key,
    this.donationCode = '482910',
    this.hospitalName = 'Government General Hospital',
    this.hospitalArea = 'Danavaipeta, Rajahmundry',
    this.wardDetail = 'Ward 3, Second Floor ICU',
    this.requesterName = 'Suresh (Family)',
    this.requesterPhone = '+919848123456',
    this.bloodGroup = BloodGroup.oPositive,
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
      if (context.mounted) {
        _showPhoneFallback(context);
      }
    }
  }

  void _showPhoneFallback(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: DuoColors.border, width: 2.0),
        ),
        title: Text('Contact Requester', style: DuoTypography.title3(color: DuoColors.textPrimary)),
        content: Text('Requester contact number: $requesterPhone', style: DuoTypography.body(color: DuoColors.textSecondary)),
        actions: [
          DuoButton(
            label: 'OK',
            variant: DuoButtonVariant.primary,
            height: 44,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: const DuoHeaderBar(
        title: 'Donation Pass',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Mascot Speech Bubble
              const DuoSpeechBubble(
                emoji: '🎫',
                text: 'Show this 6-digit code at the blood bank reception so they can verify your donation!',
              ),
              const SizedBox(height: 20),

              // Duolingo 3D Paper Ticket Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: DuoColors.border, width: 2.0),
                  boxShadow: const [
                    BoxShadow(
                      color: DuoColors.border,
                      offset: Offset(0, 5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header band
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: const BoxDecoration(
                        color: DuoColors.red,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.confirmation_number_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'DONOR PASS',
                                style: TextStyle(
                                  fontFamily: DuoTypography.fontFamily,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              bloodGroup.label,
                              style: TextStyle(
                                fontFamily: DuoTypography.fontFamily,
                                color: DuoColors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Big 6-Digit Code Display
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      child: Column(
                        children: [
                          Text(
                            'CONFIRMATION CODE',
                            style: TextStyle(
                              fontFamily: DuoTypography.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: DuoColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            decoration: BoxDecoration(
                              color: DuoColors.redTint,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: DuoColors.red, width: 2.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: DuoColors.redShadow,
                                  offset: Offset(0, 3),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Text(
                              donationCode,
                              style: TextStyle(
                                fontFamily: DuoTypography.fontFamily,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8.0,
                                color: DuoColors.red,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Share ONLY with hospital staff upon arrival',
                            style: TextStyle(
                              fontFamily: DuoTypography.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.normal,
                              color: DuoColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, thickness: 1.5, color: DuoColors.border),

                    // Destination Info
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.local_hospital_rounded, color: DuoColors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  hospitalName,
                                  style: DuoTypography.headline(color: DuoColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 28),
                            child: Text(hospitalArea, style: DuoTypography.caption(color: DuoColors.textSecondary)),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 28),
                            child: Text(wardDetail, style: DuoTypography.caption(color: DuoColors.red)),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.person_rounded, color: DuoColors.textSecondary, size: 20),
                              const SizedBox(width: 8),
                              Text('Requester: $requesterName', style: DuoTypography.caption(color: DuoColors.textPrimary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3D Call Requester Button
              DuoButton(
                label: 'CALL REQUESTER',
                icon: Icons.phone_rounded,
                variant: DuoButtonVariant.success,
                height: 52,
                onPressed: () => _callRequester(context),
              ),
              const SizedBox(height: 12),

              // Medical check reminder
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: DuoColors.border, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medical_services_rounded, color: DuoColors.red, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'A doctor at the blood bank will verify your medical fitness before collection (BR-12).',
                        style: TextStyle(
                          fontFamily: DuoTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: DuoColors.textSecondary,
                        ),
                      ),
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
}
