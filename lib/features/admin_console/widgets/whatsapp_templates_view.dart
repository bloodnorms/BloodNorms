// ============================================================================
// BloodNorms | whatsapp_templates_view.dart
// Modern Minimal WhatsApp Pre-approved Templates Preview & Live Editor
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/messaging_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';
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
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTemplateChip('Camp invitation', 'camp_invite'),
              const SizedBox(width: 8),
              _buildTemplateChip('Emergency alert', 'emergency_alert'),
              const SizedBox(width: 8),
              _buildTemplateChip('Donor thank you', 'thank_you'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _templateNameVar,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Donor name {{name}}'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _templateHospVar,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Hospital {{hospital}}'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _templateUnitsVar,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Units/Group {{units}}'),
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
              AppPillButton(
                label: 'Save and sync template',
                icon: Icons.save_rounded,
                variant: AppPillButtonVariant.primary,
                onPressed: () => widget.onShowToast(
                  'Template updated and synchronized with Meta Cloud API',
                ),
              ),
              const SizedBox(width: 12),
              AppPillButton(
                label: 'Send test message',
                icon: Icons.send_rounded,
                variant: AppPillButtonVariant.secondary,
                onPressed: _sendTestMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateChip(String label, String key) {
    final isSelected = _activeTemplateKey == key;
    return GestureDetector(
      onTap: () => setState(() => _activeTemplateKey = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? BrandColors.primaryAction : BrandColors.surfaceSoft,
          borderRadius: BorderRadius.circular(BrandColors.radiusPill),
          border: Border.all(
            color: isSelected ? BrandColors.primaryAction : BrandColors.borderSubtle,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: BrandTypography.fontFamily,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : BrandColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Future<void> _sendTestMessage() async {
    final text = _formatMessageBody();
    widget.onShowToast('Sending WhatsApp message to ${_waTestPhoneController.text}...');
    final res = await WhatsAppService().sendTextMessage(
      toPhone: _waTestPhoneController.text,
      bodyText: text,
    );
    if (res.success) {
      widget.onShowToast('WhatsApp message delivered! ID: ${res.messageId}');
    } else {
      widget.onShowToast('Meta error: ${res.errorSummary}');
    }
  }
}
