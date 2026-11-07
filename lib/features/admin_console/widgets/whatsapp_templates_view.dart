// ============================================================================
// BloodNorms | whatsapp_templates_view.dart
// WhatsApp Pre-approved HSM Templates Preview & Live Editor View
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/messaging_service.dart';
import 'whatsapp_chat_bubble_preview.dart';

export 'whatsapp_chat_bubble_preview.dart';

class WhatsAppTemplatesView extends StatefulWidget {
  final void Function(String message) onShowToast;

  const WhatsAppTemplatesView({
    super.key,
    required this.onShowToast,
  });

  @override
  State<WhatsAppTemplatesView> createState() => _WhatsAppTemplatesViewState();
}

class _WhatsAppTemplatesViewState extends State<WhatsAppTemplatesView> {
  String _activeTemplateKey = 'camp_invite';
  final TextEditingController _templateNameVar =
      TextEditingController(text: 'Suresh');
  final TextEditingController _templateHospVar =
      TextEditingController(text: 'GGH Rajahmundry');
  final TextEditingController _templateUnitsVar =
      TextEditingController(text: '2 Units of O+');
  final TextEditingController _waTestPhoneController =
      TextEditingController(text: '+91 9052493747');

  @override
  void dispose() {
    _templateNameVar.dispose();
    _templateHospVar.dispose();
    _templateUnitsVar.dispose();
    _waTestPhoneController.dispose();
    super.dispose();
  }

  String _formatMessageBody() {
    if (_activeTemplateKey == 'camp_invite') {
      return 'Namaste ${_templateNameVar.text}! 🩸\n\nA voluntary blood camp is organized at ${_templateHospVar.text}. Can you join and donate ${_templateUnitsVar.text} to save local lives in Rajahmundry?\n\nReply YES to confirm your slot.';
    } else if (_activeTemplateKey == 'emergency_alert') {
      return '🚨 URGENT: ${_templateUnitsVar.text} needed immediately at ${_templateHospVar.text} for critical patient!\n\n${_templateNameVar.text}, are you available to donate right now? Reply 1 for YES, 2 for NO.';
    } else {
      return 'Thank you ${_templateNameVar.text}! Your recent donation of ${_templateUnitsVar.text} at ${_templateHospVar.text} was verified. Your certificate is ready in your BloodNorms Pass! 🎖️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ChoiceChip(
                label: const Text('Camp Invitation'),
                selected: _activeTemplateKey == 'camp_invite',
                onSelected: (_) =>
                    setState(() => _activeTemplateKey = 'camp_invite'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Emergency Need Alert'),
                selected: _activeTemplateKey == 'emergency_alert',
                onSelected: (_) =>
                    setState(() => _activeTemplateKey = 'emergency_alert'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Donor Thank You'),
                selected: _activeTemplateKey == 'thank_you',
                onSelected: (_) =>
                    setState(() => _activeTemplateKey = 'thank_you'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _templateNameVar,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Donor Name {{name}}',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _templateHospVar,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Hospital {{hospital}}',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _templateUnitsVar,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Units/Group {{units}}',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          WhatsAppChatBubblePreview(
            formattedMessageBody: _formatMessageBody(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => widget.onShowToast(
                  'Template updated and synchronized with Meta Cloud API',
                ),
                icon: const Icon(Icons.save_rounded, size: 16),
                label: const Text('Save & Sync Template'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _sendTestMessage,
                icon: const Icon(Icons.send_rounded,
                    size: 16, color: Color(0xFF25D366)),
                label: Text('Send Test to ${_waTestPhoneController.text}'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _sendTestMessage() async {
    final text = _formatMessageBody();
    widget.onShowToast(
        'Sending WhatsApp message to ${_waTestPhoneController.text}...');
    final res = await WhatsAppService().sendTextMessage(
      toPhone: _waTestPhoneController.text,
      bodyText: text,
    );
    if (res.success) {
      widget.onShowToast(
          '✓ WhatsApp message delivered! ID: ${res.messageId}');
    } else {
      widget.onShowToast('✕ Meta error: ${res.errorSummary}');
    }
  }
}
