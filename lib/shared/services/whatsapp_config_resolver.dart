// ============================================================================
// BloodNorms | whatsapp_config_resolver.dart
// WhatsApp credentials resolution and validation from environment and runtime
// ============================================================================

import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/whatsapp_models.dart';

class WhatsAppConfigResolver {
  static WhatsAppConfigSummary resolve({
    String? runtimePhoneId,
    String? runtimeToken,
    String? runtimeWabaId,
  }) {
    final phoneId = runtimePhoneId ??
        (dotenv.isInitialized
            ? dotenv.env['WHATSAPP_PHONE_NUMBER_ID']?.trim()
            : null) ??
        '';

    final token = runtimeToken ??
        (dotenv.isInitialized
            ? dotenv.env['WHATSAPP_ACCESS_TOKEN']?.trim()
            : null) ??
        '';

    final wabaId = runtimeWabaId ??
        (dotenv.isInitialized
            ? dotenv.env['WHATSAPP_BUSINESS_ACCOUNT_ID']?.trim()
            : null) ??
        '';

    final verify = (dotenv.isInitialized
            ? dotenv.env['WHATSAPP_WEBHOOK_VERIFY_TOKEN']?.trim()
            : null) ??
        'bloodnorms_wa_verify';

    final isLikelyMobile = phoneId.isNotEmpty &&
        (phoneId.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(phoneId));

    String masked = 'Not Set';
    if (token.isNotEmpty) {
      if (token.length > 12) {
        masked =
            '${token.substring(0, 6)}••••${token.substring(token.length - 4)}';
      } else {
        masked = '••••••••';
      }
    }

    return WhatsAppConfigSummary(
      phoneNumberId: phoneId,
      businessAccountId: wabaId,
      accessToken: token,
      webhookVerifyToken: verify,
      isConfigured: phoneId.isNotEmpty && token.isNotEmpty,
      isPhoneNumberIdLikelyMobile: isLikelyMobile,
      maskedToken: masked,
    );
  }
}
