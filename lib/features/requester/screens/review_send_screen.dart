// ============================================================================
// BloodNorms | review_send_screen.dart
// Review & Send screen — Thin Screen Composing Summary Card & Send CTA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/screen_header.dart';
import '../providers/request_flow_provider.dart';
import '../widgets/review_summary_card.dart';

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
          backgroundColor: BrandColors.red,
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
              side: const BorderSide(color: BrandColors.red, width: 2.0),
            ),
            title: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: BrandColors.red, size: 24),
                const SizedBox(width: 8),
                Text('Broadcast Error', style: BrandTypography.title3(color: BrandColors.red)),
              ],
            ),
            content: Text(
              'Failed to communicate with Supabase: $e\n\nPlease check your internet connection and try again.',
              style: BrandTypography.body(color: BrandColors.textSecondary),
            ),
            actions: [
              ActionButton(
                label: 'RETRY',
                variant: ActionButtonVariant.primary,
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
      backgroundColor: BrandColors.bgGrouped,
      appBar: const ScreenHeader(
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
                    const SpeechBubble(
                      emoji: '🚀',
                      text: "Almost ready! Verify the details below and tap SEND to alert nearby donors instantly.",
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Review Summary',
                      style: BrandTypography.title1(color: BrandColors.textPrimary),
                    ),
                    const SizedBox(height: 20),
                    ReviewSummaryCard(
                      state: state,
                      safetyNoticeText: loc.t('safety.notice'),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: BrandColors.border, width: 2.0)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ActionButton(
                  label: loc.t('cta.send'),
                  icon: Icons.bolt_rounded,
                  isLoading: _isSending,
                  variant: ActionButtonVariant.primary,
                  onPressed: _sendAlert,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
