// ============================================================================
// BloodNorms | whatsapp_dispatcher_card.dart
// Live Dispatch Test Bench Card for Meta WhatsApp Cloud API
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/messaging_service.dart';
import '../../../shared/theme/brand_typography.dart';
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.send_rounded, size: 18, color: Color(0xFF25D366)),
              SizedBox(width: 8),
              Text(
                'Live WhatsApp Dispatch Test Bench',
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: widget.testPhoneController,
                  decoration: InputDecoration(
                    labelText: 'Recipient Phone',
                    hintText: '+91 90524 93747',
                    prefixIcon:
                        const Icon(Icons.phone_iphone_rounded, size: 18),
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: widget.customTextController,
                  decoration: InputDecoration(
                    labelText: 'Custom Alert Message Text',
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
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
              ElevatedButton.icon(
                onPressed: _isWaSending ? null : _sendHelloWorldTemplate,
                icon: const Icon(Icons.rocket_launch_rounded, size: 16),
                label: const Text('Send "hello_world" Template'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                ),
              ),
              OutlinedButton.icon(
                onPressed: _isWaSending ? null : _sendUrgentAlert,
                icon: const Icon(Icons.emergency_rounded,
                    size: 16, color: Color(0xFFE52E2E)),
                label: const Text('Send Urgent Blood Alert'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE52E2E)),
              ),
              OutlinedButton.icon(
                onPressed: _isWaSending ? null : _sendCustomMessage,
                icon: const Icon(Icons.message_rounded,
                    size: 16, color: Color(0xFF25D366)),
                label: const Text('Send Custom Message'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF166534)),
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
      widget.onShowToast('✓ WhatsApp hello_world delivered!');
    } else {
      widget.onShowToast('✕ Delivery failed: ${res.errorSummary}');
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
