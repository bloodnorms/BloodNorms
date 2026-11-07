// ============================================================================
// BloodNorms | whatsapp_response_parser.dart
// Meta Graph API WhatsApp response parsing and error diagnostics
// ============================================================================

import 'dart:convert';
import '../models/whatsapp_models.dart';

class WhatsAppResponseParser {
  /// Parse and diagnose Meta Graph API responses
  static WhatsAppDispatchResult parse(int statusCode, String responseBody) {
    Map<String, dynamic>? json;
    try {
      json = jsonDecode(responseBody) as Map<String, dynamic>?;
    } catch (_) {}

    if (statusCode >= 200 && statusCode < 300 && json != null) {
      final messages = json['messages'] as List?;
      final messageId = (messages != null && messages.isNotEmpty)
          ? messages.first['id']?.toString()
          : null;

      return WhatsAppDispatchResult(
        success: true,
        statusCode: statusCode,
        messageId: messageId,
        rawResponse: json,
      );
    }

    final errorObj = json?['error'] as Map<String, dynamic>?;
    final errorCode = errorObj?['code'] as int? ?? statusCode;
    final errorMessage = errorObj?['message']?.toString() ?? 'Unknown Meta API error';

    String diagnosticMessage = errorMessage;

    if (errorCode == 190) {
      diagnosticMessage =
          'Invalid or expired Meta Access Token. Please refresh your Temporary Access Token or generate a Permanent System User Token in Meta Developer Portal.';
    } else if (errorCode == 131030) {
      diagnosticMessage =
          'Recipient phone number is not in your Meta Sandbox Allowed List. In Meta Developer Portal > WhatsApp > API Setup > Step 5, click "Manage phone number list" and add the recipient number.';
    } else if (errorCode == 100) {
      diagnosticMessage =
          'Invalid Phone Number ID. Ensure WHATSAPP_PHONE_NUMBER_ID is Meta\'s 15-digit ID (e.g. 109284759281928), NOT a 10-digit mobile number.';
    } else if (errorCode == 132000 || errorCode == 132001) {
      diagnosticMessage =
          'Template not found or language mismatch. In sandbox, test with template "hello_world" and language "en_US".';
    } else if (errorCode == 131047) {
      diagnosticMessage =
          'More than 24 hours have passed since recipient last messaged you. You must send a pre-approved Template message instead of a free text message.';
    }

    return WhatsAppDispatchResult(
      success: false,
      statusCode: statusCode,
      errorSummary: 'Meta Error $errorCode: $diagnosticMessage',
      detailedError: errorObj != null ? jsonEncode(errorObj) : responseBody,
      rawResponse: json,
    );
  }
}
