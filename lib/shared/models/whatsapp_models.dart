// ============================================================================
// BloodNorms | whatsapp_models.dart
// Data models for WhatsApp Cloud API configuration and dispatch results
// ============================================================================

class WhatsAppConfigSummary {
  final String phoneNumberId;
  final String businessAccountId;
  final String accessToken;
  final String webhookVerifyToken;
  final bool isConfigured;
  final bool isPhoneNumberIdLikelyMobile;
  final String maskedToken;

  const WhatsAppConfigSummary({
    required this.phoneNumberId,
    required this.businessAccountId,
    required this.accessToken,
    required this.webhookVerifyToken,
    required this.isConfigured,
    required this.isPhoneNumberIdLikelyMobile,
    required this.maskedToken,
  });
}

class WhatsAppDispatchResult {
  final bool success;
  final int statusCode;
  final String? messageId;
  final String? errorSummary;
  final String? detailedError;
  final Map<String, dynamic>? rawResponse;

  const WhatsAppDispatchResult({
    required this.success,
    required this.statusCode,
    this.messageId,
    this.errorSummary,
    this.detailedError,
    this.rawResponse,
  });

  @override
  String toString() {
    if (success) {
      return 'Success (HTTP $statusCode): Message ID: $messageId';
    }
    return 'Failed (HTTP $statusCode): $errorSummary';
  }
}
