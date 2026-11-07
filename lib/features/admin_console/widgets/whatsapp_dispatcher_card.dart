// ============================================================================
// BloodNorms | whatsapp_dispatcher_card.dart
// Modern Minimal Live Dispatch Test Bench Card for Meta WhatsApp Cloud API
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/messaging_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';
import 'whatsapp_dispatch_feedback.dart';

export 'whatsapp_dispatch_feedback.dart';

class WhatsAppDispatcherCard extends StatefulWidget {
  final TextEditingController testPhoneController;
  final TextEditingController customTextController;
  final void Function(String message) onShowToast;

  const WhatsAppDispatcherCard({
    super.key,
    required this.testPhoneController,
    required this.customTextController,
    required this.onShowToast,
  });

  @override
  State<WhatsAppDispatcherCard> createState() => _WhatsAppDispatcherCardState();
}

class _WhatsAppDispatcherCardState extends State<WhatsAppDispatcherCard> {
  bool _isWaSending = false;
  String? _waLastDispatchStatus;
  bool? _waLastDispatchSuccess;
  String? _waLastMessageId;
  String? _waLastErrorDetails;

  void _startSending() {
    setState(() {
      _isWaSending = true;
      _waLastDispatchStatus = null;
      _waLastDispatchSuccess = null;
    });
  }

  void _finishSending(WhatsAppDispatchResult res) {
    setState(() {
      _isWaSending = false;
      _waLastDispatchSuccess = res.success;
      _waLastDispatchStatus = res.statusCode.toString();
      _waLastMessageId = res.messageId;
      _waLastErrorDetails = res.detailedError ?? res.errorSummary;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live message dispatch test bench',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Dispatch interactive test payloads to verify real delivery status',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 13,
              color: BrandColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: widget.testPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Recipient phone',
                    hintText: '+91 90524 93747',
                    prefixIcon: Icon(Icons.phone_iphone_rounded, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: widget.customTextController,
                  decoration: const InputDecoration(
                    labelText: 'Custom alert message',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppPillButton(
                label: 'Send "hello_world" template',
                icon: Icons.send_rounded,
                variant: AppPillButtonVariant.primary,
                isLoading: _isWaSending,
                onPressed: _isWaSending ? null : _sendHelloWorldTemplate,
              ),
              AppPillButton(
                label: 'Send urgent blood alert',
                icon: Icons.emergency_outlined,
                variant: AppPillButtonVariant.secondary,
                onPressed: _isWaSending ? null : _sendUrgentAlert,
              ),
              AppPillButton(
                label: 'Send custom message',
                icon: Icons.chat_bubble_outline_rounded,
                variant: AppPillButtonVariant.tonal,
                onPressed: _isWaSending ? null : _sendCustomMessage,
              ),
            ],
          ),
          WhatsAppDispatchFeedback(
            isWaSending: _isWaSending,
            lastDispatchSuccess: _waLastDispatchSuccess,
            lastDispatchStatus: _waLastDispatchStatus,
            lastMessageId: _waLastMessageId,
            lastErrorDetails: _waLastErrorDetails,
          ),
        ],
      ),
    );
  }

  Future<void> _sendHelloWorldTemplate() async {
    _startSending();
    final res = await WhatsAppService().sendTemplateMessage(
      toPhone: widget.testPhoneController.text,
      templateName: 'hello_world',
      languageCode: 'en_US',
    );
    _finishSending(res);
    if (res.success) {
      widget.onShowToast('WhatsApp hello_world delivered');
    } else {
      widget.onShowToast('Delivery failed: ${res.errorSummary}');
    }
  }

  Future<void> _sendUrgentAlert() async {
    _startSending();
    final res = await WhatsAppService().sendTextMessage(
      toPhone: widget.testPhoneController.text,
      bodyText:
          '🚨 URGENT BLOOD ALERT: 2 Units of O+ required at GGH Rajahmundry. Can you donate today to save a life? Reply YES to confirm.',
    );
    _finishSending(res);
  }

  Future<void> _sendCustomMessage() async {
    _startSending();
    final res = await WhatsAppService().sendTextMessage(
      toPhone: widget.testPhoneController.text,
      bodyText: widget.customTextController.text,
    );
    _finishSending(res);
  }
}
