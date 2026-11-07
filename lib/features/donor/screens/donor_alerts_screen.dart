// ============================================================================
// BloodNorms | donor_alerts_screen.dart
// Donor Alerts Tab — Duolingo Feather Red Style
// Physical 3D Emergency Card, Mascot speech bubble, Material Icons, Arial
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/duo_colors.dart';
import '../../../core/theme/duo_typography.dart';
import '../../../core/widgets/duo_button.dart';
import '../../../core/widgets/duo_header_bar.dart';

class DonorAlertsScreen extends StatefulWidget {
  const DonorAlertsScreen({super.key});

  @override
  State<DonorAlertsScreen> createState() => _DonorAlertsScreenState();
}

class _DonorAlertsScreenState extends State<DonorAlertsScreen> {
  bool _hasActiveAlert = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: const DuoHeaderBar(
        title: 'Emergency Alerts',
        showBackButton: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Mascot Speech Bubble
            const DuoSpeechBubble(
              emoji: '🚨',
              text: 'Emergency request incoming! Check distance and tap ACCEPT if you can donate.',
            ),
            const SizedBox(height: 20),

            Text('Live Alerts', style: DuoTypography.title1(color: DuoColors.textPrimary)),
            const SizedBox(height: 16),

            // Incoming Active Alert Card in 3D Card
            if (_hasActiveAlert) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: DuoColors.redShadow, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: DuoColors.redShadow,
                      offset: Offset(0, 5),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: DuoColors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'URGENT NOW',
                            style: TextStyle(
                              fontFamily: DuoTypography.fontFamily,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: DuoColors.redTint,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: DuoColors.redShadow, width: 1.5),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 14, color: DuoColors.red),
                              SizedBox(width: 4),
                              Text(
                                '1.8 KM AWAY',
                                style: TextStyle(
                                  fontFamily: DuoTypography.fontFamily,
                                  color: DuoColors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text('Government General Hospital', style: DuoTypography.title2(color: DuoColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text('1 Unit O+ Whole blood needed immediately for surgery', style: DuoTypography.body(color: DuoColors.textPrimary)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: DuoButton(
                            label: 'ACCEPT',
                            icon: Icons.check_circle_rounded,
                            variant: DuoButtonVariant.success,
                            height: 48,
                            onPressed: () => context.push('/donor/ticket/mock-1'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DuoButton(
                            label: 'DECLINE',
                            variant: DuoButtonVariant.secondary,
                            height: 48,
                            onPressed: () {
                              setState(() => _hasActiveAlert = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Alert declined. You will not be contacted for this request.'),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            Text('Past Requests', style: DuoTypography.title3(color: DuoColors.textPrimary)),
            const SizedBox(height: 12),
            _buildPastAlertCard(
              hospital: 'Rotary Blood Bank Camp',
              date: '14 Oct 2026',
              group: 'O+',
              status: 'DONATED',
              statusColor: DuoColors.green,
              statusBg: DuoColors.greenTint,
              statusBorder: DuoColors.greenShadow,
            ),
            const SizedBox(height: 12),
            _buildPastAlertCard(
              hospital: 'Apollo Speciality Centre',
              date: '28 Aug 2026',
              group: 'O+',
              status: 'FULFILLED',
              statusColor: DuoColors.textSecondary,
              statusBg: const Color(0xFFF0F0F0),
              statusBorder: DuoColors.border,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastAlertCard({
    required String hospital,
    required String date,
    required String group,
    required String status,
    required Color statusColor,
    required Color statusBg,
    required Color statusBorder,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(hospital, style: DuoTypography.headline(color: DuoColors.textPrimary)),
              const SizedBox(height: 4),
              Text(date, style: DuoTypography.caption(color: DuoColors.textSecondary)),
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
}
