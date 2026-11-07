// ============================================================================
// BloodNorms | review_send_screen.dart
// Review & Send screen — Duolingo Feather Red Style
// 3D paper summary card, safety notice, 3D primary send CTA, Material
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/blood_group_tile.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/screen_header.dart';
import '../providers/request_flow_provider.dart';

class ReviewSendScreen extends StatefulWidget {
  const ReviewSendScreen({super.key});

  @override
  State<ReviewSendScreen> createState() => _ReviewSendScreenState();
}

class _ReviewSendScreenState extends State<ReviewSendScreen> {
  bool _isSending = false;

  Future<void> _sendAlert() async {
    final state = globalRequestFlow.state;

    if (state.hospitalName.isEmpty || state.patientFirstName.isEmpty || state.requesterPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all required patient and hospital details first.'),
          backgroundColor: DuoColors.red,
        ),
      );
      context.pop();
      return;
    }

    setState(() => _isSending = true);

    try {
      final reqId = await SupabaseService().createRequest(
        bloodGroup: state.bloodGroup?.label ?? 'O+',
        component: state.component.code,
        unitsNeeded: state.units,
        urgency: state.urgency.code,
        hospitalName: state.hospitalName,
        hospitalArea: state.hospitalArea.isNotEmpty ? state.hospitalArea : AppConstants.pilotCity,
        lat: state.lat,
        lng: state.lng,
        requesterName: state.requesterName.isNotEmpty ? state.requesterName : state.patientFirstName,
        requesterPhone: state.requesterPhone,
        patientFirstName: state.patientFirstName,
        allowCompatible: state.allowCompatible,
        note: state.note,
      );

      globalRequestFlow.setActiveRequestId(reqId);
      if (mounted) {
        context.go('/live/$reqId');
      }
    } catch (e) {
      if (mounted) {
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
                const Icon(Icons.error_outline_rounded, color: DuoColors.red, size: 24),
                const SizedBox(width: 8),
                Text('Broadcast Error', style: DuoTypography.title3(color: DuoColors.red)),
              ],
            ),
            content: Text(
              'Failed to communicate with Supabase: $e\n\nPlease check your internet connection and try again.',
              style: DuoTypography.body(color: DuoColors.textSecondary),
            ),
            actions: [
              DuoButton(
                label: 'RETRY',
                variant: DuoButtonVariant.primary,
                height: 44,
                onPressed: () {
                  Navigator.pop(ctx);
                  _sendAlert();
                },
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final state = globalRequestFlow.state;

    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: const DuoHeaderBar(
        title: 'Review Alert',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Duolingo Speech Bubble
                    const DuoSpeechBubble(
                      emoji: '🚀',
                      text: "Almost ready! Verify the details below and tap SEND to alert nearby donors instantly.",
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Review Summary',
                      style: DuoTypography.title1(color: DuoColors.textPrimary),
                    ),
                    const SizedBox(height: 20),

                    // 3D Paper Summary Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
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
                          Row(
                            children: [
                              if (state.bloodGroup != null)
                                DuoBloodTile(
                                  bloodGroup: state.bloodGroup!,
                                  isSelected: false,
                                  size: 64,
                                  onTap: () {},
                                ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${state.units} ${state.units == 1 ? "Unit" : "Units"} ${state.component.label}',
                                      style: DuoTypography.title2(color: DuoColors.textPrimary),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Urgency: ${state.urgency.label.toUpperCase()}',
                                      style: TextStyle(
                                        fontFamily: DuoTypography.fontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: DuoColors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32, color: DuoColors.border),
                          _buildDetailRow('Hospital', state.hospitalName.isNotEmpty ? state.hospitalName : state.placeLabel),
                          const SizedBox(height: 12),
                          _buildDetailRow('Patient', state.patientFirstName.isNotEmpty ? state.patientFirstName : 'Not specified'),
                          const SizedBox(height: 12),
                          _buildDetailRow('Contact', state.requesterPhone.isNotEmpty ? state.requesterPhone : 'Not specified'),
                          const SizedBox(height: 12),
                          _buildDetailRow('Compatible', state.allowCompatible ? 'Allowed' : 'Exact Group Only'),
                          if (state.note.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow('Note', state.note),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Safety Notice 3D Card (BR-12)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: DuoColors.redTint,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: DuoColors.redShadow, width: 1.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.shield_rounded, size: 20, color: DuoColors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              loc.t('safety.notice'),
                              style: TextStyle(
                                fontFamily: DuoTypography.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.normal,
                                color: DuoColors.textPrimary,
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
            // Sticky 3D Primary Action
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: DuoColors.border, width: 2.0)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: DuoButton(
                  label: loc.t('cta.send'),
                  icon: Icons.bolt_rounded,
                  isLoading: _isSending,
                  variant: DuoButtonVariant.primary,
                  onPressed: _sendAlert,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: DuoTypography.caption(color: DuoColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: DuoTypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: DuoColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
