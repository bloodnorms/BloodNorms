// ============================================================================
// BloodNorms | lib/shared/services/messaging_service.dart
// Meta WhatsApp Cloud API Service: Direct Dispatch, Test Bench, & Webhook Helper
// ============================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/whatsapp_models.dart';
import 'whatsapp_audit_logger.dart';
import 'whatsapp_config_resolver.dart';
import 'whatsapp_response_parser.dart';

export '../models/whatsapp_models.dart';

class WhatsAppService {
  static final WhatsAppService _instance = WhatsAppService._internal();
  factory WhatsAppService() => _instance;
  WhatsAppService._internal();

  static const String _graphApiVersion = 'v19.0';
  static const String _graphApiBase =
      'https://graph.facebook.com/$_graphApiVersion';

  String? _runtimePhoneNumberId;
  String? _runtimeAccessToken;
  String? _runtimeBusinessAccountId;

  void setRuntimeCredentials({
    String? phoneNumberId,
    String? accessToken,
    String? businessAccountId,
  }) {
    if (phoneNumberId != null) _runtimePhoneNumberId = phoneNumberId.trim();
    if (accessToken != null) _runtimeAccessToken = accessToken.trim();
    if (businessAccountId != null) {
      _runtimeBusinessAccountId = businessAccountId.trim();
    }
  }

  /// Get current WhatsApp Cloud API configuration
  WhatsAppConfigSummary getConfig() => WhatsAppConfigResolver.resolve(
        runtimePhoneId: _runtimePhoneNumberId,
        runtimeToken: _runtimeAccessToken,
        runtimeWabaId: _runtimeBusinessAccountId,
      );

  /// Normalize phone number to Meta's expected digits-only format
  static String normalizePhone(String rawPhone) {
    String cleaned = rawPhone.replaceAll(RegExp(r'[\s\+\-\(\)]'), '');
    if (cleaned.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
      cleaned = '91$cleaned';
    }
    return cleaned;
  }

  /// Mask phone number for DPDP compliance logging
  static String maskPhoneForAudit(String phone) {
    final cleaned = normalizePhone(phone);
    if (cleaned.length >= 10) {
      final prefix = cleaned.substring(0, cleaned.length - 5);
      return '+$prefix •••••';
    }
    return '••••••••••';
  }

  WhatsAppDispatchResult? _checkConfiguration(WhatsAppConfigSummary config) {
    if (!config.isConfigured) {
      return WhatsAppDispatchResult(
        success: false,
        statusCode: 400,
        errorSummary:
            'WhatsApp Cloud API is not configured. Missing Phone Number ID or Access Token.',
        detailedError: config.isPhoneNumberIdLikelyMobile
            ? 'Note: WHATSAPP_PHONE_NUMBER_ID is set to a 10-digit mobile number (${config.phoneNumberId}). It must be Meta\'s 15-digit Phone Number ID from developers.facebook.com.'
            : 'Please set WHATSAPP_PHONE_NUMBER_ID and WHATSAPP_ACCESS_TOKEN in assets/.env.',
      );
    }
    return null;
  }

  /// Send a pre-approved template message
  Future<WhatsAppDispatchResult> sendTemplateMessage({
    required String toPhone,
    required String templateName,
    String languageCode = 'en_US',
    List<String>? bodyParameters,
  }) async {
    final config = getConfig();
    final configErr = _checkConfiguration(config);
    if (configErr != null) return configErr;

    final toClean = normalizePhone(toPhone);
    final endpoint =
        Uri.parse('$_graphApiBase/${config.phoneNumberId}/messages');

    final Map<String, dynamic> templatePayload = {
      'name': templateName,
      'language': {'code': languageCode},
    };

    if (bodyParameters != null && bodyParameters.isNotEmpty) {
      templatePayload['components'] = [
        {
          'type': 'body',
          'parameters':
              bodyParameters.map((p) => {'type': 'text', 'text': p}).toList(),
        }
      ];
    }

    final Map<String, dynamic> requestBody = {
      'messaging_product': 'whatsapp',
      'recipient_type': 'individual',
      'to': toClean,
      'type': 'template',
      'template': templatePayload,
    };

    try {
      final response = await http.post(
        endpoint,
        headers: {
          'Authorization': 'Bearer ${config.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      final result =
          WhatsAppResponseParser.parse(response.statusCode, response.body);

      await WhatsAppAuditLogger.logOutboundEvent(
        toClean: toClean,
        eventType: 'template_$templateName',
        success: result.success,
        statusCode: response.statusCode,
        messageId: result.messageId,
        error: result.errorSummary,
      );

      return result;
    } catch (e) {
      final errorResult = WhatsAppDispatchResult(
        success: false,
        statusCode: 0,
        errorSummary: 'Network error connecting to Meta Graph API: $e',
        detailedError: e.toString(),
      );

      await WhatsAppAuditLogger.logOutboundEvent(
        toClean: toClean,
        eventType: 'template_$templateName',
        success: false,
        statusCode: 0,
        error: e.toString(),
      );

      return errorResult;
    }
  }

  /// Send a free-form text message
  Future<WhatsAppDispatchResult> sendTextMessage({
    required String toPhone,
    required String bodyText,
  }) async {
    final config = getConfig();
    final configErr = _checkConfiguration(config);
    if (configErr != null) return configErr;

    final toClean = normalizePhone(toPhone);
    final endpoint =
        Uri.parse('$_graphApiBase/${config.phoneNumberId}/messages');

    final Map<String, dynamic> requestBody = {
      'messaging_product': 'whatsapp',
      'recipient_type': 'individual',
      'to': toClean,
      'type': 'text',
      'text': {'body': bodyText},
    };

    try {
      final response = await http.post(
        endpoint,
        headers: {
          'Authorization': 'Bearer ${config.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      final result =
          WhatsAppResponseParser.parse(response.statusCode, response.body);

      await WhatsAppAuditLogger.logOutboundEvent(
        toClean: toClean,
        eventType: 'text_message',
        success: result.success,
        statusCode: response.statusCode,
        messageId: result.messageId,
        error: result.errorSummary,
      );

      return result;
    } catch (e) {
      return WhatsAppDispatchResult(
        success: false,
        statusCode: 0,
        errorSummary: 'Network error connecting to Meta Graph API: $e',
        detailedError: e.toString(),
      );
    }
  }
}
