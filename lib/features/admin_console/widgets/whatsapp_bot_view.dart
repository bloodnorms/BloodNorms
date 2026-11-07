// ============================================================================
// BloodNorms | whatsapp_bot_view.dart
// Modern Minimal Meta WhatsApp Cloud API Live Bot & Test Bench Dispatcher
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
              widget.onShowToast('WhatsApp runtime credentials saved and active');
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
    final isConfigured = waConfig.isConfigured;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WhatsApp Cloud API bot & test bench',
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: BrandColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Direct integration with Meta Graph API for alerts and conversational triage',
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontSize: 13,
                  color: BrandColors.textSecondary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isConfigured ? BrandColors.statusSuccessTint : BrandColors.statusWarningTint,
              borderRadius: BorderRadius.circular(BrandColors.radiusPill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: isConfigured ? BrandColors.statusSuccess : BrandColors.statusWarning,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isConfigured ? 'Connected' : 'Credentials needed',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: isConfigured ? BrandColors.statusSuccess : BrandColors.statusWarning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
