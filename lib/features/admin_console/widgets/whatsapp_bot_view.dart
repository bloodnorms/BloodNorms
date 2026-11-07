// ============================================================================
// BloodNorms | whatsapp_bot_view.dart
// Meta WhatsApp Cloud API Live Bot & Test Bench Dispatcher
// Thin View Composing Status Header, Credentials Card, and Dispatcher Card
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/messaging_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import 'whatsapp_cloud_api_guide_card.dart';
import 'whatsapp_credentials_card.dart';
import 'whatsapp_dispatcher_card.dart';

export 'whatsapp_cloud_api_guide_card.dart';

class WhatsAppBotView extends StatefulWidget {
  final void Function(String message) onShowToast;

  const WhatsAppBotView({
    super.key,
    required this.onShowToast,
  });

  @override
  State<WhatsAppBotView> createState() => _WhatsAppBotViewState();
}

class _WhatsAppBotViewState extends State<WhatsAppBotView> {
  final TextEditingController _waTestPhoneController =
      TextEditingController(text: '+91 9052493747');
  final TextEditingController _waPhoneIdController = TextEditingController();
  final TextEditingController _waAccessTokenController = TextEditingController();
  final TextEditingController _waCustomTextController = TextEditingController(
    text:
        'Hello from BloodNorms Admin Console! Live Meta WhatsApp Cloud API test message.',
  );

  @override
  void dispose() {
    _waTestPhoneController.dispose();
    _waPhoneIdController.dispose();
    _waAccessTokenController.dispose();
    _waCustomTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waConfig = WhatsAppService().getConfig();
    final is10DigitMobile = _waPhoneIdController.text.trim().length == 10 &&
        RegExp(r'^[6-9]\d{9}$').hasMatch(_waPhoneIdController.text.trim());

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConnectionHeader(waConfig),
          const SizedBox(height: 16),
          WhatsAppCredentialsCard(
            phoneIdController: _waPhoneIdController,
            accessTokenController: _waAccessTokenController,
            is10DigitMobile: is10DigitMobile,
            onApplied: () {
              setState(() {});
              widget.onShowToast(
                  'WhatsApp runtime credentials saved and active!');
            },
          ),
          const SizedBox(height: 16),
          WhatsAppDispatcherCard(
            testPhoneController: _waTestPhoneController,
            customTextController: _waCustomTextController,
            onShowToast: widget.onShowToast,
          ),
          const SizedBox(height: 16),
          const WhatsAppCloudApiGuideCard(),
        ],
      ),
    );
  }

  Widget _buildConnectionHeader(WhatsAppConfigSummary waConfig) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meta WhatsApp Cloud API Live Bot & Test Dispatcher',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Direct integration with Meta Graph API v19.0 for alerts and triage.',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: waConfig.isConfigured
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: waConfig.isConfigured
                        ? const Color(0xFF86EFAC)
                        : const Color(0xFFFECACA),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: waConfig.isConfigured
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      waConfig.isConfigured
                          ? 'CREDENTIALS SET'
                          : 'CREDENTIALS NEEDED',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: waConfig.isConfigured
                            ? const Color(0xFF166534)
                            : const Color(0xFF991B1B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Inbound WhatsApp Emergency Assistant',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: const Text(
              'Triages emergency blood needs via Meta Cloud API webhooks',
            ),
            value: true,
            activeThumbColor: BrandColors.green,
            onChanged: (val) =>
                widget.onShowToast('WhatsApp assistant status updated'),
          ),
        ],
      ),
    );
  }
}
